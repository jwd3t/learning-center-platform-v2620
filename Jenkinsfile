pipeline {
  agent any

  tools {
    maven 'MAVEN_3_9'
    jdk 'JDK_26'
  }

  environment {
    REGISTRY_USER = "jwd3t"   // <-- CAMBIA AQUÍ (en minúsculas)
    STUDENT_CODE  = "u202318609"             // <-- CAMBIA AQUÍ por tu código en minúsculas
    IMAGE_NAME    = "learning-center-${STUDENT_CODE}"
    TAG           = "${env.BUILD_NUMBER}"
  }

  stages {
    stage('1. Compile Project') {
      steps {
        withMaven(maven: 'MAVEN_3_9', jdk: 'JDK_26') {
          sh 'mvn clean compile'
        }
      }
    }

    stage('2. Validate Checkstyle') {
      steps {
        withMaven(maven: 'MAVEN_3_9', jdk: 'JDK_26') {
          sh 'mvn checkstyle:check'
        }
      }
    }

    stage('3. Validate Unit Tests & Coverage') {
      steps {
        withMaven(maven: 'MAVEN_3_9', jdk: 'JDK_26') {
          sh 'mvn clean verify jacoco:report'
          sh 'mvn jacoco:check'
        }
      }
    }

    stage('4. SonarQube Analysis & Quality Gate') {
      steps {
        withMaven(maven: 'MAVEN_3_9', jdk: 'JDK_26') {
          withSonarQubeEnv('MiSonarServer') {
            sh "mvn sonar:sonar -Dsonar.projectKey=retail-store-${STUDENT_CODE}"
          }
        }
        script {
          timeout(time: 10, unit: 'MINUTES') {
            def qg = waitForQualityGate()
            if (qg.status != 'OK') {
              error "Quality Gate fallido: ${qg.status}"
            }
          }
        }
      }
    }

    stage('5. Build & Push Docker Image') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'DOCKER_HUB_CREDENTIALS', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
          script {
            echo "Iniciando sesion en Docker Hub..."
            sh "echo '${DOCKER_PASS}' | docker login -u '${DOCKER_USER}' --password-stdin"

            echo "Construyendo y publicando imagen ${REGISTRY_USER}/${IMAGE_NAME}:${TAG}..."
            sh "docker buildx build --platform linux/amd64 -t ${REGISTRY_USER}/${IMAGE_NAME}:${TAG} -t ${REGISTRY_USER}/${IMAGE_NAME}:latest --push ."
          }
        }
      }
    }
  }
}