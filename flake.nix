{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-23.11";
    flake-utils.url = "github:numtide/flake-utils";
    nix-proto = {url = "github:notalltim/nix-proto";};

    upstream-apis.url = "github:notalltim/upstream-apis";
    upstream-apis.inputs.nix-proto.follows = "nix-proto";
    upstream-apis.inputs.nixpkgs.follows = "nixpkgs";
    nix-proto.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = {
    self,
    nixpkgs,
    flake-utils,
    nix-proto,
    upstream-apis,
    ...
  } @ inputs: let
    overlays =
      upstream-apis.overlays
      // nix-proto.generateOverlays' {
        test_proto = {upstream}:
          nix-proto.mkProtoDerivation {
            name = "test_proto";
            src = nix-proto.lib.srcFromNamespace {
              root = ./proto;
              namespace = "test_proto";
            };
            version = "1.0.0";
            protoDeps = [upstream];
          };

        tester = {
          upstream,
          test_proto,
        }:
          nix-proto.mkProtoDerivation {
            name = "tester";
            src = nix-proto.lib.srcFromNamespace {
              root = ./proto;
              namespace = "tester";
            };
            version = "1.0.0";
            protoDeps = [upstream test_proto];
          };
      };
  in
    {inherit overlays;}
    // flake-utils.lib.eachDefaultSystem (system: rec
      {
        legacyPackages = import nixpkgs {
          inherit system;
          overlays = nix-proto.lib.overlayToList overlays;
        };
      });
}
