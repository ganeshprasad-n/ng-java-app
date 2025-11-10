pipeline {
    agent any
    
    // Use the tools we configured in Jenkins
    tools {
        maven 'Maven-3.8.9'
        jdk 'JDK-11'
    }
    
    parameters {
        choice(
            name: 'ENVIRONMENT',
            choices: ['dev', 'staging', 'production'],
            description: 'Select deployment environment'
        )
    }
    
    environment {
        APP_REPO = 'https://github.com/ganeshprasad-n/ng-java-app.git'
        CONFIG_REPO = 'https://github.com/ganeshprasad-n/ng-java-app-config.git'
        APP_SERVER_IP = '10.115.108.112'  // Change to your app server IP
    }
    
    stages {
        stage('Tool Versions') {
            steps {
                echo '🔍 Checking build tool versions...'
                sh '''
                    echo "Java Version:"
                    java -version
                    echo ""
                    echo "Maven Version:"
                    mvn --version
                '''
            }
        }
        
        stage('Checkout Code') {
            steps {
                echo '📥 Checking out application code...'
                checkout([$class: 'GitSCM',
                    branches: [[name: '*/fedora-local']],
                    extensions: [[$class: 'RelativeTargetDirectory',
                        relativeTargetDir: 'app']],
                    userRemoteConfigs: [[url: env.APP_REPO]]
                ])
            }
        }
        
        stage('Checkout Config') {
            steps {
                echo '🔐 Checking out configuration...'
                checkout([$class: 'GitSCM',
                    branches: [[name: '*/main']],
                    extensions: [[$class: 'RelativeTargetDirectory',
                        relativeTargetDir: 'config']],
                    userRemoteConfigs: [[
                        url: env.CONFIG_REPO,
                        credentialsId: 'github-config-token'
                    ]]
                ])
            }
        }
        
        stage('Copy Config') {
            steps {
                echo "📋 Copying ${params.ENVIRONMENT} configuration..."
                sh """
                    cp config/environments/${params.ENVIRONMENT}/application.properties \
                       app/src/main/resources/application.properties
                    
                    echo "Config copied successfully"
                """
            }
        }
        
        stage('Build WAR') {
            steps {
                dir('app') {
                    echo '🔨 Building WAR file...'
                    sh 'mvn clean install -DskipTests'
                    
                    echo '📦 WAR file created:'
                    sh 'ls -lh target/*.war'
                }
            }
        }
        
        stage('Archive') {
            steps {
                dir('app') {
                    archiveArtifacts artifacts: 'target/*.war', fingerprint: true
                }
            }
        }
        
        stage('Deploy') {
            when {
                expression { params.ENVIRONMENT == 'dev' }
            }
            steps {
                echo '🚀 Deploying to app server...'
                sshagent(['app-server-ssh']) {
                    sh """
                        ssh -o StrictHostKeyChecking=no ngp@${APP_SERVER_IP} 'sudo systemctl stop tomcat9'
                        scp app/target/vprofile-v2.war ngp@${APP_SERVER_IP}:/tmp/
                        ssh ngp@${APP_SERVER_IP} '
                            sudo rm -rf /opt/tomcat9/webapps/ROOT*
                            sudo mv /tmp/vprofile-v2.war /opt/tomcat9/webapps/ROOT.war
                            sudo chown tomcat:tomcat /opt/tomcat9/webapps/ROOT.war
                            sudo systemctl start tomcat9
                        '
                        echo "Deployment complete!"
                    """
                }
            }
        }
    }
    
    post {
        success {
            echo "✅ Build successful for ${params.ENVIRONMENT} environment!"
        }
        failure {
            echo "❌ Build failed!"
        }
    }
}
