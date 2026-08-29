{
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    wineWow64Packages.stable
    winetricks
    vulkan-loader
    vulkan-tools
  ];
}
