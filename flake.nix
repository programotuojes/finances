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
        version = "0.1.0";
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
        LD_LIBRARY_PATH=ld-library-path;

        shellHook = ''
          ${flutter}/bin/flutter config --disable-analytics --jdk-dir ${jdk17} > /dev/null
          source <(${flutter}/bin/flutter bash-completion)

          export PS1='\[\e[1;93m\][Finances]\[\e[m\] \$ '

          # Avoid crashing when opening file picker
          export XDG_DATA_DIRS=${gtk3}/share/gsettings-schemas/${gtk3.name}:$XDG_DATA_DIRS
        '';
      };
    };
}
