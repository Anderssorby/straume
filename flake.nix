{
  inputs = {
    lean = {
      # url = "github:leanprover/lean4/v4.0.0-m5";
      url = "github:leanprover/lean4";
    };
    yatima-std = {
      url = "github:anderssorby/YatimaStdLib.lean";
      # url = "github:yatima-inc/YatimaStdLib.lean";
      inputs.lean.follows = "lean";
    };

    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-utils = {
      url = "github:numtide/flake-utils";
    };

  };

  outputs = { self, lean, flake-utils, nixpkgs, yatima-std }:
    let
      supportedSystems = [
        "aarch64-linux"
        "aarch64-darwin"
        "i686-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];
    in
    flake-utils.lib.eachSystem supportedSystems (system:
      let
        leanPkgs = lean.packages.${system};
        pkgs = nixpkgs.legacyPackages.${system};
        project = leanPkgs.buildLeanPackage {
          deps = [ yatima-std.project.${system} ];
          debug = false;
          name = "Straume";
          src = ./.;
        };
      in
      {
        inherit project;
        packages = project // {
          default = project.sharedLib;
        };

        devShell = pkgs.mkShell {
          buildInputs = [
            leanPkgs.lean-dev
          ];
        };

        defaultPackage = project;
      });
}
