{
  description = "A program for tracking personal finances";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/24.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    android = {
      url = "github:tadfisher/android-nixpkgs/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, android }:
    let
      system = "x86_64-linux";

      pkgs = nixpkgs.legacyPackages.${system};
      pkgs-unstable = nixpkgs-unstable.legacyPackages.${system};

      flutter = pkgs-unstable.flutterPackages.v3_24;

      android-sdk = android.sdk.${system} (sdkPkgs: with sdkPkgs; [
        cmdline-tools-latest
        emulator
        platform-tools
        system-images-android-34-google-apis-x86-64
        build-tools-30-0-3
        platforms-android-28
        platforms-android-31
        platforms-android-33
        platforms-android-34
      ]);

      ld-library-path = pkgs.lib.makeLibraryPath [ pkgs.sqlite ];
    in
    {
      packages.${system}.default = flutter.buildFlutterApplication {
        pname = "finances";
        version =
          let
            versionMatch = builtins.match ".*version: ([0-9]+\.[0-9]+\.[0-9]+)\n.*" (builtins.readFile ./pubspec.yaml);
          in
          if versionMatch != null && versionMatch != [ ]
          then builtins.head versionMatch
          else throw "Failed to extract version from pubspec.yaml";
        src = ./.;
        autoPubspecLock = ./pubspec.lock;
        extraWrapProgramArgs = "--suffix LD_LIBRARY_PATH : ${ld-library-path}";
      };

      devShells.${system}.default = with pkgs; mkShell {
        packages = [
          android-sdk
          flutter
          jdk17
        ];

        FLUTTER_SDK = flutter;
        JAVA_HOME = jdk17.home;
        LD_LIBRARY_PATH = ld-library-path;

        shellHook = ''
          echo -n 'Setting Flutter config... '
          ${flutter}/bin/flutter config --disable-analytics --jdk-dir ${jdk17} > /dev/null
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
