config.load_autoconfig()

c.content.user_stylesheets = ["~/.config/qutebrowser/styles/youtube.css"]

c.colors.statusbar.normal.bg = "#282a36"
c.colors.statusbar.command.bg = "#282a36"
c.colors.statusbar.command.fg = "#f8f8f2"
c.colors.statusbar.normal.fg = "#8be9fd"
c.colors.statusbar.passthrough.fg = "#8be9fd"
c.colors.statusbar.url.fg = "#ff79c6"
c.colors.statusbar.url.success.https.fg = "#ff79c6"
c.colors.statusbar.url.hover.fg = "#bd93f9"
c.colors.tabs.even.bg = "#282a36"
c.colors.tabs.odd.bg = "#282a36"
c.colors.tabs.bar.bg = "#282a36"
c.colors.tabs.even.fg = "#6272a4"
c.colors.tabs.odd.fg = "#6272a4"
c.colors.tabs.selected.even.bg = "#bd93f9"
c.colors.tabs.selected.odd.bg = "#bd93f9"
c.colors.tabs.selected.even.fg = "#282a36"
c.colors.tabs.selected.odd.fg = "#282a36"
c.colors.hints.bg = "#282a36"
c.colors.hints.fg = "#f8f8f2"
c.tabs.show = "multiple"
c.colors.completion.item.selected.match.fg = "#8be9fd"
c.colors.completion.match.fg = "#8be9fd"
c.colors.tabs.indicator.start = "#50fa7b"
c.colors.tabs.indicator.stop = "#44475a"
c.colors.completion.odd.bg = "#282a36"
c.colors.completion.even.bg = "#282a36"
c.colors.completion.fg = "#f8f8f2"
c.colors.completion.category.bg = "#282a36"
c.colors.completion.category.fg = "#f8f8f2"
c.colors.completion.item.selected.bg = "#282a36"
c.colors.completion.item.selected.fg = "#f8f8f2"
c.colors.messages.info.bg = "#282a36"
c.colors.messages.info.fg = "#f8f8f2"
c.colors.messages.error.bg = "#282a36"
c.colors.messages.error.fg = "#f8f8f2"
c.colors.downloads.error.bg = "#282a36"
c.colors.downloads.error.fg = "#f8f8f2"
c.colors.downloads.bar.bg = "#282a36"
c.colors.downloads.start.bg = "#50fa7b"
c.colors.downloads.start.fg = "#f8f8f2"
c.colors.downloads.stop.bg = "#44475a"
c.colors.downloads.stop.fg = "#f8f8f2"
c.colors.tooltip.bg = "#282a36"
c.colors.webpage.bg = "#282a36"
c.hints.border = "#f8f8f2"
c.tabs.title.format = "{audio}{current_title}"
c.fonts.web.size.default = 20
c.tabs.padding = {"top": 5, "bottom": 5, "left": 9, "right": 9}
c.tabs.indicator.width = 0
c.tabs.width = "7%"
c.fonts.default_family = []
c.fonts.default_size = "13pt"
c.fonts.web.family.fixed = "monospace"
c.fonts.web.family.sans_serif = "monospace"
c.fonts.web.family.serif = "monospace"
c.fonts.web.family.standard = "monospace"
c.colors.webpage.darkmode.enabled = True
c.colors.webpage.darkmode.algorithm = "lightness-cielab"
c.colors.webpage.darkmode.policy.images = "never"
config.set("colors.webpage.darkmode.enabled", False, "file://*")

# =============================================================================
# URLs & Search
# =============================================================================
c.url.default_page = "http://localhost:8087"
c.url.start_pages = ["http://localhost:8087"]
c.url.auto_search = "naive"
c.url.searchengines = {
    "DEFAULT": "http://localhost:8087/search?q={}",
    "!a": "https://wiki.archlinux.org/?search={}",
    "!aw": "https://wiki.archlinux.org/?search={}",
    "!n": "https://wiki.nixos.org/?search={}",
    "!nix": "https://wiki.nixos.org/?search={}",
    "!np": "https://search.nixos.org/packages?query={}",
    "!no": "https://search.nixos.org/options?query={}",
    "!gh": "https://github.com/search?q={}",
    "!r": "https://reddit.com/r/{}",
    "!yt": "https://youtube.com/results?search_query={}",
    "!w": "https://en.wikipedia.org/wiki/{}",
    "!m": "https://www.google.com/maps?q={}",
    "!so": "https://stackoverflow.com/search?q={}",
}

