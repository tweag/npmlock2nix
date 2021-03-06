{ lib, npmlock2nix, testLib }:
let
  inherit (testLib) noGithubHashes;
  i = npmlock2nix.internal;
in
(testLib.runTests {
  testTurnsGitHubRefsToStorePaths = {
    expr =
      let
        leftpad = (npmlock2nix.internal.patchPackagefile noGithubHashes ./examples-projects/github-dependency/package.json).dependencies.leftpad;
      in
      lib.hasPrefix ("file://" + builtins.storeDir) leftpad;
    expected = true;
  };
  testHandlesDevDependencies = {
    expr =
      let
        leftpad = (npmlock2nix.internal.patchPackagefile noGithubHashes ./examples-projects/github-dev-dependency/package.json).devDependencies.leftpad;
      in
      lib.hasPrefix ("file://" + builtins.storeDir) leftpad;
    expected = true;
  };
})
