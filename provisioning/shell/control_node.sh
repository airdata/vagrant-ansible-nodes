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
    sudo yum upgrade -y
    sudo yum install -y yum-utils yum-presto wget openssl curl mlocate epel-release device-mapper-persistent-data lvm2 vim net-tools python3 python3-pip python3-devel openssl-devel python3-libselinux gcc
    sudo update-alternatives --install /usr/bin/python python /usr/bin/python2 50
    sudo update-alternatives --install /usr/bin/python python /usr/bin/python3.6 60
    sudo sed -e '1s/.*/#!\/usr\/bin\/python2/g' -i /usr/bin/yum
    sudo sed -e '1s/.*/#!\/usr\/bin\/python2/g' -i /usr/libexec/urlgrabber-ext-down
    sudo sed -e '1s/.*/#!\/usr\/bin\/python2 -tt/g' -i /bin/yum-config-manager
    # Install Docker-ce git, docker-compose and ansible
    sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    sudo yum install -y docker-ce ansible git
    sudo systemctl start docker
    INFO "Docker is started"
    sudo systemctl enable docker
    sudo groupadd docker
    sudo usermod -aG docker vagrant
    curl -L "https://github.com/docker/compose/releases/download/1.25.3/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
    # Install molecule and ansible-cmdb
    export PATH="/usr/local/bin:$PATH"
    sudo python3 -m pip install --upgrade pip
    sudo python3 -m pip install --upgrade setuptools wheel setuptools_rust ansible-cmdb
    sudo python3 -m pip install "molecule[docker]"
    # Download and Install Jenkins and Java
    sudo mkdir -m 777 /var/jenkins_home
    docker run -d --name jenkins -p 8080:8080 -p 50000:50000 -v /var/run/docker.sock:/var/run/docker.sock -v /var/jenkins_home/:/var/jenkins_home jenkins/jenkins:lts
    sleep 60
    echo "Jenkins password: $(docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword)"
}

if platform_supported; then
    chmod_ssh && \
    install_all && \
    add_ansible_nodes
fi