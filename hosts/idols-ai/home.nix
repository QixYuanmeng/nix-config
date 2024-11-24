{
  modules.desktop = {
    hyprland = {
      nvidia = false;
    };
  };
  modules.editors.emacs = {
    enable = true;
  };

  programs.ssh = {
    enable = true;
    extraConfig = ''
      Host github.com
          IdentityFile ~/.ssh/idols-ai
          # Specifies that ssh should only use the identity file explicitly configured above
          # required to prevent sending default identity files first.
          IdentitiesOnly yes
    '';
  };
}
