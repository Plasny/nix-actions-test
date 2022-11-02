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
					clang-format --style=microsoft -i src/*.c
				'';
				ci-code-run = pkgs.writeScriptBin "code-run" ''
					# change in future to nix build and nix run :D
					v run src/main.v
				'';
				ci-code-update = pkgs.writeScriptBin "github-code-update" ''
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
						buildInputs = [ ci-code-format ci-code-run ci-code-update ] ++ (with pkgs; [
							git

							# packages needed for v code compilation
							clang
							vlang
							libatomic_ops
							openssl
						]);
					};
				};

			}
		);
}
