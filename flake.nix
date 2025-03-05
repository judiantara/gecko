{
  description = "Replace LiveCD Installer SSH keys";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-24.11";
    };
  };

  outputs = {self, nixpkgs, ... }@inputs: let
    system    = "x86_64-linux";
    pkgs      = import nixpkgs { inherit system; };
    
  in {
    devShells.${system}.restore-ssh-keys = pkgs.mkShell {
      packages = with pkgs; [
        rage
      ];
      shellHook = ''
      set -euo pipefail
      if (( $EUID != 0 )); then
       echo "Please run as root"
       exit 1
      fi
      echo "Replacing LiveCD SSH Keys..."
      rm -rf $HOME/.ssh
      ${pkgs.rage}/bin/rage -d -i ''$GECKO_DIR/gecko.key ''$GECKO_DIR/user/''$USERNAME.tar.age | tar --no-same-owner -xvC ''$HOME
      rm -f /etc/ssh/ssh_host*
      ${pkgs.rage}/bin/rage -d -i ''$HOME/.ssh/id_ed25519 ''$GECKO_DIR/machine/''$HOSTNAME.tar.age | tar --no-same-owner -xvC /
      systemctl restart sshd
      echo "Done!"
      exit
      '';
    };
  };
}
