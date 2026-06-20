{ config, pkgs, ... }: {
  users.users.yari = {
    isNormalUser = true;
    description = "yari";
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
    shell = pkgs.fish;
    hashedPassword = "$6$nN7OLzbsuAMcQeFm$wcYnLy9ZWw8Ai7KIXUSg70UgziPfjK8h2elDAgetE0CZTfWUrN9TKzJL7mJcBshL16VuoXWpGT6bv1VhQ2zC9.";
  };
  users.defaultUserShell = pkgs.fish;
}
