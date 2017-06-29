#!groovy
@Library('jenkins-library') _

def dockerHubCredentialId = "dockerhub"
def props
def privateKey


node("master") {

    privateKey = env.PRIVATE_KEY
}

node() {

    stage("Checkout") {

        checkout scm

    }

    stage("Setup Environment"){

        echo "Setup stage"
        props=getProperties("${env.WORKSPACE}/auto-vault/environment.env")
        props.setProperty("COMPOSE_PROJECT_NAME", "envtritonextprod")
        props.setProperty("PRIVATE_KEY", privateKey)
        configureTestEnv(props, env)

    }

    stage("Prisebox Update") {

        docker.withRegistry('https://index.docker.io/v1/', "${dockerHubCredentialId}") {

            priseboxUpdate(props)

        }

    }

}