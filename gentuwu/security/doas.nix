_:
{
  security.doas.enable = true;
  security.doas.extraRules = [
    {
      groups = [ "wheel" ];
      # No `noPass`: any compromise of the (sole) user would otherwise be an
      # instant, silent path to root. Requiring a password turns a pwned
      # process into a visible auth event instead.
      keepEnv = true;
    }
  ];
}