{
  lib,
  fetchFromGitHub,
  buildGoModule,
  versionCheckHook,
  nix-update-script,
}:

buildGoModule (finalAttrs: {
  pname = "opencode";
  version = "0.1.140";

  src = fetchFromGitHub {
    owner = "sst";
    repo = "opencode";
    tag = "v${finalAttrs.version}";
    hash = "sha256-MNSs1E73wRTBsttHAor+YtkaM64u4A8y9O4RTgkkSDM=";
  };

  sourceRoot = "source/packages/tui";

  vendorHash = "sha256-WunhXuyqirY7RDs49hSOtWE+XgWx2v9zs12SIGLbPTc=";

  doCheck = false;

  ldflags = [
    "-s"
    "-w"
    "-X github.com/sst/opencode/internal/version.Version=${finalAttrs.version}"
  ];

  checkFlags =
    let
      skippedTests = [
        # permission denied
        "TestBashTool_Run"
        "TestSourcegraphTool_Run"
        "TestLsTool_Run"

        # Difference with snapshot
        "TestGetContextFromPaths"
      ];
    in
    [ "-skip=^${lib.concatStringsSep "$|^" skippedTests}$" ];

  nativeCheckInputs = [
    versionCheckHook
  ];
  versionCheckProgramArg = "--version";
  doInstallCheck = true;

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Powerful terminal-based AI assistant providing intelligent coding assistance";
    homepage = "https://github.com/sst/opencode";
    changelog = "https://github.com/sst/opencode/releases/tag/v${finalAttrs.version}";
    mainProgram = "opencode";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [
      zestsystem
    ];
  };
})