pipeline {
  agent any

  stages {
      stage('Build Artifact') {
            steps {
              sh "mvn clean package -DskipTests=true"
              archive 'target/*.jar'
            }
        }
      stage('Unit Tests') {
            steps {
              sh "mvn test"
            }
            post {
              always{
                junit 'target/surefire-reports/*.xml'
                jacoco execPattern: 'target/jacoco.exec'
              }
            }
        }
      stage('Mutation Tests - PIT') {
          steps {
            sh "mvn org.pitest:pitest-maven:mutationCoverage"
          }
          post {
            always {
              pitmutation mutationStatsFile: '**/target/pit-reports/**/mutations.xml'
            }
        }
      }
      stage('SonarQube SAST') {
            steps {
              withSonarQubeEnv('SonarQube') {
                sh "mvn clean verify sonar:sonar -Dsonar.projectKey=numeric-application -Dsonar.projectName='numeric-application' -Dsonar.host.url=http://my-devsecops-demo.eastus.cloudapp.azure.com:9000"
             }
             timeout(time: 2, unit: 'MINUTES') {
               script {
                 waitForQualityGate abortPipeline: true
               }
             }
         }
      }
      stage('Vulnerabilty Scan - Docker') {
            steps {
              sh "mvn dependency-check:check"
            }
            post {
              always {
                dependencyCheckPublisher pattern: 'target/dependency-check-report.xml'
         }
       }
     }

    //  stage('Vulnerability Scan - Docker ') {
    //   steps {
    //     parallel (
    //       "Dependency scan": {
    //           sh "mvn dependency-check:check"
    //       },
    //       "Trivy scan": {
    //           sh "bash trivy-docker-image-scan.sh"
    //        }
    //      )
    //    }
    //  }
    stage('Docker Build and Push') {
          steps {
            withDockerRegistry([credentialsId: "docker-hub", url: ""]) {
              sh "printenv"
              sh 'docker build -t akinadejoro/numeric-app:""$GIT_COMMIT"" .'
              sh 'docker push akinadejoro/numeric-app:""$GIT_COMMIT""'
          }
        }
    }
    stage('Kubernetes Deployment - DEV') {
          steps {
            withKubeConfig([credentialsId: 'kubeconfig']) {
              sh "sed -i 's#replace#akinadejoro/numeric-app:${GIT_COMMIT}#g' k8s_deployment_service.yaml"
              sh "kubectl apply -f k8s_deployment_service.yaml"
            }
        }
    }
    // post {
    //       always {
    //         junit 'target/surefire-reports/*.xml'
    //         jacoco execPattern: 'target/jacoco.exec'
    //         pitmutation mutationStatsFile: '**/target/pit-reports/**/mutations.xml'
    //         dependencyCheckPublisher pattern: 'target/dependency-check-report.xml'
    //       }

    //       success {

    //       }

    //       failure {

    //       }
    // }   
  }
}

