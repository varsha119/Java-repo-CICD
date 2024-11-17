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
                label 'sonar'
            }
            steps {
                sh 'mvn clean install'
            }
            post {
                success {
                    script {
                        def server = Artifactory.newServer(url: 'http://13.235.238.224/:8081/artifactory/', credentialsId: 'jfrog')
                        def rtMaven = Artifactory.newMavenBuild()
                        rtMaven.deployer server: server, releaseRepo: 'libs-release/', snapshotRepo: 'libs-snapshot/'
                        rtMaven.tool = 'maven'
                        rtMaven.run(pom: 'pom.xml', goals: 'clean install')
                    }
                }
            }
        }
	stage('Push to ECR and Deply to eks') {
            agent {
                label 'deploy'
            }
            steps {
                script {
                    sh 'curl -o jenkins-test-2.0.jar http://13.235.238.224:8081/artifactory/libs-release/com/example/jenkins-test/2.0/jenkins-test-2.0.jar'
                    sh '''
                        aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin 143106762218.dkr.ecr.ap-south-1.amazonaws.com
                        docker build -t sstest .
                        docker tag sstest:latest 143106762218.dkr.ecr.ap-south-1.amazonaws.com/sstest:latest
                        docker push 143106762218.dkr.ecr.ap-south-1.amazonaws.com/sstest:latest
                        aws eks update-kubeconfig --region ap-south-1 --name cluster-eksctl
			kubectl version --client
                        kubectl apply -f test.yaml
                        sleep 10
                        kubectl get pods -n ss-dev
                        kubectl get svc -n ss-dev
                    '''
                }
            }
        }
}
}
