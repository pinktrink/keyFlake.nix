{
inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  outputs = { self, nixpkgs, ... }: let
    pkgs = nixpkgs.legacyPackages."x86_64-linux";

    inherit (pkgs.lib.lists) filter foldl' elem map drop concatLists toList;
    inherit (pkgs.lib.strings) splitString;
    inherit (pkgs.lib.attrsets) attrValues mapAttrs genAttrs mapAttrsToList;
  in {
    lib.mkKeyFlake = ks: {
      lib.ssh.withComments = xs: cs: filter (x: foldl' (a: c: a && elem c (drop 2 (splitString " " x))) true (toList cs)) xs;
      pubKeys = {
        all = ks;
      } // genAttrs [ "ssh" "nix" "gpg" ] (x: rec {
        keys = mapAttrs (_: system: {
          host = system.host.${x} or [ ];
          users = mapAttrs (_: user: user.${x} or [ ]) system.users;
        }) ks;
        hosts = concatLists (attrValues (mapAttrs (_: v: (v.host or {}).${x} or [ ]) ks));
        users = concatLists (attrValues (mapAttrs (_: v: concatLists (mapAttrsToList (_: v': v'.${x} or [ ]) v.users or {})) ks));
        all = hosts ++ users;
      });
    };
  };
}
