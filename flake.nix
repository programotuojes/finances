{
  description = "A program for tracking personal finances";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    android = {
      url = "github:tadfisher/android-nixpkgs/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, android, ... }:
    let
      system = "x86_64-linux";

      pkgs = nixpkgs.legacyPackages.${system};

      flutter = pkgs.flutter327;

      android-sdk = android.sdk.${system} (sdkPkgs: with sdkPkgs; [
        cmdline-tools-latest
        platform-tools
        build-tools-33-0-1
        platforms-android-32 # sqlite3_flutter_libs
        platforms-android-34 # fc_native_image_resize
        platforms-android-35
      ]);
    in
    {
      devShells.${system}.default = with pkgs; mkShell {
        packages = [
          android-sdk
          flutter
          jdk17
        ];

        buildInputs = [
          gtk3
          pkg-config
        ];

        FLUTTER_SDK = flutter;
        JAVA_HOME = jdk17.home;

        shellHook = ''
          echo -n 'Setting Flutter config... '
          ${flutter}/bin/flutter config --jdk-dir ${jdk17} > /dev/null
          echo ✓

          echo -n 'Fetching pub.dev dependencies... '
          ${flutter}/bin/flutter pub get > /dev/null
          echo ✓

          echo -n 'Generating icon packs... '
          ${flutter}/bin/flutter pub run flutter_iconpicker:generate_packs --packs fontAwesomeIcons,material > /dev/null
          echo ✓

          source <(${flutter}/bin/flutter bash-completion)

          export PS1='\n\e[38;5;38m\w\e[0m \e[1;93m(Finances)\e[0m \$ '

          # Avoid crashing when opening file picker
          export XDG_DATA_DIRS=${gtk3}/share/gsettings-schemas/${gtk3.name}:$XDG_DATA_DIRS
        '';
      };
    };
}
