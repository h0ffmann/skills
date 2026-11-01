{
  description = "Agent skills tailored to the owner's projects, and the README drawing";

  # Only the Nix library: the drawing is pure Nix and needs no packages.
  inputs.nixpkgs-lib.url = "github:nix-community/nixpkgs.lib";

  outputs = { nixpkgs-lib, ... }: {
    # The README drawing, 技: `svg`, `desmos`, `checkSvg` and `failures` (`just drawing`).
    drawing = import ./drawings { inherit (nixpkgs-lib) lib; };
  };
}
