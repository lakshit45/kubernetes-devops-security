@Library('slack') _

pipeline {
  agent any

   environment {
    deploymentName = "devsecops"
    containerName = "devsecops-container"
    serviceName = "devsecops-svc"
    imageName = "siddharth67/numeric-app:${GIT_COMMIT}"
    applicationURL = "http://devsecops.australiaeast.cloudapp.azure.com" 
    applicationURI = "/increment/99"
  }

  stages {

    stage('Build Artifact - Maven') {
      steps {
        sh "mvn clean package -DskipTests=true"
        archive 'target/*.jar'
      }
    }

    stage('Unit Tests - JUnit and JaCoCo') {
      steps {
        sh "mvn test"
        sh "pwd"
      }
    }


  //  stage('SonarQube - SAST') {
   //   steps {
     //   withSonarQubeEnv('SonarQube') {
       //   sh "mvn sonar:sonar       -Dsonar.projectKey=lakshit  -Dsonar.host.url=http://20.58.188.143:9000"
      //  }
    //    timeout(time: 2, unit: 'MINUTES') {
      //    script {
        //    waitForQualityGate abortPipeline: true
          //}
   //     }
     // }
   // }

    stage('Vulnerability Scan - Docker') {
      steps {
        parallel(
          "Dependency Scan": {
           sh "mvn dependency-check:check"
          },
          "Trivy Scan": {
           sh "bash trivy-docker-image-scan.sh"
          },
          "OPA Conftest": {
            sh 'docker run --rm -v $(pwd):/project openpolicyagent/conftest test --policy opa-docker-security.rego Dockerfile'
          }
        )
      }
    }
   

    stage('Docker Build and Push') {
      steps {
        withDockerRegistry([credentialsId: "docker", url: ""]) {
          sh 'printenv'
          sh 'sudo docker build -t siddharth67/numeric-app:""$GIT_COMMIT"" .'
         // sh 'docker push siddharth67/numeric-app:""$GIT_COMMIT""'
        }
      }
    }
    

    stage('Vulnerability Scan - Kubernetes') {
      steps {
        parallel(
          "OPA Scan": {
            sh 'docker run --rm -v $(pwd):/project openpolicyagent/conftest test --policy opa-k8s-security.rego k8s_deployment_service.yaml'
           },
          "Kubesec Scan": {
            sh "bash kubesec-scan.sh"
          }
        )
      }
    }
    stage('Kubernetes Deployment - DEV') {
      steps {
        withKubeConfig([credentialsId: 'kubeconfig']) {
          sh "kubectl apply -f k8s_deployment_service.yaml"
          echo "$BUILD_NUMBER"
        }
      }
    
    stage('Prompte to PROD?') {
      steps {
        timeout(time: 2, unit: 'DAYS') {
          input 'Do you want to Approve the Deployment to Production Environment/Namespace?'
        }
      }
    

    stage('K8S CIS Benchmark') {
      steps {
        script {

          parallel(
            "Master": {
              sh "bash cis-master.sh"
            },
            "Etcd": {
              sh "bash cis-etcd.sh"
            },
            "Kubelet": {
              sh "bash cis-kubelet.sh"
            }
          )

        }
      }
    }
    stage('K8S Deployment - PROD') {
      steps {
        parallel(
          "Deployment": {
            withKubeConfig([credentialsId: 'kubeconfig']) {
              sh "sed -i 's#replace#${imageName}#g' k8s_PROD-deployment_service.yaml"
              sh "kubectl -n name apply -f k8s_PROD-deployment_service.yaml"
            }
          },
          "Rollout Status": {
            withKubeConfig([credentialsId: 'kubeconfig']) {
              sh "bash k8s-PROD-deployment-rollout-status.sh"
            }
          }
        )
      }
  }

  post {
    always {
      junit 'target/surefire-reports/*.xml'
      jacoco execPattern: 'target/jacoco.exec'
      dependencyCheckPublisher pattern: 'target/dependency-check-report.xml'
      
      // Use sendNotifications.groovy from shared library and provide current build result as parameter    
      sendNotification currentBuild.result
    }

    // success {

    // }

    // failure {

    // }
  }

 }
}
