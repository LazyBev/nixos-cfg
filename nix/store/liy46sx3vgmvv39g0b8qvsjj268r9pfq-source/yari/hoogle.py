#!/usr/bin/env python3
import sqlite3, re, os, sys, html, json
from pathlib import Path
from html.parser import HTMLParser

DB = Path.home() / ".local/share/hoogle/search.db"

def find_rustdoc():
    for p in sorted(Path("/nix/store").iterdir(), reverse=True):
        if "-rustc-" in p.name and p.name.endswith("-doc"):
            r = p / "share/doc/docs/html"
            if (r / "index.html").exists(): return r
    return None

def find_odin():
    for p in sorted(Path("/nix/store").iterdir(), reverse=True):
        if "-odin-" in p.name:
            s = p / "share"
            if (s / "core").is_dir(): return s
    return None

# ── Rust HTML parser ────────────────────────────────────────

def parse_rust_html(path, crate):
    text = path.read_text(errors="replace")
    items = []
    # Extract all section blocks: <section id="..." class="TYPE"> ... </section>
    sections = re.finditer(
        r'<section\s+id="([^"]*)"\s+class="([a-z]+)"[^>]*>.*?</section>',
        text, re.DOTALL
    )
    for m in sections:
        sid, stype = m.group(1), m.group(2)
        block = m.group(0)
        if stype in ("method", "fn", "struct", "enum", "trait", "union", "type", "constant", "static", "macro", "associatedconstant", "associatedtype", "typedef", "union", "variant", "foreigntype"):
            sig_m = re.search(r'<h4\s+class="code-header">(.*?)</h4>', block, re.DOTALL)
            desc_m = re.search(r'<div\s+class="docblock">\s*(.*?)\s*</div>', block, re.DOTALL)
            sig = clean_html(sig_m.group(1)) if sig_m else ""
            desc = clean_html(desc_m.group(1)) if desc_m else ""
            name = sid.removeprefix("method.").removeprefix("impl-").removeprefix("trait-").removeprefix("associatedconstant.").removeprefix("associatedtype.")
            if not name: name = sid
            items.append((name, sig, desc, crate, stype, str(path)))
    return items

def clean_html(t):
    t = re.sub(r'<[^>]+>', '', t)
    t = html.unescape(t)
    t = re.sub(r'\s+', ' ', t).strip()
    return t

def index_rust(conn):
    rp = find_rustdoc()
    if not rp:
        print("rustdoc not found in nix store")
        return
    print(f"Indexing Rust docs from {rp}...")
    cur = conn.cursor()
    seen = set()
    count = 0
    for html_file in rp.rglob("*.html"):
        parts = html_file.relative_to(rp).parts
        if len(parts) < 2: continue
        crate = parts[0]
        if crate in ("src", "static.files", "search.index", "trait.impl", "type.impl"): continue
        try:
            items = parse_rust_html(html_file, crate)
            for name, sig, desc, crate, stype, path in items:
                dedup_key = (name, sig, crate)
                if dedup_key in seen: continue
                seen.add(dedup_key)
                cur.execute("INSERT OR IGNORE INTO docs (name, signature, description, package, type, lang, path) VALUES (?,?,?,?,?,?,?)",
                           (name, sig, desc, f"rust:{crate}", stype, "rust", path))
                count += 1
        except Exception:
            pass
    conn.commit()
    print(f"  indexed {count} Rust items")

# ── Odin parser ─────────────────────────────────────────────

def parse_odin_file(path, base):
    text = path.read_text(errors="replace")
    items = set()
    pkg_m = re.search(r'^\s*package\s+(\w+)', text, re.MULTILINE)
    pkg = pkg_m.group(1) if pkg_m else "unknown"
    rel = path.relative_to(base)
    crate = f"odin:{'.'.join(rel.parts[:-1])}" if len(rel.parts) > 1 else f"odin:{pkg}"

    for m in re.finditer(
        r'(?P<comment>(?:/\*.*?\*/|//[^\n]*\n\s*)*?)\s*'
        r'(?:@\([^)]*\)\s*\n\s*)*'
        r'(?P<name>\w+)\s*::\s*(?P<kind>proc|struct|enum|union)\s*'
        r'(?P<sig>(?:[^{;(]|\([^)]*\)|\[^\]]*\])+)',
        text, re.DOTALL
    ):
        name = m.group("name")
        kind = m.group("kind")
        sig = m.group("sig").strip()
        sig = re.sub(r'\s+', ' ', sig)[:200]
        comment = m.group("comment")
        desc = ""
        if comment:
            desc = re.sub(r'/\*|\*/|//|^\s*\*', '', comment, flags=re.MULTILINE).strip()
            desc = re.sub(r'\s+', ' ', desc).strip()[:300]
        full_sig = f"{name} :: {kind}({sig})" if kind == "proc" else f"{name} :: {kind} {sig}"
        items.add((name, full_sig, desc, crate, kind, str(path)))
    return list(items)

