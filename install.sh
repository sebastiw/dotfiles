#!/bin/bash

# Prerequisites:
# sudo, git, chsh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Which Linux?
. /etc/lsb-release

tmp=`mktemp`
curr=`pwd`

cd $tmp

if [[ "Ubuntu" = "$DISTRIB_ID" ]]
then
  PKGMGR="APT"

  get_random_packages_apt
  setup_android-mobile_apt

  git_emacs
  git_erlang
fi

if [[ "Arch" = "$DISTRIB_ID" ]]
then
  PKGMGR="PACMAN"

  get_random_packages_pacman

fi

cd $curr


function check_n_link {
  FILENAME=$1
  [[ -z "$FILENAME" ]] && fail2 "link file! No filename specified."

  [[ ! -a "~/$FILENAME" ]] && ln -s ~/$SCRIPT_DIR/$FILENAME ~/$FILENAME
}

function fail2 {
  printf "ERROR: Failed to %s\n", $1
  exit 1
}


function get_random_packages_apt {
  # Browsers
  sudo apt-get install firefox chromium-browser

  # Shell
  sudo apt-get install zsh
  check_n_link .zshrc
  check_n_link .bashrc
  chsh -s /bin/zsh

  # Vpn
  sudo apt-get install openvpn openssh
  mkdir -p -m 600 ~/private
  check_n_link private/openvpn.conf

  # Cloud etc
  sudo apt-get install docker awscli s3cmd

  git clone git@github.com:kubernetes/kubernetes.git || fail2 "clone Kubernetes"
  cd kubernetes
  make quick-release || fail2 "make kubernetes"
  mkdir -p ~/bin
  mv ./_output/release-stage/client/linux-amd64/kubernetes/client/bin/kubectl ~/bin/
  cd ..
}

function get_random_packages_pacman {
  git clone https://aur.archlinux.org/kubectl-bin.git || fail2 "clone kubectl"
  cd kubectl-bin

  cd ..
}


function setup_android-mobile_apt {
  sudo apt-get install libmtp-dev mtpfs
  VENDORID="${1:18d1}" # OP2
  PRODUCTID="${2:d00d}" # OP2
  echo 'ATTR{idVendor}=="${VENDORID}", ATTR{idProduct}=="${PRODUCTID}", SYMLINK+="libmtp-%k", MODE="660", GROUP="audio", ENV{ID_MTP_DEVICE}="1", ENV{ID_MEDIA_PLAYER}="1", TAG+="uaccess"' | sudo tee /etc/udev/rules.d/69-libmtp.rules
  echo 'SUBSYSTEM=="usb", ATTR{idVendor}=="${VENDORID}", ATTR{idProduct}=="${PRODUCTID}", MODE="0666"' | sudo tee /etc/udev/rules.d/51-android.rules
  sudo service udev restart
}


function emacs_pre_install_apt {
  sudo apt-get install libgtk-3-dev libwebkitgtk-3.0-dev
}

function git_emacs {
  VERSION=${1:25.2}

  test "APT" == "$PKGMGR" && emacs_pre_install_apt
  test "PACMAN" = "$PKGMGR" && emacs_pre_install_pacman

  sudo mkdir -p /opt/emacs/${VERSION}

  git clone git@github.com:emacs-mirror/emacs.git || fail2 "clone Emacs"
  cd emacs

  ./configure --with-cairo --with-xwidgets --with-x-toolkit=gtk3\
              --prefix=/opt/emacs/${VERSION} || fail2 "configure emacs"

  make || fail2 "make emacs"
  sudo make install || fail2 "install emacs"
  cd ..
}



function emacs_pre_install_apt {
  sudo apt-get install openssl libssl-dev
}

function git_erlang {
  VERSION=${1:19.3.6}

  test "APT" == "$PKGMGR" && erlang_pre_install_apt
  test "PACMAN" = "$PKGMGR" && erlang_pre_install_pacman

  git clone git@github.com:erlang/otp.git || fail2 "clone Erlang"

  cd otp
  ERL_TOP=`pwd`

  ./otp_build autoconf || fail2 "generate config for Erlang"

  mkdir -p /opt/erlang/${VERSION}

  # ./configure --prefix=/opt/erlang/${VERSION} || fail2 "configure Erlang"
  ./configure --prefix=/opt/erlang/${VERSION}/\
#             TODO: .openssl might be needed for Arch.
# $ ls -l ~/.openssl-1.0/
# lrwxrwxrwx  1 seba seba   24 jun  5 16:21 include -> /usr/include/openssl-1.0
# lrwxrwxrwx  1 seba seba   20 jun  5 16:21 lib -> /usr/lib/openssl-1.0
#              --with-ssl=${HOME}/.openssl-1.0\
              --enable-builtin-zlib || fail2 "configure Erlang"

  make || fail2 "make Erlang"
  make install || fail2 "install Erlang"

  export PATH=$ERL_TOP/bin:$PATH
  export FOP_HOME=$(dirname $(which fop))

  make docs || fail2 "make docs for Erlang"
  sudo make install-docs || fail2 "install docs for Erlang"
  cd ..

  # Rebar3
  git clone git@github.com:erlang/rebar3.git || fail2 "clone Rebar3"
  cd rebar3
  ./bootstrap || fail2 "bootstrap Rebar3"
  cd ..
}


function get_clojure {
  sudo apt install openjdk-8-jre clojure

  wget https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein || fail2 "download Leiningen."
  chmod a+x lein
  mkdir -p ~/bin
  mv lein ~/bin/
}
