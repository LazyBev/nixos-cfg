{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [ sway swaylock swayidle waybar ];
}
