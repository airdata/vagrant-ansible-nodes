#!/usr/bin/env bash

# this script installs ansible control node

INFO(){
    /bin/echo -e "\e[48;5;215m[INFO -->]\e[49m\e[39m $@"
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

function install_all() {
    INFO "Upgrade and Install packages"
    # Install required packages
    yum install -y yum-utils yum-presto wget openssl openssl-devel epel-release gcc curl mlocate device-mapper-persistent-data lvm2 vim net-tools python3 python3-pip python3-devel python3-libselinux python3-setuptools

    # Setup python3 as default
    update-alternatives --install /usr/bin/python python /usr/bin/python2 50
    update-alternatives --install /usr/bin/python python /usr/bin/python3.6 60

    # Fix yum and python path
    sed -e '1s/.*/#!\/usr\/bin\/python2/g' -i /usr/bin/yum
    sed -e '1s/.*/#!\/usr\/bin\/python2/g' -i /usr/libexec/urlgrabber-ext-down
    sed -e '1s/.*/#!\/usr\/bin\/python2 -tt/g' -i /bin/yum-config-manager
    echo "export PATH=/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin">> /etc/environment
    source /etc/environment

    # Install docker git, docker-compose and ansible
    INFO "Install Docker, Ansible, Java"
    yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    yum install -y docker-ce-20.10.22-3.el7.x86_64 ansible-2.9.27 git java-11-openjdk-devel
    systemctl start docker
    systemctl enable docker
    usermod -aG docker vagrant

    # Install molecule and ansible-cmdb
    INFO "Install molecule...."
    python3 -m pip install --upgrade pip wheel setuptools_rust
    python3 -m pip install "molecule[docker]"==3.6.1 ansible-cmdb==v1.31

    # Start Jenkins container
    if [ ! -d "/var/jenkins_home" ]; then
        mkdir -m 777 /var/jenkins_home
        docker run --restart always -d --name jenkins -p 8080:8080 -p 50000:50000 -v /var/run/docker.sock:/var/run/docker.sock -v /var/jenkins_home/:/var/jenkins_home jenkins/jenkins:lts
        INFO "Starting Jenkins...."
    else
        docker restart jenkins
        INFO "Restarting Jenkins...."
    fi
}

if platform_supported; then
    chmod_ssh && \
    install_all && \
    add_ansible_nodes
fi