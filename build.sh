#!/bin/bash

# -----------------------------------------------------------------------------
# BUILD/LABEL VARIABLES
# -----------------------------------------------------------------------------
BUILD_DATE=$( date -u +"%Y-%m-%dT%H:%M:%SZ" )
VERSION="latest"
VCS_URL=$( git config --get remote.origin.url )
VCS_REF=$( git rev-parse --short HEAD )

# Install dependencies (debbootstrap)
sudo apt-get install -yqq debootstrap curl

# Fetch the latest Kali debootstrap script from git
curl "https://gitlab.com/kalilinux/packages/debootstrap/raw/kali/master/scripts/kali" > kali-debootstrap && \
  sudo debootstrap --variant=minbase --include=kali-archive-keyring kali-rolling ./kali-root https://http.kali.org/kali ./kali-debootstrap && \
  sudo rm -rf ./kali-root/var/cache/apt/archives/*.deb && \
  sudo tar -C kali-root -c . | sudo docker import - kalilinux/kali-linux-docker && \
  sudo rm -rf ./kali-root && \
  TAG=$( sudo docker run -t -i kalilinux/kali-linux-docker awk '{print $NF}' /etc/debian_version | sed 's/\r$//' ) && \
  echo "Tagging kali with $TAG" && \
  sudo docker tag kalilinux/kali-linux-docker:$VERSION kalilinux/kali-linux-docker:$TAG && \
  echo "Labeling kali" && \
  sudo docker build \
    --squash \
    --rm \
    -t kalilinux/kali-linux-docker:$VERSION \
    --build-arg BUILD_DATE=$BUILD_DATE \
    --build-arg VERSION=$VERSION \
    --build-arg VCS_URL=$VCS_URL \
    --build-arg VCS_REF=$VCS_REF .
  && echo "Build OK" \
  || echo "Build failed!"
