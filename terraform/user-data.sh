
#!/bin/bash
set -euxo pipefail

exec > /var/log/user-data.log 2>&1

apt-get update
apt-get install -y fontconfig openjdk-21-jre curl wget git docker.io

# Install Jenkins LTS repository
mkdir -p /usr/share/keyrings

curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key \
  -o /usr/share/keyrings/jenkins-keyring.asc

echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" \
  > /etc/apt/sources.list.d/jenkins.list

apt-get update
apt-get install -y jenkins

# Start Docker and Jenkins
systemctl enable --now docker
systemctl enable --now jenkins

# Allow Jenkins to use Docker
usermod -aG docker jenkins
systemctl restart jenkins

# Install AWS CLI v2
curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" \
  -o /tmp/awscliv2.zip

apt-get install -y unzip
unzip -q /tmp/awscliv2.zip -d /tmp
/tmp/aws/install

# Verify services
systemctl status jenkins --no-pager
systemctl status docker --no-pager
