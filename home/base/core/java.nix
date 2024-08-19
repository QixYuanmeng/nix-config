{ pkgs, ... }:

let
  additionalJDKs = with pkgs; [ jdk17 jdk8 jdk22 ];
in
{
  # ...
  programs.java = { /*...*/ };

  home.sessionPath = [ "$HOME/.jdks" ];
  home.file = (builtins.listToAttrs (builtins.map (jdk: {
    name = ".java/${jdk.version}";
    value = { source = jdk; };
  }) additionalJDKs));
}