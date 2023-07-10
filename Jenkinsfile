pipeline {
  agent any

  environment {
    deploymentName = "devsecops"
    containerName = "devsecops-container"
    serviceName = "devsecops-svc"
    imageName = "akinadejoro/numeric-app:${GIT_COMMIT}"
    applicationURL="http://my-devsecops-demo.eastus.cloudapp.azure.com"
    applicationURI="/increment/99"
    USER_CREDENTIALS = credentials('docker-hub')
  }

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

     stage('Vulnerability Scan - Docker ') {
      steps {
        parallel (
          "Dependency scan": {
              sh "mvn dependency-check:check"
          },
          "Trivy scan": {
              sh "bash trivy-docker-image-scan.sh"
           },
           "OPA Conftest": {
              sh 'docker run --rm -v $(pwd):/project openpolicyagent/conftest test --policy opa-docker-security.rego Dockerfile'
            }   
         )
       }
     }
    // stage('Docker Build and Push') {
    //       steps {
    //         withDockerRegistry([credentialsId: 'docker-hub', url: ""]) {
    //           sh "printenv"
    //           sh 'sudo docker build -t akinadejoro/numeric-app:""$GIT_COMMIT"" .'
    //           sh 'sudo docker push akinadejoro/numeric-app:""$GIT_COMMIT""'
    //       }
    //     }
    // }

    stage('Docker Build and Push') {
          steps {
              sh 'docker login -u "$USER_CREDENTIALS_USR" -p "$USER_CREDENTIALS_PSW" docker.io'
              sh "printenv"
              sh 'sudo docker build -t akinadejoro/numeric-app:""$GIT_COMMIT"" .'
              sh 'sudo docker push akinadejoro/numeric-app:""$GIT_COMMIT""'
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
            },
            "Trivy Scan": { 
               sh 'docker login -u "$USER_CREDENTIALS_USR" -p "$USER_CREDENTIALS_PSW" docker.io'
               sh 'export CONTAINERD_ADDRESS=/var/run/docker.sock'
               sh 'sudo TRIVY_USERNAME=$USER_CREDENTIALS_USR TRIVY_PASSWORD=$USER_CREDENTIALS_PSW docker run --rm -v $WORKSPACE:/root/.cache/ aquasec/trivy -q image --exit-code 0 --severity LOW,MEDIUM,HIGH --light $imageName'
               sh 'sudo TRIVY_USERNAME=$USER_CREDENTIALS_USR TRIVY_PASSWORD=$USER_CREDENTIALS_PSW docker run --rm -v $WORKSPACE:/root/.cache/ aquasec/trivy -q image --exit-code 1 --severity CRITICAL --light $imageName'
                // sh "bash trivy-k8s-scan.sh"
                // sh 'docker run --rm -v /tmp/.cache:/root/.cache/ aquasec/trivy:0.17.2 -q image --exit-code 0 --severity LOW,MEDIUM,HIGH --light $imageName'
                // sh 'docker run --rm -v /tmp/.cache:/root/.cache/ aquasec/trivy:0.17.2 -q image --exit-code 1 --severity CRITICAL --light $imageName'
          }
        )
      }
    }

    // stage('Kubernetes Deployment - DEV') {
    //       steps {
    //         withKubeConfig([credentialsId: 'kubeconfig']) {
    //           sh "sed -i 's#replace#akinadejoro/numeric-app:${GIT_COMMIT}#g' k8s_deployment_service.yaml"
    //           sh "kubectl apply -f k8s_deployment_service.yaml"
    //         }
    //     }
    // }

    stage('K8S Deployment - DEV') {
      steps {
        parallel(
          "Deployment": {
            withKubeConfig([credentialsId: 'kubeconfig']) {
              sh "bash k8s-deployment.sh"
            }
          },
          "Rollout Status": {
            withKubeConfig([credentialsId: 'kubeconfig']) {
              sh "bash k8s-deployment-rollout-status.sh"
            }
          }
        )
      }
    }
     
  }
  post {
          always {
            junit 'target/surefire-reports/*.xml'
            jacoco execPattern: 'target/jacoco.exec'
            dependencyCheckPublisher pattern: 'target/dependency-check-report.xml'
          }

          // success {

          // }

          // failure {

          // }
    }
}

































































// pipeline {
//   agent any

//   stages {
//       stage('Build Artifact') {
//             steps {
//               sh "mvn clean package -DskipTests=true"
//               archive 'target/*.jar'
//             }
//         }
//       stage('Unit Tests') {
//             steps {
//               sh "mvn test"
//             }
//             post {
//               always{
//                 junit 'target/surefire-reports/*.xml'
//                 jacoco execPattern: 'target/jacoco.exec'
//               }
//             }
//         }
//       stage('Mutation Tests - PIT') {
//           steps {
//             sh "mvn org.pitest:pitest-maven:mutationCoverage"
//           }
//           post {
//             always {
//               pitmutation mutationStatsFile: '**/target/pit-reports/**/mutations.xml'
//             }
//         }
//       }
//       stage('SonarQube SAST') {
//             steps {
//               withSonarQubeEnv('SonarQube') {
//                 sh "mvn clean verify sonar:sonar -Dsonar.projectKey=numeric-application -Dsonar.projectName='numeric-application' -Dsonar.host.url=http://my-devsecops-demo.eastus.cloudapp.azure.com:9000"
//              }
//              timeout(time: 2, unit: 'MINUTES') {
//                script {
//                  waitForQualityGate abortPipeline: true
//                }
//              }
//          }
//       }
//       stage('Vulnerabilty Scan - Docker') {
//             steps {
//               sh "mvn dependency-check:check"
//             }
//             post {
//               always {
//                 dependencyCheckPublisher pattern: 'target/dependency-check-report.xml'
//          }
//        }
//      }

//     //  stage('Vulnerability Scan - Docker ') {
//     //   steps {
//     //     parallel (
//     //       "Dependency scan": {
//     //           sh "mvn dependency-check:check"
//     //       },
//     //       "Trivy scan": {
//     //           sh "bash trivy-docker-image-scan.sh"
//     //        }
//     //      )
//     //    }
//     //  }
//     stage('Docker Build and Push') {
//           steps {
//             withDockerRegistry([credentialsId: "docker-hub", url: ""]) {
//               sh "printenv"
//               sh 'docker build -t akinadejoro/numeric-app:""$GIT_COMMIT"" .'
//               sh 'docker push akinadejoro/numeric-app:""$GIT_COMMIT""'
//           }
//         }
//     }
//     stage('Kubernetes Deployment - DEV') {
//           steps {
//             withKubeConfig([credentialsId: 'kubeconfig']) {
//               sh "sed -i 's#replace#akinadejoro/numeric-app:${GIT_COMMIT}#g' k8s_deployment_service.yaml"
//               sh "kubectl apply -f k8s_deployment_service.yaml"
//             }
//         }
//     }
//     // post {
//     //       always {
//     //         junit 'target/surefire-reports/*.xml'
//     //         jacoco execPattern: 'target/jacoco.exec'
//     //         pitmutation mutationStatsFile: '**/target/pit-reports/**/mutations.xml'
//     //         dependencyCheckPublisher pattern: 'target/dependency-check-report.xml'
//     //       }

//     //       success {

//     //       }

//     //       failure {

//     //       }
//     // }   
//   }
// }