{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/22.05";
    flake-utils.url = "github:numtide/flake-utils";
    nix-proto = { url = "github:notalltim/nix-proto"; };
    upstream-apis.url = "github:notalltim/upstream-apis";

    upstream-apis.inputs.nix-proto.follows = "nix-proto";
    upstream-apis.inputs.nixpkgs.follows = "nixpkgs";
    nix-proto.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = { self, nixpkgs, flake-utils, nix-proto, upstream-apis, ... }@inputs:
    let
      meta = nix-proto.generateMeta {
        name = "test_proto";
        dir = ./proto;
        version = "1.0.0";
        protoDeps = [ upstream-apis.meta ];
      };

      meta_teser = nix-proto.generateMeta {
        name = "tester";
        dir = ./proto;
        version = "1.0.0";
        protoDeps = [ meta ];
      };
      overlays = upstream-apis.overlays ++ nix-proto.generateOverlays { metas = [ meta meta_teser ]; };
    in
    { inherit overlays; } // flake-utils.lib.eachDefaultSystem (system: rec
    {
      legacyPackages = import nixpkgs { inherit system; inherit overlays; };
    });
}
