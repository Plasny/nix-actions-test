{
	description	=	"test	project";

	inputs = {
		nixpkgs.url	=	"github:NixOS/nixpkgs";
		flake-utils.url	=	"github:numtide/flake-utils";
	};

	outputs	=	{	self,	nixpkgs, flake-utils }:
		flake-utils.lib.eachDefaultSystem	(system:
			let
				pkgs = nixpkgs.legacyPackages.${system};
				ci-code-format = pkgs.writeScriptBin "code-format" ''
					echo "-> clang-format	code formatting"
					clang-format --style=microsoft -i	src/*.c
				'';
				ci-code-run	=	pkgs.writeScriptBin	"code-run" ''
					#	change in	future to	nix	build	and	nix	run	:D
					v	run	src/main.v
				'';
				ci-code-build	=	pkgs.writeScriptBin	"code-build" ''
					#	change in	future to	nix	build	and	nix	run	:D
					echo "-> build code for windows and linux"
					v -os windows -o app-windows.exe src/
					v -os linux -o app-linux src/
				'';
				ci-code-update = pkgs.writeScriptBin "github-code-update"	''
					echo "-> push	changed	code to	git"
					git	config --global	user.name	'Plasny'
					git	config --global	user.email 'git.plasny.uq95y@slmail.me'
					git	remote set-url origin	https://x-access-token:$\{{	secrets.GITHUB_TOKEN }}@github.com/$\{{	github.repository	}}
					git	commit -am "Auto update	for	$(git	log	-n 1 --pretty=format:"%h")"
					git	push
				'';
				ci-release = pkgs.writeScriptBin "github-release" ''
					echo "-> release packages on github"
					export GH_TOKEN="$\{{ secrets.GITHUB_TOKEN }}"
					gh release create \
						-F changelog.md \
						app-windows.exe app-linux
				'';
			in {
				devShells	=	{
					default	=	pkgs.mkShell {
						buildInputs	=	[
							ci-code-format
							ci-code-run
							ci-code-build
							ci-code-update
							ci-release ]	++ (with pkgs; [
							# git and github stuff
							git
							gh

							# packages needed for c code formatting
							clang

							# packages needed for v code compilation
							gcc
							pkgsCross.mingwW64.buildPackages.gcc
							vlang
							libatomic_ops
							openssl
						]);
						shellHook = ''
							echo -e "\e[32;1mVLANG TEST PROJECT\e[0m"
						'';
					};
				};

			}
		);

}
