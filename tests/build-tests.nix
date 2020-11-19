{ lib, symlinkJoin, npmlock2nix, runCommand, libwebp }:
let
  symlinkAttrs = attrs: runCommand "symlink-attrs"
    { }
    (
      let
        drvs = lib.attrValues (lib.mapAttrs (name: drv: { inherit name drv; }) attrs);
      in
      ''
          mkdir $out
        ${lib.concatMapStringsSep "\n" (o: "ln -s ${o.drv} $out/${o.name}") drvs}
      ''
    );
in
symlinkAttrs {
  webpack-cli-project-default-build-command = npmlock2nix.build {
    src = ./examples-projects/webpack-cli-project;
    installPhase = ''
      cp -r dist $out
    '';
  };

  webpack-cli-project-custom-build-command = npmlock2nix.build {
    src = ./examples-projects/webpack-cli-project;
    buildCommands = [ "webpack --mode=production" ];
    installPhase = ''
      cp -r dist $out
    '';
  };

  node-modules-attributes-are-passed-through = npmlock2nix.build {
    src = ./examples-projects/bin-wrapped-dep;
    buildCommands = [
      ''
        readlink -f $(node -e "console.log(require('cwebp-bin'))") > actual
        echo ${libwebp}/bin/cwebp > expected
      ''
    ];
    installPhase = ''
      cp actual $out
    '';

    doCheck = true;
    checkPhase = ''
      cmp actual expected || exit 1
    '';

    node_modules_attrs = {
      preInstallLinks = {
        "cwebp-bin"."vendor/cwebp" = "${libwebp}/bin/cwebp";
      };
    };
  };

  build-yarn-node-modules = npmlock2nix.internal.yarn.node_modules {
    src = ./examples-projects/simple-yarn-project;
  };

  build-yarn-webpack-cli =
    let
      nm = npmlock2nix.internal.yarn.node_modules {
        src = ./examples-projects/webpack-cli-project;
      };
    in
    npmlock2nix.build {
      src = ./examples-projects/webpack-cli-project;
      node_modules = nm;
      installPhase = ''
        cp -r dist $out
      '';
    };

  # build-yarn-node-modules-concourse = npmlock2nix.internal.yarn.node_modules {
  #   src = ./examples-projects/simple-yarn-project;
  #   yarnLockFile = ./concourse-yarn.lock;
  # };

}
