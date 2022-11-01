{
  description = "test project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
		flake-utils.lib.eachDefaultSystem (system:
			let
				pkgs = nixpkgs.legacyPackages.${system};
				ci-formatting = pkgs.writeScriptBin "code-formatting" ''
					echo "clang-format code formatting"
					clang-format --style=microsoft -i src/*

					echo "editorconfig code formatting"
					# eclint fix *
				'';
			in {
				devShells = {
					default = pkgs.mkShell {
						buildInputs = [ ci-formatting ] ++ (with pkgs; [
							# packages needed for code formatting
							clang
							eclint
						]);
					};
				};

			}
		);
}
