#!/bin/bash
sudo yum update -y
sudo yum install ruby -y
sudo yum install wget -y
sudo yum install amazon-cloudwatch-agent -y
sudo amazon-linux-extras install docker -y
sudo systemctl start docker
sudo usermod -a -G docker ec2-user
sudo chkconfig docker on
sudo yum install -y git
sudo curl -L https://github.com/docker/compose/releases/download/1.23.0/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

readonly REGION="eu-central-1"
readonly SCRIPT_NAME="install"

SCRIPT_URL="https://aws-codedeploy-$REGION.s3.amazonaws.com/latest/install"

cd /tmp
FILE_SIZE=0
MAX_RETRY_COUNT=3
RETRY_COUNT=0

while [ $RETRY_COUNT -lt $MAX_RETRY_COUNT ] ; do
  echo AWS-Ami-Creation: Downloading script from $SCRIPT_URL
  sudo wget "$SCRIPT_URL"
  FILE_SIZE=$(du -k /tmp/$SCRIPT_NAME | cut -f1)
  echo AWS-Ami-Creation: Finished downloading script, size: $FILE_SIZE
  if [ $FILE_SIZE -gt 0 ]; then
    break
  else
    if [[ $RETRY_COUNT -lt MAX_RETRY_COUNT ]]; then
      RETRY_COUNT=$((RETRY_COUNT+1));
      echo AWS-Ami-Creation: FileSize is 0, retryCount: $RETRY_COUNT
    fi
  fi
done

if [ $FILE_SIZE -gt 0 ]; then
  sudo chmod +x "$SCRIPT_NAME"
  echo AWS-Ami-Creation: Running Ami Creation script now ....
  sudo ./"$SCRIPT_NAME" auto
else
  echo AWS-Ami-Creation: Unable to download script, quitting ....
fi

# Download node_exporter and copy utilities to where they should be in the filesystem
#VERSION=0.16.0
VERSION=$(curl https://raw.githubusercontent.com/prometheus/node_exporter/master/VERSION)
wget https://github.com/prometheus/node_exporter/releases/download/v${VERSION}/node_exporter-${VERSION}.linux-amd64.tar.gz
tar xvzf node_exporter-${VERSION}.linux-amd64.tar.gz

sudo cp node_exporter-${VERSION}.linux-amd64/node_exporter /usr/local/bin/
sudo chown root:root /usr/local/bin/node_exporter

# systemd
sudo touch /etc/systemd/system/node_exporter.service
sudo echo "[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=root
Group=root
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
" > /etc/systemd/system/node_exporter.service

sudo systemctl daemon-reload
sudo systemctl enable node_exporter
sudo systemctl start node_exporter

# Installation cleanup
rm node_exporter-${VERSION}.linux-amd64.tar.gz
rm -rf node_exporter-${VERSION}.linux-amd64