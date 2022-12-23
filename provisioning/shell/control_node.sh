#!/usr/bin/env bash

# this script installs ansible control node
PLATFORM_RELEASE_FILE="/etc/redhat-release"
ANSIBLE_HOSTS_FILE="/etc/ansible/hosts"
ANSIBLE_NODES=("$@")
USER_NAME='admin'
USER_PASSWORD='admin'
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

# Install ansible, docker, git, jenkins
function install_all() {
    # Remove any old versions
    sudo yum remove -y docker docker-common docker-selinux docker-engine java*
    # Install required packages
    sudo yum install -y yum-utils yum-presto wget openssl curl mlocate epel-release device-mapper-persistent-data lvm2 vim net-tools
    # Install Docker-ce git, docker-compose and ansible
    sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    sudo yum install -y docker-ce ansible git
    sudo systemctl start docker
    echo "!-- Docker is started --!"
    sudo systemctl enable docker
    sudo groupadd docker
    sudo usermod -aG docker vagrant
    curl -L "https://github.com/docker/compose/releases/download/1.25.3/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
    # Download and Install Jenkins and Java
    sudo wget --no-check-certificate -O /etc/yum.repos.d/jenkins.repo \
        https://pkg.jenkins.io/redhat-stable/jenkins.repo
    sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
    sudo yum install -y jenkins java-11-openjdk-devel
    sudo systemctl daemon-reload
    sudo systemctl start jenkins
    sudo systemctl enable jenkins
    echo "!-- Jenkins is started --!"
    sudo echo "Jenkins password is: $(cat /var/lib/jenkins/secrets/initialAdminPassword)"
}

function config_jenkins() {
    # Get initial password
    initial_password=$(cat /var/lib/jenkins/secrets/initialAdminPassword)
    # Get jenkins CLI
    path_to_jenkins='/var/lib/jenkins/jenkins-cli.jar'
    if [ ! -f $path_to_jenkins ]; then
       wget http://localhost:8080/jnlpJars/jenkins-cli.jar -O $path_to_jenkins
    else
       echo "CLI exist.."
    fi
    # Jenkins version
    echo 2.0 > /var/lib/jenkins/jenkins.install.InstallUtil.lastExecVersion
    # Create admin user
    echo 'jenkins.model.Jenkins.instance.securityRealm.createAccount("'$USER_NAME'","'$USER_PASSWORD'")' |java -jar /var/lib/jenkins/jenkins-cli.jar -auth admin:$initial_password -s http://localhost:8080/ groovy =
    systemctl restart jenkins
}
function plugins_install() {
    sed -i 's/<denyAnonymousReadAccess>true<\/denyAnonymousReadAccess>/<denyAnonymousReadAccess>false<\/denyAnonymousReadAccess>/g' /var/lib/jenkins/config.xml
    sed -i 's/<useSecurity>true<\/useSecurity>/<useSecurity>false<\/useSecurity>/g' /var/lib/jenkins/config.xml
    systemctl restart jenkins
    sleep 20
    systemctl status jenkins

    # Install plugins
    for i in ${PLUGIN_NAME[@]};do
       java -jar /var/lib/jenkins/jenkins-cli.jar -s http://localhost:8080/ -auth $USER_NAME:$USER_PASSWORD install-plugin $i
    done
    systemctl restart jenkins
}

if platform_supported; then
    chmod_ssh && \
    install_all && \
    add_ansible_nodes
    config_jenkins && \
    plugins_install
fi