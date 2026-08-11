_: {
  security.doas.enable = true;
  security.doas.extraRules = [
    {
      groups = [ "wheel" ];
      noPass = true;
      keepEnv = true;
    }
  ];
}
