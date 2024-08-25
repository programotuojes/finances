{
  description = "A program for tracking personal finances";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/24.05";
    android = {
      url = "github:tadfisher/android-nixpkgs/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, android }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      flutter = pkgs.flutter319;
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
    in
    {
      packages.${system}.default = with pkgs; flutter.buildFlutterApplication {
        pname = "finances";
        version = "0.1.0";
        src = ./.;
        autoPubspecLock = ./pubspec.lock;
        extraWrapProgramArgs = "--suffix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ sqlite ]}";
      };

      devShells.${system}.default = with pkgs; mkShell {
        packages = [
          android-sdk
          flutter
        ];

        FLUTTER_SDK = flutter;

        shellHook = ''
          ${flutter}/bin/flutter --disable-analytics > /dev/null
          source <(${flutter}/bin/flutter bash-completion)
          export PS1='\[\e[1;93m\][Finances]\[\e[m\] \$ '

          # Avoid crashing when opening file picker
          export XDG_DATA_DIRS=${gtk3}/share/gsettings-schemas/${gtk3.name}:$XDG_DATA_DIRS
          export LD_LIBRARY_PATH=${lib.makeLibraryPath [ sqlite ]}:$LD_LIBRARY_PATH
        '';
      };
    };
}
