{ pkgs, ... }: {
  users.users.yari = {
    isNormalUser = true;
    uid = 1002;
    description = "yari";
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "audio"
    ];
    shell = pkgs.fish;
    hashedPassword = builtins.getEnv "USER_PASSWORD_HASH";
  };
  users.defaultUserShell = pkgs.fish;
}
