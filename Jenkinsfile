#!/bin/env groovy

@Library('cliqz-shared-library@vagrant') _

properties([
    disableConcurrentBuilds(),
    [$class: 'JobRestrictionProperty']
])

def vagrantfile = '''
require 'uri'
Vagrant.configure("2") do |config|
	config.vm.box = "mojave"

	config.vm.define "publishios" do |publishios|
	    publishios.vm.hostname ="mojave"
	    publishios.ssh.forward_agent = true

	    config.vm.provider "parallels" do |prl|
            prl.memory = ENV["NODE_MEMORY"]
            prl.cpus = ENV["NODE_CPU_COUNT"]
        end

	    node_id = URI::encode(ENV['NODE_ID'])
	    publishios.vm.provision "shell", privileged: false, run: "always", inline: <<-SHELL#!/bin/bash -l
            set -e
            set -x
            sudo mkdir -p /jenkins
            sudo chown vagrant /jenkins
            brew install python3
            brew tap adoptopenjdk/openjdk
            brew cask install adoptopenjdk8
            curl -LO https://raw.githubusercontent.com/cliqz/cliqz-browser-ios/develop/jenkins.py
            python3 jenkins.py --url #{ENV['JENKINS_URL']} --node #{node_id} --secret #{ENV["NODE_SECRET"]} &
	    SHELL
	end
end
'''

node('gideon') {
    try{
        timeout(120){
            writeFile file: 'Vagrantfile', text: vagrantfile

            vagrant.inside(
                'Vagrantfile',
                '/jenkins',
                4, // CPU
                8192, // MEMORY
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
                                brew install node carthage
                                java -version
                                node -v
                                npm -v
                                brew -v
                                sudo xcode-select --switch /Applications/Xcode.app/
                                xcodebuild -version
                                pkgutil --pkg-info=com.apple.pkg.CLTools_Executables
                                sudo xcodebuild -license accept
                                sudo gem install fastlane cocoapods
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
                    } catch(all) {
                        print "Something Failed. Check the above logs."
                        print all
                        currentBuild.result = 'FAILURE'
                    } finally {
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
