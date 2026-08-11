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
      "input"
    ];
    shell = pkgs.fish;
  };
  users.defaultUserShell = pkgs.fish;
}
