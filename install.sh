#!/bin/bash

set -e

main() {
  if [ -z "$OTP_VERSION" ]; then
    echo "Please set at least OTP_VERSION environment variable!"
    echo
    echo "Usage: install.sh"
    echo
    echo "Supported environment variables:"
    echo
    echo " - OTP_VERSION"
    echo " - ELIXIR_VERSION"
    exit 1
  fi

  TMPDIR="${TMPDIR:=/tmp}/beamup-install"
  mkdir -p $TMPDIR

  cd $TMPDIR
  install_otp $OTP_VERSION

  if [ -n "${ELIXIR_VERSION}" ]; then
    cd $TMPDIR
    install_elixir ${ELIXIR_VERSION}
  fi

  echo
  echo "Installation complete!"
  echo
  echo "Add this directory to your PATH:"
  echo
  echo "    export PATH=$root/bin:\$PATH"
  echo
}

install_otp() {
  version=$1
  release=otp-${version}-$(uname -sm | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
  url=https://github.com/wojtekmach/otp_releases/releases/download/OTP-$version/$release.tar.gz
  echo ">> downloading $url"
  curl --fail -LO $url
  tar xzf $release.tar.gz

  root=$HOME/.local/share/beamup
  otp_root=$root/installs/otp

  echo ">> installing to $otp_root/$version"
  rm -rf $otp_root/$version
  mkdir -p $otp_root
  mv $release $otp_root/$version
  cd $otp_root/$version
  ./Install -sasl $PWD

  mkdir -p $root/bin
  ln -fs $otp_root/$version/bin/* $root/bin
}

install_elixir() {
  version=$1
  url=https://github.com/elixir-lang/elixir/releases/download/v$version/Precompiled.zip
  echo ">> downloading $url"
  curl --fail -LO $url
  unzip -q -d elixir-$version Precompiled.zip

  root=$HOME/.local/share/beamup
  elixir_root=$root/installs/elixir

  echo ">> installing to $elixir_root/$version"
  rm -rf $elixir_root/$version
  mkdir -p $elixir_root
  mv elixir-$version $elixir_root/$version
  mkdir -p $root/bin
  ln -fs $elixir_root/$version/bin/* $root/bin
}

main
