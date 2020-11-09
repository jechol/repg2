let
  nixpkgs = import (fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/20.09.tar.gz";
    sha256 = "1wg61h4gndm3vcprdcg7rc4s1v3jkm5xd7lw8r2f67w502y94gcy";
  }) { };
  beam = import (fetchTarball {
    url = "https://github.com/jechol/nix-beam/archive/v5.0.tar.gz";
    sha256 = "1sp0zi18pc2h5ckdj70incwai03s8dbqpzpd8r7r0c81dcixahcj";
  }) { };
in nixpkgs.mkShell {
  buildInputs = [
    beam.erlang.v21_0
    beam.pkg.v21_0.elixir.v1_8_0
    beam.pkg.v21_0.rebar3
    beam.pkg.v21_0.rebar
  ];
}
