{
  nixcord,
  config,
  lib,
  options,
  pkgs,
  ...
}:
let
  cfg = config.programs.nixcord;

  common = import (nixcord + "/modules/lib/mkCommonConfig.nix") {
    inherit
      config
      lib
      options
      pkgs
      ;
  };

  homeDir = lib.attrsets.attrByPath [ cfg.user "home" ] "/home/${cfg.user}" config.users.users;

  install = lib.getExe' pkgs.coreutils "install";

  id = lib.getExe' pkgs.coreutils "id";
  setpriv = lib.getExe' pkgs.util-linux "setpriv";
  activationScripts = common.mkActivationScripts (script: ''
    uid="$(${id} -u ${lib.escapeShellArg cfg.user})"
    gid="$(${id} -g ${lib.escapeShellArg cfg.user})"
    ${setpriv} --reuid="$uid" --regid="$gid" --init-groups ${pkgs.runtimeShell} -c ${lib.escapeShellArg script}
  '');
in
{
  imports = [ (nixcord + "/modules/common.nix") ];

  programs.nixcord = lib.recursiveUpdate (common.mkConfigDirs cfg cfg.xdgConfigHome) {
    enable = true;
    user = config.modules.user.name;

    homeDirectory = lib.mkDefault homeDir;
    xdgConfigHome = lib.mkDefault "${homeDir}/.config";
    finalPackage = common.packages.final;

    discord.equicord.enable = true;

    config = {
      transparent = true;
      frameless = true;
      plugins = {
        accountPanelServerProfile.enable = true;
        alwaysAnimate.enable = true;
        alwaysExpandRoles.enable = true;
        betterFolders.enable = true;
        betterGifAltText.enable = true;
        betterGifPicker.enable = true;
        betterRoleDot.enable = true;
        betterSettings.enable = true;
        betterUploadButton.enable = true;
        biggerStreamPreview.enable = true;
        blurNsfw.enable = true;
        callTimer.enable = true;
        characterCounter.enable = true;
        clearUrls.enable = true;
        concatenatedComponentExtractor.enable = true;
        consoleJanitor.enable = true;
        crashHandler.enable = true;
        dearrow.enable = true;
        disableCallIdle.enable = true;
        disableDeepLinks.enable = true;
        dontRoundMyTimestamps.enable = true;
        fakeNitro.enable = true;
        fakeProfileThemes.enable = true;
        fixCodeblockGap.enable = true;
        fixImagesQuality.enable = true;
        fixSpotifyEmbeds.enable = true;
        fixYoutubeEmbeds.enable = true;
        forceOwnerCrown.enable = true;
        friendInvites.enable = true;
        fullUserInChatbox.enable = true;
        gameActivityToggle.enable = true;
        gifPaste.enable = true;
        iLoveSpam.enable = true;
        imageZoom.enable = true;
        implicitRelationships.enable = true;
        keepCurrentChannel.enable = true;
        memberCount.enable = true;
        mentionAvatars.enable = true;
        messageClickActions.enable = true;
        messageLatency.enable = true;
        messageLinkEmbeds.enable = true;
        messageLogger = {
          enable = true;
          ignoreBots = false;
        };
        moreQuickReactions.enable = true;
        mutualGroupDms.enable = true;
        noBlockedMessages.enable = true;
        notificationVolume.enable = true;
        noTrack.enable = true;
        oneko.enable = true;
        permissionsViewer.enable = true;
        petpet.enable = true;
        pictureInPicture.enable = true;
        pinDms = {
          enable = true;
          userBasedCategoryList = {
            "1403502748749795409" = [ ];
          };
        };
        platformIndicators.enable = true;
        previewMessage.enable = true;
        quickMention.enable = true;
        quickReply.enable = true;
        reactErrorDecoder.enable = true;
        readAllNotificationsButton.enable = true;
        relationshipNotifier.enable = true;
        revealAllSpoilers.enable = true;
        reverseImageSearch.enable = true;
        reviewDb.enable = true;
        roleColorEverywhere.enable = true;
        secretRingToneEnabler.enable = true;
        sendTimestamps.enable = true;
        serverInfo.enable = true;
        settings.enable = true;
        shikiCodeblocks.enable = true;
        showAllMessageButtons.enable = true;
        showConnections.enable = true;
        showHiddenChannels.enable = true;
        showHiddenThings.enable = true;
        showTimeoutDuration.enable = true;
        silentMessageToggle.enable = true;
        silentTyping.enable = true;
        sortFriendRequests.enable = true;
        spotifyControls.enable = true;
        spotifyCrack.enable = true;
        spotifyShareCommands.enable = true;
        startupTimings.enable = true;
        stickerPaste.enable = true;
        streamerModeOnStream.enable = true;
        superReactionTweaks.enable = true;
        supportHelper.enable = true;
        typingIndicator.enable = true;
        typingTweaks.enable = true;
        userMessagesPronouns.enable = true;
        userVoiceShow.enable = true;
        usrbg.enable = true;
        validReply.enable = true;
        validUser.enable = true;
        vcNarrator.enable = true;
        vencordToolbox.enable = true;
        viewRaw.enable = true;
        voiceDownload.enable = true;
        voiceMessages.enable = true;
        volumeBooster.enable = true;
        webContextMenus.enable = true;
        webKeybinds.enable = true;
        webScreenShareFixes.enable = true;
        whoReacted.enable = true;
        youtubeAdblock.enable = true;
      };
    };

    extraConfig.plugins = {
      CtrlEnterSend = {
        enable = true;
        submitRule = "ctrl+enter";
      };
    };
  };

  environment.systemPackages = common.packages.installed;

  system.activation.scripts = {
    nixcord-prepareHome = {
      deps = [ "users" ];
      text = ''
        install -d -o ${cfg.user} -g ${config.users.users.${cfg.user}.group} -m 0700 ${homeDir}/.config
        chown -R ${cfg.user}:${config.users.users.${cfg.user}.group} ${homeDir}/.config
      '';
    };

    nixcord-disableDiscordUpdates = {
      deps = [
        "users"
        "nixcord-prepareHome"
      ];
      text = activationScripts.disableDiscordUpdates;
    };

    nixcord-fixDiscordModules = {
      deps = [
        "users"
        "nixcord-prepareHome"
      ];
      text = activationScripts.fixDiscordModules;
    };

    nixcord-writeFiles = {
      deps = [
        "users"
        "nixcord-prepareHome"
      ];
      text = ''
        (
          set -eu
          target_user=${lib.escapeShellArg cfg.user}
          target_group="$(${pkgs.coreutils}/bin/id -gn "$target_user")"

          copy_file() {
            local src="$1"
            local dest="$2"
            local mode="''${3:-0644}"
            ${install} -D -m "$mode" -o "$target_user" -g "$target_group" "$src" "$dest"
          }

          ${common.fileCopyCommands "copy_file"}
        )
      '';
    };
  };
}
