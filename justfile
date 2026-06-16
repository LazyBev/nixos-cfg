check:
	nix flake check

flakeupd:
	nix flake update

upgrade host:
	doas nixos-rebuild switch --flake .#{{host}} -j$(( $(nproc) / 2 ))

gc:
	doas nix-collect-garbage --delete-older-than 30d

lint:
	nix flake check

clean:
	doas nix-collect-garbage -d
	nix-collect-garbage -d

sysupd host:
	nix flake update && doas nixos-rebuild switch --flake .#{{host}} -j$(( $(nproc) / 2 ))

gitwho name email:
	git config --global user.name "{{name}}"
	git config --global user.email "{{email}}"

gp msg:
	git add .
	git commit -m "{{msg}}"
	git push

install host:
	cfdisk /dev/nvme0n1 && \
	wipefs -a /dev/nvme0n1 && \
	sgdisk --zap-all /dev/nvme0n1 && \
	partprobe /dev/nvme0n1 && sleep 2 && \
	wipefs -a /dev/nvme0n1p* 2>/dev/null; \
	nix --experimental-features "nix-command flakes" run github:nix-community/disko -- \
	  --mode disko \
	  --flake .#{{host}} && \
	nixos-install --root /mnt --max-jobs 4 --flake .#{{host}}

devenv-shell:
	devenv shell

devenv-test:
	devenv test

devenv-update:
	devenv update

devenv-gc:
	devenv gc

search query:
	nix search nixpkgs {{query}}

search-options query:
	nix-instantiate --eval -E "(import <nixpkgs/nixos> {}).options" | grep -i {{query}}
