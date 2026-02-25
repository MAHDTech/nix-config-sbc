{ pkgs, ... }:
{
  imports =
    [
    ];

  environment = {

    systemPackages = with pkgs; [
      vim

      mtr # A network diagnostic tool
      iperf3 # A tool for measuring TCP and UDP bandwidth performance
      nmap # A utility for network discovery and security auditing
      ldns # replacement of dig, it provide the command `drill`
      socat # replacement of openbsd-netcat
      tcpdump # A powerful command-line packet analyzer

      # archives
      zip
      xz
      unzip
      p7zip
      zstd
      gnutar

      # misc
      file
      which
      tree
      gnused
      gawk
      tmux

      # Filesystem tools
      #bcachefs-tools

      # Containers
      docker-client
      docker-compose
    ];

  };

}
