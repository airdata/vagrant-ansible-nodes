#!/usr/bin/env bash

# this script installs ansible control node
INFO(){
    /bin/echo -e "\e[104m\e[97m[INFO -->]\e[49m\e[39m $@"
}

OS_RELEASE="/etc/redhat-release"
ANSIBLE_HOSTS_FILE="/etc/ansible/hosts"
ANSIBLE_NODES=("$@")
USER_NAME=admin
USER_PASSWORD=admin
PLUGIN_NAME=( "ace-editor" "ansible-tower" "ansicolor" "ant" "antisamy-markup-formatter" "apache-httpcomponents-client-4-api" "atlassian-bitbucket-server-integration" "authentication-tokens"
            "blueocean-autofavorite" "blueocean-bitbucket-pipeline" "blueocean-commons" "blueocean-config" "blueocean-core-js" "blueocean-dashboard" "blueocean-display-url" "blueocean-events" "blueocean-git-pipeline"
            "blueocean-github-pipeline" "blueocean-i18n" "blueocean-jwt" "blueocean-personalization" "blueocean-pipeline-api-impl" "blueocean-pipeline-editor" "blueocean-pipeline-scm-api" "blueocean-rest-impl" "blueocean-rest"
            "blueocean-web" "blueocean" "bootstrap5-api" "bouncycastle-api" "branch-api" "build-monitor-plugin" "build-timeout" "build-user-vars-plugin" "build-with-parameters" "caffeine-api" "checks-api" "cloud-stats" "cloudbees-bitbucket-branch-source"
            "cloudbees-folder" "command-launcher" "commons-lang3-api" "commons-text-api" "conjur-credentials" "conjur-simple-integration" "credentials-binding" "credentials" "declarative-pipeline-migration-assistant-api" "declarative-pipeline-migration-assistant"
            "display-url-api" "docker-build-publish" "docker-build-step" "docker-commons" "docker-compose-build-step" "docker-java-api" "docker-plugin" "docker-slaves" "docker-workflow" "dockerhub-notification" "durable-task" "dynamic_extended_choice_parameter"
            "echarts-api" "email-ext" "extended-choice-parameter" "extended-read-permission" "extensible-choice-parameter" "external-monitor-job" "favorite" "font-awesome-api" "generic-webhook-trigger" "git-client" "git" "github-api" "github-branch-source"
            "github" "gradle" "groovy" "handy-uri-templates-2-api" "htmlpublisher" "icon-shim" "instance-identity" "ionicons-api" "jackson2-api" "jakarta-activation-api" "jakarta-mail-api" "javadoc" "javax-activation-api" "javax-mail-api" "jaxb" "jdk-tool"
            "jenkins-design-language" "jenkinslint" "jjwt-api" "jquery3-api" "jsch" "junit" "ldap" "mailer" "mapdb-api" "matrix-auth" "matrix-project" "maven-plugin" "metrics" "mina-sshd-api-common" "mina-sshd-api-core" "momentjs" "okhttp-api" "pam-auth" "parameterized-trigger"
            "pipeline-build-step" "pipeline-github-lib" "pipeline-graph-analysis" "pipeline-graph-view" "pipeline-groovy-lib" "pipeline-input-step" "pipeline-milestone-step" "pipeline-model-api" "pipeline-model-definition" "pipeline-model-extensions" "pipeline-rest-api"
            "pipeline-stage-step" "pipeline-stage-tags-metadata" "pipeline-stage-view" "plain-credentials" "plugin-util-api" "popper2-api" "pubsub-light" "resource-disposer" "role-strategy" "scm-api" "script-security" "show-build-parameters" "snakeyaml-api" "sse-gateway" "ssh-agent"
            "ssh-credentials" "ssh-slaves" "ssh-steps" "sshd" "structs" "subversion" "timestamper" "token-macro" "trilead-api" "uno-choice" "validating-string-parameter" "variant" "windows-slaves" "workflow-aggregator" "workflow-api" "workflow-basic-steps" "workflow-cps"
            "workflow-durable-task-step" "workflow-job" "workflow-multibranch" "workflow-scm-step" "workflow-step-api" "workflow-support" "ws-cleanup" "yet-another-docker-plugin" )

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
    sudo yum install -y yum-utils yum-presto wget ansible git java-11-openjdk-devel openssl curl mlocate device-mapper-persistent-data lvm2 vim net-tools openssl-devel gcc
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

function config_jenkins() {
    # Get initial password
    INFO "Getting jenkins-cli"
    initial_password=$(docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword)
    # Get jenkins CLI
    path_to_jenkins='/var/jenkins_home/jenkins-cli.jar'
    until curl --retry 10 --retry-delay 5 -s -o /dev/null "http://localhost:8080/jnlpJars/jenkins-cli.jar"
    do
        sleep 5
    done
    if [ ! -f $path_to_jenkins ]; then
       wget http://localhost:8080/jnlpJars/jenkins-cli.jar -O $path_to_jenkins
    fi
    # Jenkins version
    docker exec jenkins echo 2.0 > /var/jenkins_home/jenkins.install.InstallUtil.lastExecVersion
    # Create admin user
    echo 'jenkins.model.Jenkins.instance.securityRealm.createAccount("'$USER_NAME'","'$USER_PASSWORD'")' |java -jar /var/jenkins_home/jenkins-cli.jar -auth admin:$initial_password -s http://localhost:8080/ groovy =
}

function jenkins_plugins() {
    docker exec jenkins sed -i 's/<denyAnonymousReadAccess>true<\/denyAnonymousReadAccess>/<denyAnonymousReadAccess>false<\/denyAnonymousReadAccess>/g' /var/jenkins_home/config.xml
    docker exec jenkins sed -i 's/<useSecurity>true<\/useSecurity>/<useSecurity>false<\/useSecurity>/g' /var/jenkins_home/config.xml

    # Install plugins
    INFO "Start installing plugins"
    for i in ${PLUGIN_NAME[@]};do
       java -jar /var/jenkins_home/jenkins-cli.jar -s http://localhost:8080/ -auth $USER_NAME:$USER_PASSWORD install-plugin $i
    done
    docker restart jenkins
}

if platform_supported; then
    chmod_ssh && \
    install_all && \
    add_ansible_nodes && \
    config_jenkins && \
    jenkins_plugins
fi