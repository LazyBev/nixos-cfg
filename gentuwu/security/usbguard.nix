_: {
  services.usbguard = {
    enable = true;
    rules = ''
      allow id 1d6b:0002
      allow id 1d6b:0003
      allow id 1d6b:0005
      allow id 30c9:0042
      allow id 8087:0026
      allow id 04e8:6860
      allow id 320f:505b
      allow id 413c:301a
    '';
    implicitPolicyTarget = "block";
    IPCAllowedUsers = [
      "root"
      "yari"
    ];
    IPCAllowedGroups = [ "wheel" ];
  };
}
