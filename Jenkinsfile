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
  }  
   post {
        always {
          junit 'target/surefire-reports/*.xml'
          jacoco execPattern: 'target/jacoco.exec'
        }
      }
  }