# =============================================================================
# Tabs
# =============================================================================
c.tabs.position = "top"
c.tabs.favicons.scale = 1.0
c.tabs.mousewheel_switching = False
c.tabs.new_position.related = "next"
c.tabs.new_position.unrelated = "last"

# =============================================================================
# Statusbar
# =============================================================================
c.statusbar.show = "in-mode"
c.statusbar.padding = {"top": 4, "bottom": 4, "left": 6, "right": 6}

# =============================================================================
# Downloads
# =============================================================================
c.downloads.position = "bottom"
c.downloads.remove_finished = 5000

# =============================================================================
# Scrolling
# =============================================================================
c.scrolling.smooth = True
c.scrolling.bar = "always"

# =============================================================================
# Completion
# =============================================================================
c.completion.height = "35%"
c.completion.show = "always"

# =============================================================================
# Content & Privacy
# =============================================================================
c.content.autoplay = False
c.content.notifications.enabled = False
c.content.geolocation = False
c.content.cookies.store = True
c.content.cookies.accept = "no-3rdparty"
c.content.blocking.enabled = True
c.content.blocking.method = "both"
c.content.blocking.adblock.lists = [
    "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/filters.txt",
    "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/annoyances.txt",
    "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/quick-fixes.txt",
    "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/unbreak.txt",
]
c.content.headers.user_agent = "Mozilla/5.0 (X11; Linux x86_64; rv:136.0) Gecko/20100101 Firefox/136.0"
c.content.headers.accept_language = "en-US,en;q=0.9"
c.content.headers.do_not_track = True
c.content.webrtc_ip_handling_policy = "disable-non-proxied-udp"

# =============================================================================
# Zoom
# =============================================================================
c.zoom.default = "100%"
c.zoom.mouse_divider = 512

# =============================================================================
# Editor
# =============================================================================
c.editor.command = ["alacritty", "-e", "nvim", "{file}", "-c", "normal {line}G{column}l"]

# =============================================================================
# Hints
# =============================================================================
c.hints.auto_follow = "unique-match"
c.hints.uppercase = True
c.hints.scatter = True

# =============================================================================
# Input
# =============================================================================
c.input.insert_mode.auto_load = False
c.input.insert_mode.auto_leave = True
c.input.partial_timeout = 5000

# =============================================================================
# Session
# =============================================================================
c.confirm_quit = ["downloads"]
c.auto_save.session = True
c.session.default_name = "default"

# =============================================================================
# Aliases
# =============================================================================
c.aliases = { "q": "close", "qa": "quit", "w": "session-save", "wq": "quit --save", "e": "open editor", "h": "back", "l": "forward" }

# =============================================================================
# Keybinds
# =============================================================================
config.bind("H", "back")
config.bind("L", "forward")
config.bind("J", "tab-prev")
config.bind("K", "tab-next")
config.bind("r", "reload")
config.bind("R", "reload --force")
config.bind("gg", "scroll-to-perc 0")
config.bind("G", "scroll-to-perc")
config.bind("j", "scroll down")
config.bind("k", "scroll up")
config.bind("h", "scroll left")
config.bind("l", "scroll right")
config.bind("t", "open -t")
config.bind("T", "cmd-set-text -s :open -t")
config.bind("o", "cmd-set-text -s :open")
config.bind("O", "cmd-set-text -s :open -t")
config.bind("d", "tab-close")
config.bind("u", "undo")
config.bind("f", "hint")
config.bind("F", "hint links tab")
config.bind("yy", "yank")
config.bind("yt", "yank title")
config.bind("+", "zoom-in")
config.bind("-", "zoom-out")
config.bind("=", "zoom")
config.bind("g1", "tab-focus 1")
config.bind("g2", "tab-focus 2")
config.bind("g3", "tab-focus 3")
config.bind("g4", "tab-focus 4")
config.bind("g5", "tab-focus 5")
config.bind("g6", "tab-focus 6")
config.bind("g7", "tab-focus 7")
config.bind("g8", "tab-focus 8")
config.bind("g9", "tab-focus 9")
config.bind("M", "spawn --detach mpv {url}")
config.bind("ZZ", "quit --save")
config.bind("ZQ", "quit")
