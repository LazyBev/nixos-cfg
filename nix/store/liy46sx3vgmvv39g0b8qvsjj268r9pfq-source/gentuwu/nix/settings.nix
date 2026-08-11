_: {
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = [ "yari" ];
    max-jobs = 6;
    build-cores = 6;
    max-substitution-jobs = 16;
    keep-going = true;
  };
}
