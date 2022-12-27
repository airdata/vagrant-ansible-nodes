#!/usr/bin/env bash

# this script installs ansible control node
INFO(){
    /bin/echo -e "\e[104m\e[97m[INFO -->]\e[49m\e[39m $@"
}
OS_RELEASE="/etc/redhat-release"
ANSIBLE_HOSTS_FILE="/etc/ansible/hosts"
ANSIBLE_NODES=("$@")

function platform_supported() {
    [ -f "$OS_RELEASE" ] && \
    INFO "Platform supported" || \
    (INFO "Platform is not supported. Exiting..."; exit 1)
}

function chmod_ssh() {
    INFO "chmod ssh"
    chmod 600 /home/vagrant/.ssh/*
}

function add_ansible_nodes() {
    INFO "Add ansible nodes"
    for node in "${ANSIBLE_NODES[@]}"; do
        grep -q "$node" "$ANSIBLE_HOSTS_FILE" && \
        (echo "$node is already added to $ANSIBLE_HOSTS_FILE"; exit 0) \
        || echo "$node" >> "$ANSIBLE_HOSTS_FILE"
    done
}

# Install ansible, docker, git, jenkins
function install_all() {
    INFO "Upgrade and Install packages"
    # Install required packages
    sudo yum install -y yum-utils yum-presto wget ansible git openssl curl mlocate device-mapper-persistent-data lvm2 vim net-tools openssl-devel gcc
    # Setup python3 as default
    sudo update-alternatives --install /usr/bin/python python /usr/bin/python2 50
    sudo update-alternatives --install /usr/bin/python python /usr/bin/python3.6 60
    # Fix yum and python path
    sudo sed -e '1s/.*/#!\/usr\/bin\/python2/g' -i /usr/bin/yum
    sudo sed -e '1s/.*/#!\/usr\/bin\/python2/g' -i /usr/libexec/urlgrabber-ext-down
    sudo sed -e '1s/.*/#!\/usr\/bin\/python2 -tt/g' -i /bin/yum-config-manager
    echo "export PATH=/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin">> /etc/environment
    source /etc/environment
    # Install molecule and ansible-cmdb
    sudo python3 -m pip install --upgrade pip setuptools wheel setuptools_rust
    sudo python3 -m pip install "molecule[docker]" ansible-cmdb
    # Download and Install Jenkins and Java
    sudo mkdir -m 777 /var/jenkins_home
    docker run -d --name jenkins -p 8080:8080 -p 50000:50000 -v /var/run/docker.sock:/var/run/docker.sock -v /var/jenkins_home/:/var/jenkins_home jenkins/jenkins:lts
    sleep 20
    INFO "Jenkins password: $(docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword)"
}

if platform_supported; then
    chmod_ssh && \
    install_all && \
    add_ansible_nodes
fi