def index_odin(conn):
    oroot = find_odin()
    if not oroot:
        print("odin not found in nix store")
        return
    print(f"Indexing Odin docs from {oroot}...")
    cur = conn.cursor()
    count = 0
    for f in sorted(oroot.rglob("*.odin")):
        try:
            items = parse_odin_file(f, oroot)
            for name, sig, desc, crate, kind, path in items:
                cur.execute("INSERT OR IGNORE INTO docs (name, signature, description, package, type, lang, path) VALUES (?,?,?,?,?,?,?)",
                           (name, sig, desc[:500], crate, kind, "odin", path))
                count += 1
        except Exception as e:
            pass
    conn.commit()
    print(f"  indexed {count} Odin items")

# ── Database ─────────────────────────────────────────────────

def init_db():
    DB.parent.mkdir(parents=True, exist_ok=True)
    conn = sqlite3.connect(str(DB))
    conn.execute("PRAGMA journal_mode=WAL")
    conn.execute("CREATE TABLE IF NOT EXISTS docs ("
                 "id INTEGER PRIMARY KEY, "
                 "name TEXT, signature TEXT, description TEXT, "
                 "package TEXT, type TEXT, lang TEXT, path TEXT)")
    conn.execute("CREATE VIRTUAL TABLE IF NOT EXISTS docs_fts USING fts5("
                 "name, signature, description, package, "
                 "content='docs', content_rowid='id')")
    conn.commit()
    return conn

def rebuild_index(conn):
    conn.execute("DELETE FROM docs")
    conn.execute("INSERT INTO docs_fts(docs_fts) VALUES('delete-all')")
    conn.commit()
    index_rust(conn)
    index_odin(conn)
    # rebuild FTS index
    conn.execute("INSERT INTO docs_fts(docs_fts) VALUES('rebuild')")
    conn.commit()

# ── CLI Search ───────────────────────────────────────────────

def search(conn, query, limit=20):
    words = query.split()
    # Try exact phrase first, then OR individual words
    fts_queries = [
        f'"{query}"',
        " NEAR ".join(f'"{w}"' for w in words),
        " OR ".join(f'"{w}"' for w in words),
        " OR ".join(words),
    ]
    for fts_q in fts_queries:
        if len(fts_q) > 200: continue
        try:
            cur = conn.execute(
                "SELECT d.name, d.signature, snippet(docs_fts, 1, '<b>', '</b>', '...', 32), "
                "d.package, d.type, d.lang "
                "FROM docs_fts f JOIN docs d ON f.rowid = d.id "
                "WHERE docs_fts MATCH ? "
                "ORDER BY rank LIMIT ?", (fts_q, limit))
            results = cur.fetchall()
            if results: return results
        except sqlite3.OperationalError:
            continue
    # fallback: LIKE search
    like = f"%{query}%"
    cur = conn.execute(
        "SELECT name, signature, substr(description,1,80), package, type, lang "
        "FROM docs WHERE name LIKE ? OR description LIKE ? "
        "LIMIT ?", (like, like, limit))
    return cur.fetchall()

def print_results(results):
    if not results:
        print("No results.")
        return
    for name, sig, desc, package, typ, lang in results:
        pkg_short = package.split(":")[-1] if ":" in package else package
        sig = clean_html(sig)[:100]
        desc = clean_html(desc)[:80]
        print(f"  \033[36m{pkg_short}\033[0m :: \033[33m{name}\033[0m \033[90m({typ}, {lang})\033[0m")
        if sig: print(f"    \033[2m{sig}\033[0m")
        if desc: print(f"    {desc}")
        print()

# ── Main ─────────────────────────────────────────────────────

def main():
    import argparse
    parser = argparse.ArgumentParser(description="Offline Hoogle for Rust and Odin")
    sub = parser.add_subparsers(dest="cmd")
    sub.add_parser("index", help="Build/rebuild search index")
    search_p = sub.add_parser("search", help="Search documentation")
    search_p.add_argument("query", nargs="+", help="Search query")
    search_p.add_argument("-n", type=int, default=20, help="Max results")
    info_p = sub.add_parser("info", help="Show index info")

    args = parser.parse_args()
    if not args.cmd:
        parser.print_help()
        return

    conn = init_db()

    if args.cmd == "index":
        rebuild_index(conn)
        print("Done.")
    elif args.cmd == "search":
        query = " ".join(args.query)
        results = search(conn, query, args.n)
        print_results(results)
    elif args.cmd == "info":
        cur = conn.execute("SELECT lang, COUNT(*) FROM docs GROUP BY lang")
        for lang, cnt in cur:
            print(f"  {lang}: {cnt} items")
        cur = conn.execute("SELECT COUNT(*) FROM docs")
        print(f"  total: {cur.fetchone()[0]} items")

if __name__ == "__main__":
    main()
