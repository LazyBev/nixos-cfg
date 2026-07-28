# Centralized NixOS configuration helpers
# Usage: helpers = import ../lib/helpers.nix { inherit lib; };
{ lib }:

let
  # ── Option shorthand ──────────────────────────────────

  mkStrOpt = default: description: lib.mkOption {
    type = lib.types.str;
    inherit default description;
  };

  mkBoolOpt = default: description: lib.mkOption {
    type = lib.types.bool;
    inherit default description;
  };

  mkIntOpt = default: description: lib.mkOption {
    type = lib.types.int;
    inherit default description;
  };

  mkPathOpt = default: description: lib.mkOption {
    type = lib.types.path;
    inherit default description;
  };

  mkPortOpt = default: description: lib.mkOption {
    type = lib.types.port;
    inherit default description;
  };

  mkEnumOpt = values: default: description: lib.mkOption {
    type = lib.types.nullOr (lib.types.enum values);
    inherit default description;
  };

  mkListOpt = elemType: default: description: lib.mkOption {
    type = lib.types.listOf elemType;
    inherit default description;
  };

  # ── Host conditionals ─────────────────────────────────

  isHostIn = config: hosts: builtins.elem config.vars.hostname hosts;
  isGentuwu = config: config.vars.hostname == "gentuwu";

  onHosts = config: hosts: body:
    lib.mkIf (isHostIn config hosts) body;

  # ── Systemd service security hardening ────────────────

  hardenService = {
    privateTmp = true;
    protectSystem = "strict";
    protectHome = true;
  };

  # ── Common sysctl security settings ───────────────────

  securitySysctl = {
    "kernel.kptr_restrict" = 2;
    "kernel.dmesg_restrict" = 1;
    "kernel.perf_event_paranoid" = 3;
    "kernel.unprivileged_bpf_disabled" = 1;
    "kernel.ftrace_enabled" = false;
    "net.core.bpf_jit_harden" = 2;
    "net.ipv4.tcp_syncookies" = 1;
    "net.ipv4.conf.all.rp_filter" = 1;
    "net.ipv4.conf.default.rp_filter" = 1;
    "net.ipv4.conf.all.log_martians" = true;
    "net.ipv4.conf.default.log_martians" = true;
    "net.ipv4.conf.all.accept_redirects" = 0;
    "net.ipv4.conf.default.accept_redirects" = 0;
    "net.ipv6.conf.all.accept_redirects" = 0;
    "net.ipv6.conf.default.accept_redirects" = 0;
    "net.ipv4.conf.all.secure_redirects" = 0;
    "net.ipv4.conf.all.send_redirects" = 0;
    "net.ipv4.conf.all.accept_source_route" = 0;
    "net.ipv6.conf.all.accept_source_route" = 0;
  };

  # ── Network helper ────────────────────────────────────

  mkFirewallRule = port: protocol: {
    inherit port;
    proto = protocol;
  };

in {
  inherit
    mkStrOpt mkBoolOpt mkIntOpt mkPathOpt mkPortOpt
    mkEnumOpt mkListOpt
    isHostIn isGentuwu
    onHosts
    hardenService securitySysctl
    mkFirewallRule;
}
