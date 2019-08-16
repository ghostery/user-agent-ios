#!/bin/env groovy

@Library('cliqz-shared-library@vagrant') _

properties([
    disableConcurrentBuilds(),
    [$class: 'JobRestrictionProperty']
])

def jobStatus = 'FAIL'

node('gideon') {
    try{
        timeout(120){
            writeFile file: 'Vagrantfile', text: '''
            Vagrant.configure("2") do |config|
                config.vm.box = "xcode-10.1"
                config.vm.synced_folder ".", "/vagrant", disabled: true
                config.vm.define "publishios" do |publishios|
                    publishios.vm.hostname ="cliqz-browser-ios"
                    publishios.vm.network "public_network", :bridge => "en0: Ethernet 1", auto_config: false
                    publishios.vm.boot_timeout = 900
                    publishios.ssh.forward_agent = true
                    publishios.vm.provider "virtualbox" do |v|
                        v.name = "cliqz-browser-ios"
                        v.gui = false
                        v.memory = ENV["NODE_MEMORY"]
                        v.cpus = ENV["NODE_CPU_COUNT"]
                    end
                    publishios.vm.provision "shell", privileged: false, run: "always", inline: <<-SHELL#!/bin/bash -l
                        set -e
                        set -x
                        rm -f agent.jar
                        curl -LO #{ENV['JENKINS_URL']}/jnlpJars/agent.jar
                        nohup java -jar agent.jar -jnlpUrl #{ENV['JENKINS_URL']}/computer/#{ENV['NODE_ID']}/slave-agent.jnlp -secret #{ENV["NODE_SECRET"]} &
                    SHELL
                end
            end
            '''

            vagrant.inside(
                'Vagrantfile',
                '/jenkins',
                4, // CPU
                12000, // MEMORY
                12000, // VNC port
                false, // rebuild image
            ) { nodeId ->
                node(nodeId) {
                    try {
                        stage('Checkout') {
                            checkout scm
                        }
                        stage('Prepare') {
                            sh '''#!/bin/bash -l
                                set -e
                                set -x
                                java -version
                                node -v
                                npm -v
                                brew -v
                                xcodebuild -version
                                pkgutil --pkg-info=com.apple.pkg.CLTools_Executables
                                sudo xcodebuild -license accept
                                fastlane clearCache
                                fastlane prepare
                            '''
                        }
                        stage('Build & Upload') {
                            withCredentials([
                                [
                                    $class          : 'UsernamePasswordMultiBinding',
                                    credentialsId   : '85859bba-4927-4b14-bfdf-aca726009962',
                                    passwordVariable: 'GITHUB_PASSWORD',
                                    usernameVariable: 'GITHUB_USERNAME',
                                ],
                                string(credentialsId: '8b4f7459-c446-4058-be61-3c3d98fe72e2', variable: 'ITUNES_USER'),
                                string(credentialsId: 'c21d2e60-e4b9-4f75-bad7-6736398a1a05', variable: 'SentryDSN'),
                                string(credentialsId: '05be12cd-5177-4adf-9812-809f01451fa0', variable: 'FASTLANE_PASSWORD'),
                                string(credentialsId: 'ea8c47ad-1de8-4300-ae93-ec9ff4b68f39', variable: 'MATCH_PASSWORD'),
                                string(credentialsId: 'f206e880-e09a-4369-a3f6-f86ee94481f2', variable: 'SENTRY_AUTH_TOKEN'),
                                string(credentialsId: 'ab91f92a-4588-4034-8d7f-c1a741fa31ab', variable: 'FASTLANE_ITC_TEAM_ID')])
                            {
                                sh '''#!/bin/bash -l
                                    set -x
                                    set -e
                                    rm -rf /Users/vagrant/Library/Keychains/ios-build.keychain*
                                    rm -rf ../build-tools

                                    export MATCH_KEYCHAIN_NAME=ios-build.keychain
                                    export CommitHash=`git rev-parse --short HEAD`
                                    export PATH="$PATH:/Users/vagrant/Library/Python/2.7/bin"

                                    fastlane CliqzNightly
                                '''
                            }
                        }
                        jobStatus = 'PASS'
                    }
                    catch(all) {
                        jobStatus = 'FAIL'
                        print "Something Failed. Check the above logs."
                        emailext(
                                to: 'krzysztof@cliqz.com',
                                subject: '$PROJECT_NAME - Build # $BUILD_NUMBER Failed!!!',
                                body: '\n\nCheck console output at ' + env.BUILD_URL + ' to view the cause.'
                        )
                        currentBuild.result = 'FAILURE'
                    }
                    finally {
                        stage("Clean Up"){
                            sh '''#!/bin/bash -l
                                set -x
                                set -e
                                fastlane clearCache
                            '''
                        }
                    }
                }
            }
        }
    } catch(err){
        echo 'Build was not completed before timeout'
        currentBuild.result = 'FAILURE'
    }
}



