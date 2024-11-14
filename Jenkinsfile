pipeline {
    agent any
    environment {
        AWS_ACCESS_KEY_ID     = credentials('aws-access-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
        AWS_DEFAULT_REGION    = 'ap-south-1'
    }
	
    stages {
        stage('SonarQube Analysis') {
            agent {
                label 'sonar'
            }
            steps{
                withSonarQubeEnv('sonarCodeSS') { 
                    sh "mvn clean verify sonar:sonar -Dsonar.projectKey=ss"
                 }
                }
            }
        stage('Build Stage') {
            agent {
                label 'jfrog'
            }
            steps {
                sh 'mvn clean install'
            }
            post {
                success {
                    script {
                        def server = Artifactory.newServer(url: 'http://13.127.33.64:8081/artifactory/', credentialsId: 'jfrog')
                        def rtMaven = Artifactory.newMavenBuild()
                        rtMaven.deployer server: server, releaseRepo: 'libs-release/', snapshotRepo: 'libs-snapshot/'
                        rtMaven.tool = 'maven'
                        rtMaven.run(pom: 'pom.xml', goals: 'clean install')
                    }
                }
            }
        }
}
}
