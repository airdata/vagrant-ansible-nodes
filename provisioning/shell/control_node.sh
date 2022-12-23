#!/usr/bin/env bash

# this script installs ansible control node
INFO(){
    /bin/echo -e "\e[104m\e[97m[INFO -->]\e[49m\e[39m $@"
}
OS_RELEASE="/etc/redhat-release"
ANSIBLE_HOSTS_FILE="/etc/ansible/hosts"
ANSIBLE_NODES=("$@")
USER_NAME='admin'
USER_PASSWORD='admin'
JENKINS_PLUGINS=( "javax-activation-api:1.2.0-4" "ws-cleanup:0.41" "javax-mail-api:1.6.2-5" "sshd:3.228.v4c9f9e652c86" "cloudbees-folder:6.740.ve4f4ffa_dea_54" "antisamy-markup-formatter:2.7" "structs:318.va_f3ccb_729b_71" "token-macro:293.v283932a_0a_b_49" "ant:1.13" "build-timeout:1.20" "jsch:0.1.55.2" "credentials:1087.1089.v2f1b_9a_b_040e4" "trilead-api:1.57.v6e90e07157e1" "workflow-scm-step:400.v6b_89a_1317c9a_" "ssh-credentials:277.v95c2fec1c047" "workflow-step-api:625.vd896b_f445a_f8" "workflow-cps:2729.vea_17b_79ed57a_" "plain-credentials:1.8" "credentials-binding:523.vd859a_4b_122e6" "git-client:3.11.0" "scm-api:608.vfa_f971c5a_a_e9" "workflow-api:1188.v0016b_4f29881" "git-server:1.10" "timestamper:1.17" "caffeine-api:2.9.2-29.v717aac953ff3" "workflow-job:1189.va_d37a_e9e4eda_" "script-security:1175.v4b_d517d6db_f0" "plugin-util-api:2.16.0" "mailer:435.v79ef3972b_5c7" "font-awesome-api:6.0.0-1" "branch-api:2.1044.v2c007e51b_87f" "popper-api:1.16.1-2" "jquery3-api:3.6.0-2" "bootstrap4-api:4.6.0-3" "workflow-basic-steps:986.v6b_9c830a_6b_37" "snakeyaml-api:1.30.1" "jackson2-api:2.13.3-285.vc03c0256d517" "popper2-api:2.11.5-1" "bootstrap5-api:5.1.3-6" "echarts-api:5.3.2-1" "gradle:1.38" "display-url-api:2.3.6" "pipeline-milestone-step:101.vd572fef9d926" "workflow-support:820.vd1a_6cc65ef33" "checks-api:1.7.2" "jjwt-api:0.11.2-9.c8b45b8bb173" "junit:1.59" "matrix-project:772.v494f19991984" "resource-disposer:0.18" "jaxb:2.3.6-1" "durable-task:496.va67c6f9eefa7" "ace-editor:1.1" "workflow-durable-task-step:1190.vc93d7d457042" "okhttp-api:4.9.3-105.vb96869f8ac3a" "jdk-tool:1.5" "pipeline-build-step:2.18" "command-launcher:1.6" "bouncycastle-api:2.25" "apache-httpcomponents-client-4-api:4.5.13-1.0" "pipeline-stage-step:293.v200037eefcd5" "pipeline-model-api:2.2114.v2654ca_721309" "pipeline-model-extensions:2.2114.v2654ca_721309" "workflow-cps-global-lib:570.v21311f4951f8" "workflow-multibranch:716.vc692a_e52371b_" "pipeline-stage-tags-metadata:2.2114.v2654ca_721309" "pipeline-input-step:449.v77f0e8b_845c4" "blueocean-rest:1.25.5" "pipeline-model-definition:2.2114.v2654ca_721309" "variant:1.4" "lockable-resources:2.14" "workflow-aggregator:581.v0c46fa_697ffd" "github-api:1.303-400.v35c2d8258028" "pubsub-light:1.16" "git:4.11.3" "htmlpublisher:1.30" "github:1.34.3" "github-branch-source:1598.v91207e9f9b_4a_" "pipeline-github-lib:38.v445716ea_edda_" "pipeline-graph-analysis:188.v3a01e7973f2c" "pipeline-rest-api:2.23" "blueocean-jwt:1.25.3" "handlebars:3.0.8" "blueocean-web:1.25.3" "momentjs:1.1.1" "pipeline-stage-view:2.23" "favorite:2.4.1" "ssh-slaves:1.821.vd834f8a_c390e" "blueocean-config:1.25.3" "matrix-auth:3.1" "jnr-posix-api:3.1.7-3" "blueocean-i18n:1.25.3" "pam-auth:1.7" "ldap:2.8" "sse-gateway:1.25" "email-ext:2.87" "authentication-tokens:1.4" "ansicolor:1.0.1" "docker-commons:1.19" "jenkins-design-language:1.25.3" "docker-slaves:1.0.7" "blueocean-events:1.25.3" "docker-plugin:1.2.9" "build-steps-from-json:1.0" "blueocean:1.25.3" "mercurial:2.16" "stashNotifier:1.28" "blueocean-git-pipeline:1.25.3" "build-token-trigger:1.0.0" "generic-webhook-trigger:1.84" "blueocean-core-js:1.25.3" "build-token-root:1.9" "ansible:1.1" "uno-choice:2.6.1" "osf-builder-suite-xml-linter:1.0.2" "pipeline-utility-steps:2.12.2" "blueocean-commons:1.25.5" "blueocean-pipeline-scm-api:1.25.5" "blueocean-rest-impl:1.25.3" "blueocean-pipeline-api-impl:1.25.3" "blueocean-github-pipeline:1.25.3" "handy-uri-templates-2-api:2.1.8-22.v77d5b_75e6953" "cloudbees-bitbucket-branch-source:765.v5a_2d6a_23c01d" "pipeline-groovy-lib:593.va_a_fc25d520e9" "blueocean-bitbucket-pipeline:1.25.3" "blueocean-dashboard:1.25.3" "blueocean-personalization:1.25.3" "blueocean-display-url:2.4.1" "blueocean-pipeline-editor:1.25.3" "blueocean-autofavorite:1.2.5" "environment-script:1.2.6" "docker-java-api:3.2.13-37.vf3411c9828b9" "multiple-scms:0.8" "deploy:1.16" "bitbucket-build-status-notifier:1.4.2" "job-dsl:1.79" "ssh-steps:2.0.39.v831c5e6468b_c" "bitbucket:223.vd12f2bca5430" "bitbucket-push-and-pull-request:2.8.1" "jakarta-mail-api:2.0.0-6" "github-branch-pr-change-filter:1.2.4" "docker-workflow:1.29" "atlassian-bitbucket-server-integration:3.2.1" "metrics:4.1.6.2" "bitbucket-pullrequests-filter:0.1.0" "parameterized-trigger:2.44" "parameterized-scheduler:1.0" "ssh:2.6.1" "ssh-agent:295.v9ca_a_1c7cc3a_a_" "publish-over:0.22" "publish-over-ssh:1.24" "jakarta-activation-api:2.0.1-1" "ansible-tower:0.16.0" "docker-build-step:2.8" "build-failure-analyzer:2.4.0" "envinject-api:1.199.v3ce31253ed13" "envinject:2.881.v37c62073ff97" "GatekeeperPlugin:3.0.5" )

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
    INFO "Install all"
    # Remove any old versions
    sudo yum remove -y docker docker-common docker-selinux docker-engine java*
    # Install required packages
    sudo yum install -y yum-utils yum-presto wget openssl curl mlocate epel-release device-mapper-persistent-data lvm2 vim net-tools
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
    # Download and Install Jenkins and Java
    mkdir -m 777 /var/jenkins_home
    docker run -d -p 8080:8080 -p 50000:50000 --name jenkins -v /var/run/docker.sock:/var/run/docker.sock -v /var/jenkins_home/:/var/jenkins_home jenkins/jenkins:lts
    sleep 100
    echo "Jenkins password: $(docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword)"
}

if platform_supported; then
    chmod_ssh && \
    install_all && \
    add_ansible_nodes
fi