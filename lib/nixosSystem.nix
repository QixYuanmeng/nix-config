{
  inputs,
  lib,
  system,
  genSpecialArgs,
  nixos-modules,
  home-modules ? [],
  specialArgs ? (genSpecialArgs system),
  myvars,
  ...
}: let
  inherit (inputs) nixpkgs home-manager nixos-generators;
in
  nixpkgs.lib.nixosSystem {
    inherit system specialArgs;
    modules =
    [
        inputs.daeuniverse.nixosModules.dae
        inputs.daeuniverse.nixosModules.daed
        {
            environment.systemPackages =
    with inputs.daeuniverse.packages.x86_64-linux;
      [ dae daed ];
        }
      ] ++
    [
            { nixpkgs.overlays = [ inputs.nur.overlay ]; }
       inputs.nur.nixosModules.nur
    ] ++
      nixos-modules
      ++ [
        nixos-generators.nixosModules.all-formats
      ]
      ++ (
        lib.optionals ((lib.lists.length home-modules) > 0)
        [
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            home-manager.extraSpecialArgs = specialArgs;
            home-manager.users."${myvars.username}".imports = home-modules;
          }
        ]
      );
  }
