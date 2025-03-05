{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  outputs = { self, nixpkgs, ... }: let
    pkgs = nixpkgs.legacyPackages."x86_64-linux";

    inherit (pkgs.lib.lists) filter foldl' elem map drop concatLists toList;
    inherit (pkgs.lib.strings) splitString;
    inherit (pkgs.lib.attrsets) attrValues mapAttrs;
  in {
    lib.mkKeyFlake = ks: {
      lib.withComments = xs: cs: filter (x: foldl' (a: c: a && elem c (drop 2 (splitString " " x))) true (toList cs)) xs;
      pubKeys = rec {
        keys = ks;
        hosts = concatLists (attrValues (mapAttrs (_: v: v.host or [ ]) ks));
        users = concatLists (attrValues (mapAttrs (_: v: concatLists (attrValues v.users or [ ])) ks));
        all = hosts ++ users;
      };
    };
  };
}
