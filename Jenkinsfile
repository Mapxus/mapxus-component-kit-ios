pipeline {

    agent any
    
    parameters {
        gitParameter branchFilter: 'origin/(.*)', defaultValue: 'master', name: 'BRANCH', type: 'PT_BRANCH'
        choice name: 'ENV', choices: ['test', 'prod'], description: ''
        choice name: 'COM', choices: ['mapxus', 'landsd'], description: ''
    }
    
    stages {
        stage('checkout code') {
            steps {
                checkout([$class: 'GitSCM',
                        branches: [[name: "${params.BRANCH}"]],
                        doGenerateSubmoduleConfigurations: false,
                        extensions: [],
                        submoduleCfg: [],
                        userRemoteConfigs: [[credentialsId: 'ae558206-9d95-41be-bc22-137ff85fbdc4',
                        url: "https://gitea.mapxus.com/iOS/mapxus-base-sdk-ios.git"]]])
            }
        }
        
        stage('build code') {
            steps {
                withEnv(['PATH+EXTRA=/usr/local/bin']) {
                    sh "bash AutoRun.sh -c \"${params.COM}\" -d \"${JENKINS_HOME}/workspace\" -e \"${params.ENV}\""
                }
            }
        }

    }
    
}
