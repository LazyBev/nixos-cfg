{ config, ... }: {
  services.mpd = {
    enable = true;
    user = "yari";
    dataDir = "/home/yari/.mpd";
    settings = {
      music_directory = "/home/yari/Music";
      audio_output = [
        {
          type = "pulse";
          name = "PulseAudio (via PipeWire)";
          server = "/run/user/${toString config.users.users.yari.uid}/pulse/native";
        }
      ];
    };
  };
}
