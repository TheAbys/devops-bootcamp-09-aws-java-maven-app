#!/user/bin/env groovy
library identifier: "jenkins-shared-library@master", retriever: modernSCM([
    $class: "GitSCMSource",
    remote: "git@github.com:TheAbys/devops-bootcamp-08-jenkins-shared-library.git",
    credentialsId: "github"
])

pipeline {   
    agent any
    tools {
        maven 'maven-3.9'
    }
    stages {
        stage('increment version') {
            steps {
                script {
                    echo 'incrementing app version...'
                    sh 'mvn build-helper:parse-version versions:set \
                        -DnewVersion=\\\${parsedVersion.majorVersion}.\\\${parsedVersion.minorVersion}.\\\${parsedVersion.nextIncrementalVersion} \
                        versions:commit'
                    def matcher = readFile('pom.xml') =~ '<version>(.+)</version>'
                    def version = matcher[0][1]
                    env.IMAGE_NAME = "k0938261-training:$version-$BUILD_NUMBER"
                }
            }
        }
        stage('build app') {
            steps {
                echo 'building application jar...'
                buildJar()
            }
        }
        stage('build image') {
            steps {
                script {
                    echo 'building the docker image...'
                    dockerBuildImageECR("aws-credentials", env.IMAGE_NAME, "561656302811.dkr.ecr.eu-central-1.amazonaws.com")
                    //dockerBuildImageECR("aws-credentials", "0938261-training:latest", "561656302811.dkr.ecr.eu-central-1.amazonaws.com")
                }
            }
        } 
        stage("deploy") {
            steps {
                script {
                    // deploy("ec2-user", "3.68.213.53", "docker run -p 3080:3080 -d 561656302811.dkr.ecr.eu-central-1.amazonaws.com/$env.IMAGE_NAME")
                    deploy("ec2-user", "3.68.213.53", env.IMAGE_NAME, "ssh-agent-credentials")
                }
            }               
        }
        stage('commit version update'){
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: "github", passwordVariable: "PASS", usernameVariable: "USER")]) {
                        sh 'git config --global user.email "jenkins@example.com"'
                        sh 'git config --global user.name "jenkins"'

                        sh "git status"
                        sh "git branch" // XX jenkins checks out the commit and not the branch itself
                        sh "git config --list"

                        sh "git remote set-url origin https://${USER}:${PASS}@github.com/TheAbys/devops-bootcamp-08-jenkins.git"
                        sh 'git add .'
                        sh 'git commit -m "CI: version bump"'
                        sh 'git push origin HEAD:master' // see XX: that's why it is necessary to tell push where exactly to push
                    }
                }
            }
        }
    }
}
