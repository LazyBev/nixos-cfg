# LibreWolf with a fixed set of extensions.
{
  wrapFirefox,
  librewolf-unwrapped,
  fetchFirefoxAddon,
}:
let
  addon =
    name: id: file: sha256:
    fetchFirefoxAddon {
      inherit name sha256;
      url = "https://addons.mozilla.org/firefox/downloads/file/${id}/${file}.xpi";
    };
in
wrapFirefox librewolf-unwrapped {
  nixExtensions = [
    (addon "ublock-origin" "4814095" "ublock_origin-1.71.0"
      "47f788a1fc2c014830b30bb0ef9588615701b98c5265fb19b8cf4ba779849feb"
    )
    (addon "darkreader" "4837294" "darkreader-4.9.127"
      "25f06b10b43270266af63c8d25e01ecf5e497bd2d5411243ee6d19b3869296ad"
    )
    (addon "vimium" "4717567" "vimium_ff-2.4.2"
      "131e2a67580e7ae9125ab19781159e61409fac47b441fc2782aab76396ead196"
    )
    (addon "return-youtube-dislike" "4371820" "return_youtube_dislikes-3.0.0.18"
      "2d33977ce93276537543161f8e05c3612f71556840ae1eb98239284b8f8ba19e"
    )
    (addon "privacy-badger" "4700632" "privacy_badger17-2026.2.20"
      "eea49f1461de5eb00eb17b22b2864b55b54acb577b0360687460fe982633fbd6"
    )
    (addon "tampermonkey" "4797143" "tampermonkey-5.5.0"
      "190031c78dbc5696114835601f2c8e6b855ad1e134df5df278f8fc158c065908"
    )
    (addon "facebook-container" "4451874" "facebook_container-2.3.12"
      "3369bd865877860e6d7d38399d5902b300d3d5737acb2d1342ff5beb1d3780c1"
    )
    (addon "sidebery" "4766841" "sidebery-5.5.2"
      "43e7dd4b8f684e637193d645fbcc94fb182583d24ac9a5b58effc4fb4d9faef2"
    )
    (addon "tabliss" "3940751" "tabliss-2.6.0"
      "de766810f234b1c13ffdb7047ae6cbf06ed79c3d08b51a07e4766fadff089c0f"
    )
    (addon "btroblox" "4555645" "btroblox-3.6.21"
      "87572eb0db7cbfb8572cfecbd356f1c1a354cd7d6df6af8b29e1aa0bd1aa00e5"
    )
  ];
}
