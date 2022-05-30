pipeline {
  agent any

  stages {
      stage('Build Artifact') {
            steps {
              sh "mvn clean package -DskipTests=true"
              archive 'target/*.jar' //so that they can be downloaded later
              sh "whoami"
            }
        }  
      stage('Unit Tests - JUnit and Jacoco') {
            steps {
                sh "mvn test"
           }
       }
      stage('Docker Build and Push') {
      steps {
        withDockerRegistry([credentialsId: "docker", url: ""]) {
          sh 'printenv'
          sh 'docker build -t lakshit45/io:1 .'
          sh 'docker push lakshit45/io:1'
         }
        }
      }
      stage('Vulnerability Scan - Docker ') {
      steps {
        sh "mvn dependency-check:check"
        }
      }  
      
      stage('SonarQube - SAST') {
      steps {
        withSonarQubeEnv('SonarQube') {
          sh "mvn sonar:sonar   -Dsonar.projectKey=lakshit -Dsonar.host.url=http://20.58.188.143:9000 "
        }
        timeout(time: 2, unit: 'MINUTES') {
          script {
            waitForQualityGate abortPipeline: true
          }
        }
      }
    }


     
      stage('Kubernetes Deployment - DEV') {
      steps {
        withKubeConfig([credentialsId: 'kubeconfig']) {
          sh "sed -i 's#replace#siddharth67/numeric-app:${GIT_COMMIT}#g' k8s_deployment_service.yaml"
          sh "kubectl apply -f k8s_deployment_service.yaml"
        }
      }
    }
  }  
     
   post {
        always {
          junit 'target/surefire-reports/*.xml'
          jacoco execPattern: 'target/jacoco.exec'
          dependencyCheckPublisher pattern: 'target/dependency-check-report.xml'
        }
      }
  }
