# ~/awakened-poe-trade-flake/flake.nix
{
  description = "A Nix flake for packaging Awakened PoE Trade";

  # --- Входы ---
  # Нашему флейку нужен только nixpkgs, чтобы получить доступ к инструментам
  # для сборки (fetchurl, appimageTools и т.д.).
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  # --- Выходы ---
  # Здесь мы определяем, что наш флейк "производит".
  outputs = { self, nixpkgs }:
    let
      # Мы будем поддерживать только одну систему для простоты.
      system = "x86_64-linux";
      # Получаем доступ к набору пакетов для нашей системы.
      pkgs = nixpkgs.legacyPackages.${system};

      # --- ОПРЕДЕЛЕНИЕ НАШЕГО ПАКЕТА ---
      awakened-poe-trade-pkg = pkgs.appimageTools.wrapType2 {
        # Имя пакета
        pname = "awakened-poe-trade";
        # Версия из оригинального репозитория
        version = "3.26.101";

        # Скачиваем AppImage с GitHub-релиза
        src = pkgs.fetchurl {
          url = "https://github.com/SnosMe/awakened-poe-trade/releases/download/v3.26.101/Awakened-PoE-Trade-3.26.101.AppImage";
          # ВАЖНО: Хеш нужно будет получить. Сначала вставьте сюда фиктивный хеш.
          hash = "sha256-n7xweAHNYQSDQMxZpHEf60PZk62ydwMsW9a7k3QeU1E=";
        };

        # Дополнительная информация о пакете
        meta = with pkgs.lib; {
          description = "Path of Exile trading app for price checking";
          homepage = "https://github.com/SnosMe/awakened-poe-trade";
          license = licenses.mit; # Предположительно MIT, как у многих проектов
          platforms = platforms.linux;
        };
      };

      # Создаем Desktop Item отдельно (хорошая практика)
      desktop-item = pkgs.makeDesktopItem {
        name = "awakened-poe-trade";
        exec = "awakened-poe-trade"; # Имя бинарника будет таким же, как pname
        icon = "awakened-poe-trade"; # Иконку можно добавить позже
        desktopName = "Awakened PoE Trade";
        comment = "Path of Exile trading app for price checking";
        categories = [ "Game" ];
      };

    in
    {
      # --- ПРЕДОСТАВЛЯЕМ ПАКЕТЫ ---
      # Мы "экспортируем" наши пакеты, чтобы другие флейки могли их использовать.
      packages.${system} = {
        # Основной пакет с приложением
        awakened-poe-trade = awakened-poe-trade-pkg;

        # Desktop item как отдельный пакет
        awakened-poe-trade-desktop = desktop-item;

        # Пакет "по умолчанию" для удобства
        default = self.packages.${system}.awakened-poe-trade;
      };

      # --- ПРЕДОСТАВЛЯЕМ OVERLAY ---
      # Это самый удобный способ для других использовать наш пакет.
      overlays.default = final: prev: {
        awakened-poe-trade = self.packages.${system}.awakened-poe-trade;
        awakened-poe-trade-desktop = self.packages.${system}.awakened-poe-trade-desktop;
      };
    };
}
