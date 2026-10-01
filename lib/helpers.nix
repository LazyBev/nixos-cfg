# Centralized NixOS configuration helpers
# Usage: helpers = import ../lib/helpers.nix { inherit lib; };
{ lib }:

let
  # ── Option shorthand ──────────────────────────────────

  mkStrOpt =
    default: description:
    lib.mkOption {
      type = lib.types.str;
      inherit default description;
    };

  mkIntOpt =
    default: description:
    lib.mkOption {
      type = lib.types.int;
      inherit default description;
    };

  mkPathOpt =
    default: description:
    lib.mkOption {
      type = lib.types.path;
      inherit default description;
    };

in
{
  inherit
    mkStrOpt
    mkIntOpt
    mkPathOpt
    ;
}