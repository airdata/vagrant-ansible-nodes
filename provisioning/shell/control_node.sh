#!/usr/bin/env bash

# this script installs ansible control node 

PLATFORM_RELEASE_FILE="/etc/redhat-release"
ANSIBLE_HOSTS_FILE="/etc/ansible/hosts"
ANSIBLE_NODES=("$@")

function platform_supported() {
    [ -f "$PLATFORM_RELEASE_FILE" ] && \
    echo "Platform supported" || \
    (echo "Platform is not supported. Exiting..."; exit 1)
}

function chmod_ssh() {
    chmod 600 /home/vagrant/.ssh/*
}

function add_ansible_nodes() {
    for node in "${ANSIBLE_NODES[@]}"; do
        grep -q "$node" "$ANSIBLE_HOSTS_FILE" && \
        (echo "$node is already added to $ANSIBLE_HOSTS_FILE"; exit 0) \
        || echo "$node" >> "$ANSIBLE_HOSTS_FILE"
    done
}
function install_docker () {
    # Remove any old versions
    sudo yum remove docker docker-common docker-selinux docker-engine
    # Install required packages
    sudo yum install -y yum-utils epel-release device-mapper-persistent-data lvm2
    # Configure docker repository
    sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    # Install Docker-ce
    sudo yum install -y docker-ce ansible git
    # Start Docker
    sudo systemctl start docker
    sudo systemctl enable docker
    # Post Installation Steps
    # Create Docker group
    sudo groupadd docker
    # Add user to the docker group
    sudo usermod -aG docker vagrant
    # Install docker-compose
    curl -L "https://github.com/docker/compose/releases/download/1.25.3/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    # Permssion +x execute binary
    chmod +x /usr/local/bin/docker-compose
    # Create link symbolic
    ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
}
function install_jenkins () {
    sudo yum install -y yum-presto wget openssl curl mlocate epel-release
    # Jenkins on CentOS requires Java, but it won't work with the default (GCJ) version of Java. So, let's remove it:
    sudo yum remove -y java*
    # Download and Install Jenkins
    sudo wget --no-check-certificate -O /etc/yum.repos.d/jenkins.repo \
        https://pkg.jenkins.io/redhat-stable/jenkins.repo
    sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
    sudo yum install -y jenkins java-11-openjdk-devel
    sudo systemctl daemon-reload
    # Start Jenkins
    sudo systemctl start jenkins
    # Enable Jenkins to run on Boot
    sudo systemctl enable jenkins
    sudo sed -i 's/<denyAnonymousReadAccess>true/<denyAnonymousReadAccess>false/g' /var/lib/jenkins/config.xml
    sudo sed -i 's/<useSecurity>true/<useSecurity>false/g' /var/lib/jenkins/config.xml
    sudo echo "Jenkins password is: $(cat /var/lib/jenkins/secrets/initialAdminPassword)"
}

if platform_supported; then
    chmod_ssh && \
    install_docker && \
    add_ansible_nodes && \
    install_jenkins
fi