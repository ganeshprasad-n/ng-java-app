pipeline {
    agent any
    
    // ═══════════════════════════════════════════════════════════
    // Build Tools Configuration
    // ═══════════════════════════════════════════════════════════
    tools {
        maven 'Maven-3.8.9'  // Must match Jenkins Global Tool Configuration
        jdk 'JDK-11'         // Must match Jenkins Global Tool Configuration
    }
    
    // ═══════════════════════════════════════════════════════════
    // Pipeline Parameters
    // ═══════════════════════════════════════════════════════════
    parameters {
        choice(
            name: 'ENVIRONMENT',
            choices: ['dev', 'staging', 'production'],
            description: 'Select target deployment environment'
        )
    }
    
    // ═══════════════════════════════════════════════════════════
    // Environment Variables
    // ═══════════════════════════════════════════════════════════
    environment {
        // Repository URLs (SSH format)
        APP_REPO = 'git@github.com:ganeshprasad-n/ng-java-app.git'
        CONFIG_REPO = 'git@github.com:ganeshprasad-n/ng-java-app-config.git'
        
        // Server Configuration
        APP_SERVER_HOST = 'app-server'  // SSH hostname from ~/.ssh/config
        APP_SERVER_IP = '10.115.108.191'  // For display purposes only
        DEPLOY_USER = 'deploy'
        
        // Build Metadata
        BUILD_TIME = sh(script: "date '+%Y-%m-%d %H:%M:%S'", returnStdout: true).trim()
        PROJECT_NAME = 'VProfile'
    }
    
    // ═══════════════════════════════════════════════════════════
    // Pipeline Stages
    // ═══════════════════════════════════════════════════════════
    stages {
        
        // ───────────────────────────────────────────────────────
        // Stage 1: Display Build Information
        // ───────────────────────────────────────────────────────
        stage('Environment Info') {
            steps {
                script {
                    echo '═══════════════════════════════════════════════════════'
                    echo "🚀 ${PROJECT_NAME} CI/CD Pipeline"
                    echo '═══════════════════════════════════════════════════════'
                    echo "Environment     : ${params.ENVIRONMENT}"
                    echo "Build Number    : #${BUILD_NUMBER}"
                    echo "Build Time      : ${BUILD_TIME}"
                    echo "Branch          : jenkins"
                    echo "Deploy Target   : ${DEPLOY_USER}@${APP_SERVER_HOST}"
                    echo "App Server IP   : ${APP_SERVER_IP}"
                    echo '═══════════════════════════════════════════════════════'
                }
            }
        }
        
        // ───────────────────────────────────────────────────────
        // Stage 2: Verify Build Tools
        // ───────────────────────────────────────────────────────
        stage('Verify Tools') {
            steps {
                echo '🔍 Verifying build tool versions...'
                sh '''
                    echo "══════════════════════════════════"
                    echo "Java Version:"
                    java -version
                    echo ""
                    echo "══════════════════════════════════"
                    echo "Maven Version:"
                    mvn --version
                    echo ""
                    echo "══════════════════════════════════"
                    echo "Git Version:"
                    git --version
                    echo "══════════════════════════════════"
                '''
            }
        }
        
        // ───────────────────────────────────────────────────────
        // Stage 3: Checkout Application Code
        // ───────────────────────────────────────────────────────
        stage('Checkout Application') {
            steps {
                echo '📥 Checking out application code from jenkins branch...'
                checkout([$class: 'GitSCM',
                    branches: [[name: '*/jenkins-local']],
                    extensions: [[$class: 'RelativeTargetDirectory',
                        relativeTargetDir: 'app']],
                    userRemoteConfigs: [[
                        url: env.APP_REPO,
                        credentialsId: 'github-ssh-key'
                    ]]
                ])
                sh '''
                    echo "✅ Application code checked out"
                    ls -la app/ | head -10
                '''
            }
        }
        
        // ───────────────────────────────────────────────────────
        // Stage 4: Checkout Configuration Repository
        // ───────────────────────────────────────────────────────
        stage('Checkout Configuration') {
            steps {
                echo "🔐 Checking out ${params.ENVIRONMENT} configuration..."
                checkout([$class: 'GitSCM',
                    branches: [[name: '*/jenkins-local']],
                    extensions: [[$class: 'RelativeTargetDirectory',
                        relativeTargetDir: 'config']],
                    userRemoteConfigs: [[
                        url: env.CONFIG_REPO,
                        credentialsId: 'github-ssh-key'
                    ]]
                ])
                sh '''
                    echo "✅ Configuration repository checked out"
                    echo "Available environments:"
                    ls -la config/environments/
                '''
            }
        }
        
        // ───────────────────────────────────────────────────────
        // Stage 5: Inject Environment Configuration
        // ───────────────────────────────────────────────────────
        stage('Inject Configuration') {
            steps {
                script {
                    echo "📋 Injecting ${params.ENVIRONMENT} configuration..."
                    sh """
                        # Verify config file exists
                        if [ ! -f config/environments/${params.ENVIRONMENT}/application.properties ]; then
                            echo "❌ Error: Configuration file not found!"
                            exit 1
                        fi
                        
                        # Copy environment-specific config
                        cp config/environments/${params.ENVIRONMENT}/application.properties \
                           app/src/main/resources/application.properties
                        
                        # Verify injection WITHOUT exposing secrets
                        echo "✅ Configuration injected successfully"
                        echo "Config file contains \$(grep -c '=' app/src/main/resources/application.properties) properties"
                        echo "Database configured: \$(grep -q 'jdbc.url' app/src/main/resources/application.properties && echo 'Yes' || echo 'No')"
                    """
                }
            }
        }
        
        // ───────────────────────────────────────────────────────
        // Stage 6: Build WAR File
        // ───────────────────────────────────────────────────────
        stage('Build Application') {
            steps {
                dir('app') {
                    echo '🔨 Building WAR file with Maven...'
                    sh '''
                        # Clean and build
                        mvn clean install -DskipTests
                        
                        # Verify WAR file
                        echo ""
                        echo "✅ Build completed successfully"
                        echo "════════════════════════════════════════"
                        echo "Build Artifacts:"
                        ls -lh target/*.war
                        echo ""
                        echo "WAR File Details:"
                        file target/*.war
                        echo "════════════════════════════════════════"
                    '''
                }
            }
        }
        
        // ───────────────────────────────────────────────────────
        // Stage 7: Archive Build Artifacts
        // ───────────────────────────────────────────────────────
        stage('Archive Artifacts') {
            steps {
                dir('app') {
                    echo '📦 Archiving build artifacts...'
                    archiveArtifacts artifacts: 'target/*.war', 
                                     fingerprint: true,
                                     allowEmptyArchive: false
                    echo '✅ Artifacts archived in Jenkins'
                }
            }
        }
        
        // ───────────────────────────────────────────────────────
        // Stage 8: Deploy to Target Environment
        // ───────────────────────────────────────────────────────
        stage('Deploy to Environment') {
            when {
                expression { params.ENVIRONMENT == 'dev' }
            }
            steps {
                script {
                    echo '═══════════════════════════════════════════════════════'
                    echo "🚀 Deploying to ${params.ENVIRONMENT} environment"
                    echo "Target: ${DEPLOY_USER}@${APP_SERVER_HOST} (${APP_SERVER_IP})"
                    echo '═══════════════════════════════════════════════════════'
                    
                    // Use app-server-deploy-key for deployment
                    sshagent(['app-server-deploy-key']) {
                        sh """
                            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                            echo "Step 1/6: Stopping Tomcat service..."
                            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                            ssh -o StrictHostKeyChecking=no ${DEPLOY_USER}@${APP_SERVER_HOST} \
                                'sudo systemctl stop tomcat9'
                            echo "✅ Tomcat stopped"
                            
                            echo ""
                            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                            echo "Step 2/6: Copying WAR file to app server..."
                            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                            scp -o StrictHostKeyChecking=no \
                                app/target/vprofile-v2.war \
                                ${DEPLOY_USER}@${APP_SERVER_HOST}:/tmp/
                            echo "✅ WAR file copied"
                            
                            echo ""
                            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                            echo "Step 3/6: Cleaning old deployment..."
                            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                            ssh -o StrictHostKeyChecking=no ${DEPLOY_USER}@${APP_SERVER_HOST} \
                                'sudo rm -rf /opt/tomcat9/webapps/ROOT*'
                            echo "✅ Old deployment removed"
                            
                            echo ""
                            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                            echo "Step 4/6: Deploying new WAR file..."
                            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                            ssh -o StrictHostKeyChecking=no ${DEPLOY_USER}@${APP_SERVER_HOST} '
                                sudo mv /tmp/vprofile-v2.war /opt/tomcat9/webapps/ROOT.war
                                sudo chown tomcat:tomcat /opt/tomcat9/webapps/ROOT.war
                            '
                            echo "✅ WAR deployed"
                            
                            echo ""
                            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                            echo "Step 5/6: Starting Tomcat service..."
                            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                            ssh -o StrictHostKeyChecking=no ${DEPLOY_USER}@${APP_SERVER_HOST} \
                                'sudo systemctl start tomcat9'
                            echo "✅ Tomcat started"
                            
                            echo ""
                            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                            echo "Step 6/6: Waiting for deployment (30 seconds)..."
                            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                            sleep 30
                            
                            echo ""
                            echo "Verifying deployment..."
                            ssh -o StrictHostKeyChecking=no ${DEPLOY_USER}@${APP_SERVER_HOST} \
                                'sudo ls -la /opt/tomcat9/webapps/ | grep ROOT'
                            
                            echo ""
                            echo "✅ Deployment completed successfully!"
                        """
                    }
                }
            }
        }
    }
    
    // ═══════════════════════════════════════════════════════════
    // Post-Build Actions
    // ═══════════════════════════════════════════════════════════
    post {
        success {
            script {
                echo ''
                echo '═══════════════════════════════════════════════════════'
                echo '✅ Pipeline Completed Successfully!'
                echo '═══════════════════════════════════════════════════════'
                echo "Project         : ${PROJECT_NAME}"
                echo "Environment     : ${params.ENVIRONMENT}"
                echo "Build Number    : #${BUILD_NUMBER}"
                echo "Build Time      : ${BUILD_TIME}"
                if (params.ENVIRONMENT == 'dev') {
                    echo "Application URL : http://${APP_SERVER_IP}:8080"
                }
                echo '═══════════════════════════════════════════════════════'
                echo ''
            }
        }
        failure {
            script {
                echo ''
                echo '═══════════════════════════════════════════════════════'
                echo '❌ Pipeline Failed!'
                echo '═══════════════════════════════════════════════════════'
                echo "Environment     : ${params.ENVIRONMENT}"
                echo "Build Number    : #${BUILD_NUMBER}"
                echo "Failed Stage    : Check console output above"
                echo '═══════════════════════════════════════════════════════'
                echo ''
            }
        }
        always {
            echo '🧹 Cleaning workspace...'
            cleanWs()
        }
    }
}