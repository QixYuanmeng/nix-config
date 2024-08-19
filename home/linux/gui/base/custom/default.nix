{pkgs, pkgs-unstable, ... }:
{
  wechat-universal-bwrap = pkgs.callPackage ./wechat-universal-bwrap { };
}