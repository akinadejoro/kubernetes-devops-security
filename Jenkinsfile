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
      stage('Docker Build and Push') {
            steps {
              withDockerRegistry([credentialId: "docker-hub", url: ""]) {
              sh "printenv"
              sh 'docker build -t akinadejoro/numeric-app:""$GIT_COMMIT"" .'
              sh 'docker push akinadejoro/numeric-app:""$GIT_COMMIT""'
            }
          }
        }   
    }
}
