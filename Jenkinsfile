pipeline {

  agent {
    node {
      label 'maven'
    }

  }
  stages {
    stage('git-clone') {
      agent none
      steps {
        git(url: 'https://github.com/Sun-V/MMS.git', credentialsId: 'github', changelog: true, poll: false)
      }
    }

    stage('maven-test') {
      agent none
      steps {
        container('maven') {
          sh 'mvn -version'
        }

      }
    }

    stage('maven-deploy') {
      agent none
      steps {
        container('maven') {
          sh 'mvn -Dmaven.test.skip=true -Dfile.encoding=UTF-8 -DsourceEncoding=UTF-8 clean install -U'
        }

      }
    }

    stage('code-check') {
      agent none
      steps {
        container('maven') {
          withCredentials([string(credentialsId : 'sonar' ,variable : 'SONAR_TOKEN' ,)]) {
            withSonarQubeEnv('sonar') {
              sh 'mvn sonar:sonar -Dsonar.projectKey=mms  -Dsonar.host.url=https://sonar.xxx.tech -Dsonar.login=$SONAR_TOKEN'
            }

          }

          timeout(unit: 'HOURS', activity: true, time: 1) {
            waitForQualityGate 'true'
          }

        }

      }
    }

    stage('build & push') {
      agent none
      steps {
        script {
          env.COMMIT_ID = sh(returnStdout: true, script: "git log -n 1 --pretty=format:'%h'").trim()
          env.BUILD_FLAG="${COMMIT_ID}"
        }

        container('maven') {
          sh 'docker build -f Dockerfile -t $REGISTRY/$HARBOR_NAMESPACE/$APP_NAME:SNAPSHOT-$BRANCH_NAME-$BUILD_FLAG .'

          sh 'echo $HARBOR_CREDENTIAL_PSW | docker login $REGISTRY -u \'robot$robot-s\' --password-stdin'
          sh 'docker push $REGISTRY/$HARBOR_NAMESPACE/$APP_NAME:SNAPSHOT-$BRANCH_NAME-$BUILD_FLAG'

        }

      }
    }

    stage('deploy2k8s') {
      agent none
      steps {
        kubernetesDeploy(enableConfigSubstitution: true, deleteResource: false, kubeconfigId: 'kubeconfig', configs: 'deploy/**')
      }
    }

  }

  environment {
    BRANCH_NAME = 'dev'
    APP_NAME = 'mms'
    REGISTRY = 'harbor.xxx.tech'

    HARBOR_NAMESPACE = 'test'
    HARBOR_CREDENTIAL = credentials('harbor-s')
  }

}
