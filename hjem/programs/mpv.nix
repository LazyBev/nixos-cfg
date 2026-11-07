{ pkgs, ... }:
{
  rum.programs.mpv = {
    enable = true;
    config = {
      osc = "no";
      keepaspect = "yes";
      vo = "gpu-next";
      gpu-context = "wayland";
      hwdec = "vaapi";
      profile = "gpu-hq";
      watch-later-options-remove = "sub-pos";
    };
    scripts = with pkgs.mpvScripts; [
      modernz
      thumbfast
    ];
  };
}
