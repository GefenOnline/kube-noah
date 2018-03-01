#!/usr/bin/env groovy

/* The goal is to minimize the use of groovy functions as mush as possible
   and replace is with Jenkins pipeline declerative language when docker is supported */
import groovy.transform.Field

// Organization name and project name
/*@Field ORG_NAME = JOB_NAME.tokenize('/')[0].toLowerCase()
@Field PROJECT_NAME = JOB_NAME.tokenize('/')[1].toLowerCase()

// Image name, version and the image itself once it is built
@Field BUILD_NAME = ORG_NAME + "/" + PROJECT_NAME
@Field IMAGE_VERSION = BRANCH_NAME.tokenize('/').last() + ".${BUILD_NUMBER}"
@Field IMAGE = ''

// Build type and dir to use for the build
@Field BUILD_TYPE = 'docker'
@Field BUILD_DIR = "build/${BUILD_TYPE}"

// Docker registry and credentials
@Field DOCKER_REGISTRY = 'https://registry.hub.docker.com'
@Field DOCKER_REGISTRY_CREDS_ID = '52d6d5f9-4dea-426e-b561-2d419b0f3c48'

// Norifications: Slack Channel
@Field SLACK_CHANNEL = "#jenkins_pipelines"*/

//Build image using the files in the build directory
def buildImage() {
  echo "Building Image..."
  switch (BUILD_TYPE) {
    case "docker":
      sh "cp -r ${BUILD_DIR}/. ."
      IMAGE = docker.build("${IMAGE_NAME}:${IMAGE_VERSION}")
      break
    default:
      echo "Unkown build type"
      break
  }
}

// Push image to registry
def pushImage() {
  echo "Pushing Image..."
  switch (BUILD_TYPE) {
    case "docker":
      docker.withRegistry("${DOCKER_REGISTRY}", "${DOCKER_REGISTRY_CREDS_ID}") {
        IMAGE.push("${IMAGE_VERSION}")
        IMAGE.push("latest")
      }
      break
    default:
      echo "Unknow build type"
      break
  }
}

// Delete image and all its tags (using the image id)
def deleteImage() {
  echo "Deleting Image..."
  switch (BUILD_TYPE) {
    case "docker":
      sh "docker rmi -f \$(docker images --quiet --filter reference=${IMAGE_NAME}:${IMAGE_VERSION})"
      break
    default:
      echo "Unknown build type"
      break
  }
}

// Main function to be called upon start
def start() {
  ORG_NAME = JOB_NAME.tokenize('/')[0].toLowerCase()
  PROJECT_NAME = JOB_NAME.tokenize('/')[1].toLowerCase()

  // Image name, version and the image itself once it is built
  BUILD_NAME = ORG_NAME + "/" + PROJECT_NAME
  IMAGE_VERSION = BRANCH_NAME.tokenize('/').last() + ".${BUILD_NUMBER}"
  IMAGE = ''

  // Build type and dir to use for the build
  BUILD_TYPE = 'docker'
  BUILD_DIR = "build/${BUILD_TYPE}"

  // Docker registry and credentials
  DOCKER_REGISTRY = 'https://registry.hub.docker.com'
  DOCKER_REGISTRY_CREDS_ID = '52d6d5f9-4dea-426e-b561-2d419b0f3c48'

  // Norifications: Slack Channel
  SLACK_CHANNEL = "#jenkins_pipelines"
  pipeline {

    agent any

    stages {
      stage ('Verify Tools And Print Environment Vars') {
        steps {
          parallel (
            /* Verify Docker for Docker builds, docker-compose for tests and print environment variables
            NOTE: here one should add testing tools commands (acbuild -v for rkt type builds for example) */
            DOCKER: { sh "docker info" },
            DOCKER_COMPOSE: { sh "docker-compose version" },
            ENVIRONMENT: {
              echo "JOB_NAME                : ${JOB_NAME}"
              echo "IMAGE_NAME              : ${IMAGE_NAME}"
              echo "IMAGE_VERSION           : ${IMAGE_VERSION}"
              echo "BUILD_TYPE              : ${BUILD_TYPE}"
              echo "BUILD_DIR               : ${BUILD_DIR}"
              echo "BRANCH_NAME             : ${BRANCH_NAME}"
              echo "DOCKER_REGISTRY         : ${DOCKER_REGISTRY}"
              echo "DOCKER_REGISTRY_CREDS_ID: ${DOCKER_REGISTRY_CREDS_ID}"
            }
          )
        }
      }
      stage('Build') {
        when {
          anyOf { branch 'master/*' }
        }
        steps {
          buildImage()
        }
      }
      stage('Push to Registry') {
        when {
          anyOf { branch 'master/*' }
        }
        steps {
          pushImage()
        }
      }
    }
    post {
      always {
        // Cleaning Image
        deleteImage()
        // Cleaning Workspace (build-in function)
        deleteDir()
      }
      success {
        slackSend channel: "${SLACK_CHANNEL}",
          color: 'good',
          message: "The pipeline ${currentBuild.fullDisplayName} completed successfully. ${BUILD_URL}"
      }
      failure {
          slackSend channel: "${SLACK_CHANNEL}",
          color: 'danger',
          message: "The pipeline ${currentBuild.fullDisplayName} failed. ${BUILD_URL}"
      }
      unstable {
          slackSend channel: "${SLACK_CHANNEL}",
          color: 'warning',
          message: "The pipeline ${currentBuild.fullDisplayName} is unstable. ${BUILD_URL}"
      }
    }
  }
}

start()
