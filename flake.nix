{
  description = "Flutter project for tracking finances";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/23.11";
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    android.url = "github:tadfisher/android-nixpkgs/stable";
  };

  outputs = { self, nixpkgs, unstable, android }:
    let
      system = "x86_64-linux";

      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      unstable-pkgs = import unstable {
        inherit system;
        config.allowUnfree = true;
      };

      android-sdk = android.sdk.${system} (sdkPkgs: with sdkPkgs; [
        cmdline-tools-latest
        emulator
        platform-tools

        build-tools-33-0-1
        sources-android-33
        platforms-android-33
        system-images-android-34-google-apis-x86-64
      ]);
    in
    {
      devShells.${system}.default = with pkgs; mkShell {
        packages = [
          unstable-pkgs.flutter
          android-sdk
          androidStudioPackages.stable
        ];

        shellHook = ''
          ${unstable-pkgs.flutter}/bin/flutter --disable-analytics > /dev/null
          source <(${unstable-pkgs.flutter}/bin/flutter bash-completion)
          export PS1='\[\e[1;93m\][Finances]\[\e[m\] \$ '
        '';
      };
    };
}
