#!/usr/bin/env bash
INFO(){
    /bin/echo -e "\e[104m\e[97m[INFO -->]\e[49m\e[39m $@"
}
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
    sed -i 's/<denyAnonymousReadAccess>true<\/denyAnonymousReadAccess>/<denyAnonymousReadAccess>false<\/denyAnonymousReadAccess>/g' /var/jenkins_home/config.xml
    sed -i 's/<useSecurity>true<\/useSecurity>/<useSecurity>false<\/useSecurity>/g' /var/jenkins_home/config.xml

    # Install plugins
    INFO "Start installing plugins"
    for i in ${PLUGIN_NAME[@]};do
       java -jar /var/jenkins_home/jenkins-cli.jar -s http://localhost:8080/ -auth $USER_NAME:$USER_PASSWORD install-plugin $i
    done
    docker rm -f jenkins
    sudo ex +g/useSecurity/d +g/authorizationStrategy/d -scwq /var/lib/jenkins/config.xml
    docker run -d --name jenkins -e JAVA_OPTS="-Djenkins.install.runSetupWizard=false" -p 8080:8080 -p 50000:50000 -v /var/run/docker.sock:/var/run/docker.sock -v /var/jenkins_home/:/var/jenkins_home jenkins/jenkins:lts
    INFO "Start Jenkins..."
}

config_jenkins
jenkins_plugins