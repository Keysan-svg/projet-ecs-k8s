pipeline {
    agent any

    environment {
        HOME = "/var/lib/jenkins"
    }

    stages {
        stage('Validate') {
            steps {
                sh 'terraform fmt -check -recursive || true'
                sh 'terraform validate'
            }
        }

        stage('Plan') {
            steps {
                sh 'terraform plan -out=tfplan'
            }
        }

        stage('Approve') {
            steps {
                input message: 'Appliquer le deploiement ECS + Kubernetes ?'
            }
        }

        stage('Apply') {
            steps {
                sh 'terraform apply -input=false tfplan'
            }
        }
    }

    post {
        success {
            echo 'Deploiement ECS + Kubernetes termine avec succes.'
        }
        failure {
            echo 'Le pipeline a echoue. Verifier les logs ci-dessus.'
        }
    }
}
