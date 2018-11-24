#!groovy

pipeline {

	agent any

    environment {
        ORG_NAME = "oscurorestalion"
        APP_NAME = "income-predictor-vaadin"
        APP_CONTEXT_ROOT = "oscuroweb"
        CONTAINER_NAME = "ci-${APP_NAME}"
        IMAGE_NAME = "${ORG_NAME}/${APP_NAME}"
    }

    stages {
        stage('Compile') {
            agent {
        		docker {
            		image 'maven:3.5.4-jdk-8'
            		args '--network ci --mount type=volume,source=ci-maven-home,target=/root/.m2'
        		}
    		}
            steps {
                echo "-=- compiling project -=-"
                sh "mvn clean compile"
            }
        }

//        stage('Unit tests') {
//            steps {
//                echo "-=- execute unit tests -=-"
//                sh "mvn dependency:tree -Dverbose -Dincludes=oscuroweb"
//                sh "mvn test"
//            }
//        }

        stage('Package') {
            agent {
        		docker {
            		image 'maven:3.5.4-jdk-8'
            		args '--network ci --mount type=volume,source=ci-maven-home,target=/root/.m2'
        		}
    		}
            steps {
                echo "-=- packaging project -=-"
                sh "mvn package -DskipTests"
                archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
            }
        }

        stage('Build Docker image') {
            steps {
                echo "-=- build Docker image -=-"
                script {
                    step ([
                    	$class: "CopyArtifact",
                 		projectName: "${JOB_NAME}",
                 		selector: [$class: "SpecificBuildSelector", buildNumber: "${BUILD_NUMBER}"]
             		])
             		
                    def image = docker.build("${IMAGE_NAME}:${env.BUILD_ID}")
                }
            }
        }

        stage('Run Docker image') {
            steps {
                echo "-=- run Docker image -=-"
                sh "docker run -p 8080:8080 --network ci -e SERVICE_HOSTNAME=ci-income-predictor-service --name ${env.CONTAINER_NAME} -d ${IMAGE_NAME}:${env.BUILD_ID}"
            }
        }

        stage('Integration tests') {
            steps {
                echo "-=- execute integration tests -=-"
                echo "Not an executable project so no integration test phase needed"
            }
        }

        stage('Performance tests') {
            steps {
                echo "-=- execute performance tests -=-"
                echo "Not an executable project so no performance test phase needed"
            }
        }

        stage('Dependency vulnerability tests') {
            agent {
        		docker {
            		image 'maven:3.5.4-jdk-8'
            		args '--network ci --mount type=volume,source=ci-maven-home,target=/root/.m2'
        		}
    		}
            steps {
                echo "-=- run dependency vulnerability tests -=-"
                sh "mvn dependency-check:check"
            }
        }

        stage('Push Artifact') {
            steps {
                echo "-=- push Artifact -=-"
                withCredentials([usernamePassword(credentialsId: 'docker-hub', passwordVariable: 'DOCKERHUB_PASSWORD', usernameVariable: 'DOCKERHUB_USERNAME')]) {
                    sh "docker login -u ${DOCKERHUB_USERNAME} -p ${DOCKERHUB_PASSWORD}"
                    //sh "docker push ${IMAGE_NAME}:${env.BUILD_ID}"
                }
            }
        }
    }

    post {
        always {
            echo "-=- remove deployment -=-"
            sh "docker stop ${env.CONTAINER_NAME}"
        }
    }
}