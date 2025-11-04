pipeline {
    
	agent any
	
	tools {
        maven "Maven3"
        jdk "OracleJDK17"
    }
	
    stages{
        stage ('fetch code') {
            steps {
                script {
                    echo "Pull source code from Git"
                    git branch: 'javaapp', url: 'https://github.com/seunayolu/JavaProject.git'
                }
            }
        }

        stage('Build'){
            steps {
                sh 'mvn clean install -DskipTests'
            }
            post {
                success {
                    echo 'Now Archiving...'
                    archiveArtifacts artifacts: '**/target/*.war'
                }
            }
        }

        stage('Unit Test'){
            steps {
                sh 'mvn test'
            }
        }

	    stage('Integration Test'){
            steps {
                sh 'mvn verify -DskipUnitTests'
            }
        }
		
        stage ('Checkstyle: Code Analysis'){
            steps {
                sh 'mvn checkstyle:checkstyle'
            }
            post {
                success {
                    echo 'Generated Analysis Result'
                }
            }
        }

        stage('SonarQube: Code Analysis') {
          
		  environment {
             scannerHome = tool 'sonar-scanner-6'
          }

          steps {
            withSonarQubeEnv('sonar-server') {
               sh '''${scannerHome}/bin/sonar-scanner -Dsonar.projectKey=thedevcloud \
                   -Dsonar.projectName=thedevcloud-app \
                   -Dsonar.projectVersion=1.0 \
                   -Dsonar.sources=src/ \
                   -Dsonar.java.binaries=target/test-classes/com/visualpathit/account/controllerTest/ \
                   -Dsonar.junit.reportsPath=target/surefire-reports/ \
                   -Dsonar.jacoco.reportsPath=target/jacoco.exec \
                   -Dsonar.java.checkstyle.reportPaths=target/checkstyle-result.xml'''
                } 
            }
        }

        stage ("Quality Gate") {
            steps {
                timeout(time: 10, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }   
            }
        }
    }
}