#!/usr/bin/env bash

# this script installs ansible control node

ANSIBLE_PACKAGE="ansible"
GIT_PACKAGE="git"
EPEL_REPO_PACKAGE="epel-release"
PLATFORM_RELEASE_FILE="/etc/redhat-release"
ANSIBLE_HOSTS_FILE="/etc/ansible/hosts"
ANSIBLE_NODES=("$@")

function platform_supported() {
    [ -f "$PLATFORM_RELEASE_FILE" ] && \
    echo "Platform supported" || \
    (echo "Platform is not supported. Exiting..."; exit 1)
}

function enable_epel_repo() {
    check_installed "$EPEL_REPO_PACKAGE"
    if [ "$?" -eq 1 ]; then
        echo "$EPEL_REPO_PACKAGE is not enabled"
        install_package "$EPEL_REPO_PACKAGE"
    fi
}

function install_ansible() {
    check_installed "$ANSIBLE_PACKAGE"
    if [ "$?" -eq 1 ]; then
        echo "$ANSIBLE_PACKAGE is not installed"
        install_package "$ANSIBLE_PACKAGE"
    fi
}

function install_git() {
    check_installed "$GIT_PACKAGE"
    if [ "$?" -eq 1 ]; then
        echo "$GIT_PACKAGE is not installed"
        install_package "$GIT_PACKAGE"
    fi
}

function check_installed() {
    yum list installed "$@"
}

function install_package() {
    yum install "$@" -y
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
    sudo yum install -y yum-utils device-mapper-persistent-data lvm2
    # Configure docker repository
    sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    # Install Docker-ce
    sudo yum install -y docker-ce
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

if platform_supported; then
    enable_epel_repo && \
    install_ansible && \
    install_git && \
    add_ansible_nodes && \
    chmod_ssh && \
    install_docker
fi