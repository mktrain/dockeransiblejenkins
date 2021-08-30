
pipeline {
    agent any 
      environment {
      IMAGE_REPO_NAME = "mktraindo/smart"
      DOCKER_HUB_USERNAME = "mktraindo"
      DOCKER_TAG= getVersion()
}
    stages{
        stage("SCM CheckOut"){
            steps{
            git branch: 'devops', credentialsId: 'github-cred', url: 'https://github.com/mktrain/dockeransiblejenkins.git'        }
        }
      stage("Maven Build"){
            steps{
            sh "mvn clean && mvn install"
            
        }
        }
        stage("SonarQube Analysis"){
            steps{
            withSonarQubeEnv('sonar-server'){
            sh "mvn sonar:sonar"
        }
        }
        }
       stage('upload artifacts'){
              steps{
                  script{

                    def mavenPom = readMavenPom file: 'pom.xml'
                      nexusArtifactUploader artifacts: 
                      [
                          [
                              artifactId: 'dockeransible', 
                              classifier: '', 
                              file: "/var/lib/jenkins/workspace/gitcheck/target/dockeransible-${mavenPom.version}.war", 
                              type: 'war'
                          ]
                      ], 
                      credentialsId: 'nexus-credentials', 
                      groupId: 'in.javahome', 
                      nexusUrl: '34.131.71.42:8081', 
                      nexusVersion: 'nexus3', 
                      protocol: 'http', 
                      repository: 'maven-snapshots', 
                      version: "${mavenPom.version}"
                  }
              }
          }
        stage("Docker Image Build"){
            steps{
            sh "docker build . -t ${IMAGE_REPO_NAME}:${DOCKER_TAG}"
        }
        }
        stage("Push to Docker Hub"){
            steps{
            withCredentials([string(credentialsId: 'DOCKER_HUB_PASSWORD', variable: 'dockerHubPwd')]) {
            sh "docker login -u ${DOCKER_HUB_USERNAME} -p ${dockerHubPwd}"
            sh "docker push ${IMAGE_REPO_NAME}:${DOCKER_TAG}"
        }
        }
        }
         stage("Docker Deploy using Ansible"){
            steps{
            ansiblePlaybook becomeUser: 'True', credentialsId: 'ansible-cred', disableHostKeyChecking: true, extras: "-e DOCKER_TAG=${DOCKER_TAG}", installation: 'ansible', inventory: '/var/lib/jenkins/workspace/gitcheck/dev.inv', playbook: '/var/lib/jenkins/workspace/gitcheck/deploy-docker.yml'
        }
        }
}
}
def getVersion(){
    def commitHash = sh label: '', returnStdout: true, script: 'git rev-parse --short HEAD'
    return commitHash
}
