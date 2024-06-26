{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    haskell-flake.url = "github:srid/haskell-flake";
  };
  outputs = inputs@{ self, nixpkgs, flake-parts, ... }:
    # Edit at least project name
    # container.name can also be changed if you want a container called
    # something different than the project name
    let
      projname = "putio-haskell";
      container = {
        name  = projname;
        tag   = "latest";
      };
    in flake-parts.lib.mkFlake { inherit inputs; } {
      systems = nixpkgs.lib.systems.flakeExposed;
      imports = [ inputs.haskell-flake.flakeModule ];

      perSystem = { self', pkgs, ... }: {

        # Typically, you just want a single project named "default". But
        # multiple projects are also possible, each using different GHC version.
        haskellProjects.default = {
          # The base package set representing a specific GHC version.
          # By default, this is pkgs.haskellPackages.
          # You may also create your own. See https://flakular.in/haskell-flake/package-set
          # basePackages = pkgs.haskellPackages;

          # Extra package information. See https://flakular.in/haskell-flake/dependency
          #
          # Note that local packages are automatically included in `packages`
          # (defined by `defaults.packages` option).
          #
          # packages = {
          #   aeson.source = "1.5.0.0"; # Hackage version override
          #   shower.source = inputs.shower;
          # };
          # settings = {
          #   aeson = {
          #     check = false;
          #   };
          #   relude = {
          #     haddock = false;
          #     broken = false;
          #   };
          # };

          devShell = {
           # Enabled by default
           enable = true;

           # Programs you want to make available in the shell.
           # Default programs can be disabled by setting to 'null'
           # tools = hp: { fourmolu = hp.fourmolu; ghcid = null; };
           tools = hp: {
            inherit (pkgs)
              ghc
              haskell-language-server
            ;
           };

           hlsCheck.enable = true;
          };
        };

        # single layer container image
        #packages.container = pkgs.dockerTools.buildImage {
        #  name = container.name;
        #  tag = container.tag;
        #  created = "now";
        #  copyToRoot = [ self'.packages.${projname} ];
        #  config = {
        #    Cmd = [ "${self'.packages.${projname}}/bin/${projname}" ];
        #  };
        #};

        # layered container image
        #packages.container = pkgs.dockerTools.buildLayeredImage {
        #  name = container.name;
        #  tag = container.tag;
        #  created = "now";
        #  contents = [ self'.packages.${projname} ];
        #  config = {
        #    Cmd = [ "${self'.packages.${projname}}/bin/${projname}" ];
        #  };
        #};

        # haskell-flake doesn't set the default package, but you can do it here.
        packages.default = self'.packages.${projname};
      };
    };
}
