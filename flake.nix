{
  description = "A Nix flake for packaging Awakened PoE Trade";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      lib = nixpkgs.lib;

      awakened-poe-trade-pkg = pkgs.appimageTools.wrapType2 {
        pname = "awakened-poe-trade";
        version = "3.26.101";
        src = pkgs.fetchurl {
          url = "https://github.com/SnosMe/awakened-poe-trade/releases/download/v3.26.101/Awakened-PoE-Trade-3.26.101.AppImage";
          hash = "sha256-n7xweAHNYQSDQMxZpHEf60PZk62ydwMsW9a7k3QeU1E=";
        };
        meta = with pkgs.lib; {
          description = "Path of Exile trading app for price checking";
          homepage = "https://github.com/SnosMe/awakened-poe-trade";
          license = licenses.mit;
          platforms = platforms.linux;
        };
      };

      desktop-item = pkgs.makeDesktopItem {
        name = "awakened-poe-trade";
        exec = "awakened-poe-trade";
        icon = "awakened-poe-trade";
        desktopName = "Awakened PoE Trade";
        comment = "Path of Exile trading app for price checking";
        categories = [ "Game" ];
      };

    in
    {
      packages.${system} = {
        awakened-poe-trade = awakened-poe-trade-pkg;
        awakened-poe-trade-desktop = desktop-item;
        default = self.packages.${system}.awakened-poe-trade;
      };

      overlays.default = final: prev: {
        awakened-poe-trade = self.packages.${system}.awakened-poe-trade;
        awakened-poe-trade-desktop = self.packages.${system}.awakened-poe-trade-desktop;
      };

      homeManagerModules.default = { config, ... }:
        let
          cfg = config.programs.awakened-poe-trade;
        in
        {
          options.programs.awakened-poe-trade = {
            enable = lib.mkEnableOption "Awakened PoE Trade";

            desktop = {
              enable = lib.mkOption {
                type = lib.types.bool;
                default = true;
                description = "Whether to install the .desktop file for application launchers.";
              };
            };
          };

          config = lib.mkIf cfg.enable {
            home.packages =
              [
                self.packages.${system}.awakened-poe-trade
              ]
              ++ (lib.optionals cfg.desktop.enable [ self.packages.${system}.awakened-poe-trade-desktop ]);
          };
        };
    };
}
