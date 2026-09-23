# QubesOS → NixOS: the "qubes-ish" layout of gentuwu

Qubes runs every app in a VM on a bare-metal hypervisor: an AppVM talks only
to a TemplateVM's wayland, and the *only* network exit from your whole desktop
is a `sys-net` VM. You can't get one-for-one Qubes on NixOS without running
actual Xen/KVM VMs, but on gentuwu the same *threat model* is approximated at
three isolation levels. This is the map; status reflects what is wired up in
the flake today.

## The isolation stack (top → bottom)

| Qubes concept | NixOS equivalent on gentuwu | status |
|---|---|---|
| **sys-net / netVM** | per-app network namespaces (`netvm.nix`): `browsernet` (internet, no LAN) and `homenet` (LAN, no internet), each with its own nft NAT + FORWARD policy | ✅ |
| **FirewallVM (sys-fw)** | `adguardhome` (DNS: OISD + 1Hosts + HaGeZi blocks, DNSSEC) + `dnsguard` nft table (egress :53 blocked) | ✅ |
| **AppVM** | firejail profiles, `netns <domain>` (librewolf → browsernet, zathura → net none) | ✅ |
| **DisposableVM** | `dvm` / `dvm-browser` (`--private`, browsernet, nothing persists) | ✅ |
| **Untrusted-files qube** | `containers.quarantine` (nspawn, no NAT, no route, ephemeral root, `/work` bind, offline tooling) | ✅ |
| **full VM (offline / burned)** | libvirtd + virt-manager (already enabled; make a locked-down `windows-offline` pool / `tails` VM) | 🚧 optional |
| **Trusted boot / AEM** | LUKS2 + TPM2 (PCR7+11) + Secure Boot (lanzaboote) | 📋 planned, see below |
| **USB / device policy** | usbguard allow-by-default | 🚧 optional |

## The domains (`gentuwu/networking/netvms.nix`)

Data-driven; add a domain, then a firejail profile with `netns <name>` and
`dns 10.254.<idx>.1`:

| domain | idx | sandbox | policy |
|---|---|---|---|
| `browsernet` | 0 | 10.254.0.2/30 | internet yes; LAN + RFC1918 + mDNS/LLMNR **blocked** at the host FORWARD hook (defense in depth on top of dnsguard) |
| `homenet` | 1 | 10.254.1.2/30 | LAN + mDNS only; **no internet** (FORWARD policy drop, only 10/8–172.16/12–192.168/16 accepted) |

DNS for each domain is the adguard instance bound to the host veth endpoint
(10.254.0.1 / 10.254.1.1).

### new domain, reviewed
```nix
# in netvm.nix: domains.mytv = mkDomain "mytv" 2;
# then a profile, e.g. gentuwu/security/firejail.nix:
#   firejail.vms.mytv = {
#     profile = '' netns mytv dns 10.254.2.1 ; '';
#   };
```

## Firejail app map (`gentuwu/security/firejail.nix`)

| app | domain | note |
|---|---|---|
| librewolf | browsernet | profile `netns browsernet`, `dns 10.254.0.1` |
| qutebrowser | host | stays host-net: its whole point is localhost UIs (streams into browser via localhost); dnsguard still blocks its egress :53 |
| everything else | `net none` by default | inherit the strong default firejail profile |

## Disposable launchers (`gentuwu/security/dvm.nix`)

- `dvm <cmd>` — firejail `--private --netns=browsernet --dns=10.254.0.1`; HOME
  is a tmpfs, per-instance name/pid, dropped on exit.
- `dvm-browser` — same, but librewolf with a zeroed profile.

## Untrusted files (`gentuwu/virtualisation/quarantine.nix`)

- `quarantine foo.pdf evil.zip ...` — container starts on demand, files copied
  into `/work`, then `file`/`exiftool`/`pdftotext`/`strings`/`bsdtar -tvf`
  output is printed to your host. Nothing written sticks: `ephemeral = true`.
- `quarantine-shell` — interactive root inside.
- Network: `privateNetwork`, **no** masquerade, container has no default route
  and hosts drop forwarding from `ve-quarantine` → it can only talk to the
  host over 10.233.0.0/16, i.e. it cannot reach ANY other machine.

## Trusted boot / anti-evil-maid — PLAN (not yet on disk)

Current state (from `hardware-configuration.nix`): **no LUKS at all**
(root = ext4 label `nixos`, `/boot` vfat label `boot`, swap label `swap`),
bootloader `limine`. To get "unlockless boot that bricks if firmware/UKI is
tampered with" (Qubes' AEM):

1. **Encrypt the disk.** Reinstall per the `justfile install` recipe but define
   a LUKS2 layout in disko: `swap` luks (volatile, key-less) + root luks.
   Requires nuking the disk — snapshot/home your data first.
2. **TPM2 auto-unlock (PCR-bound).** `systemd-cryptenroll --tpm2-device auto
   --tpm2-pcrs 7+11` so boot needs no passphrase, but turning off Secure Boot
   or a different firmware release still demands the recovery key. Keep a
   paper recovery key.
3. **Switch limine → systemd-boot + lanzaboote.** lanzaboote signs kernel +
   initrd as a UKI with your local CA keys; leaves the UKI as the last
   trustworthy link, closes shenanigans like a tampered initrd. Verify with
   `lanzaboote`'s enroll step (sbctl-style, keys held on a USB key stored
   apart from the machine).

Partial alternative if you keep limine: Secure Boot only via shim/MOK signing
(no UKI) — weaker crypto-chain but avoids the bootloader switch.

## Optional remaining steps

- **usbguard** — Qubes treats USB as a device domain: allowlist your keyboard,
  mouse, YubiKey; block the rest.
- **split GPG/SSH** — keep the signing key on the YubiKey, agent on a
  `homenet` sandbox.
- **offline VM** — a `net none` libvirtd VM for the burned bridge, since the
  host nets never fully trust each other anyway.

## How to exercise it

```bash
# per-domain sanity (needs root):
sudo ip netns exec browsernet ping 1.1.1.1     # resolves/works
sudo ip netns exec homenet   ping 1.1.1.1      # hangs (no internet)
sudo ip netns exec homenet   ping 192.168.1.1  # works (LAN)
sudo nft list table inet netvm-browsernet      # see the forward policy

# isolation:
dvm-browser                                    # fresh browser, no history
quarantine ~/Downloads/weird.zip               # offline file autopsy
```