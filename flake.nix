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
				ci-code-format = pkgs.writeScriptBin "code-format" ''
					echo "-> clang-format code formatting"
					clang-format --style=microsoft -i src/*

					echo "-> editorconfig code formatting"
					eclint fix $(git ls-files)
				'';
				ci-code-update = pkgs.writeScriptBin "code-update" ''
					echo "-> push changed code to git"
					git config --global user.name 'Plasny'
					git config --global user.email 'git.plasny.uq95y@slmail.me'
					git remote set-url origin https://x-access-token:$\{{ secrets.GITHUB_TOKEN }}@github.com/$\{{ github.repository }}
					git commit -am "Auto update for $(git log -n 1 --pretty=format:"%h")"
					git push
				'';
			in {
				devShells = {
					default = pkgs.mkShell {
						buildInputs = [ ci-code-format ci-code-update ] ++ (with pkgs; [
							git

							# packages needed for code formatting
							clang
							eclint
						]);
					};
				};

			}
		);
}
