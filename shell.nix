let
  nixpkgs = import (fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/20.09.tar.gz";
    sha256 = "1wg61h4gndm3vcprdcg7rc4s1v3jkm5xd7lw8r2f67w502y94gcy";
  }) { };
  beam = import (fetchTarball {
    url = "https://github.com/jechol/nix-beam/archive/v5.1.tar.gz";
    sha256 = "0y658cp3p4m0wfsl9a45ah7ydc9vng8a94dlk0icl0ca9pznnlaq";
  }) { };
in nixpkgs.mkShell {
  buildInputs = [
    beam.erlang.v23_0
    beam.pkg.v23_0.elixir.v1_11_0
    beam.pkg.v23_0.rebar3
    beam.pkg.v23_0.rebar

    # build tools required for hex pkgs (ex. libsecp256k1, keccakf1600)
    nixpkgs.libtool
    nixpkgs.autoconf
    nixpkgs.automake
    nixpkgs.gcc
    nixpkgs.darwin.apple_sdk.frameworks.CoreServices
    nixpkgs.gmp6
    nixpkgs.libiconv
  ];
}
