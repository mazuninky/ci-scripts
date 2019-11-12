#!/bin/sh

####################
## Jib and deploy ##
####################
# Tool for building Docker container with Gradle and jib, and deploying to AWS ECS
#
# Requirements:
# * aws-cli
# * amazon-ecr-credential-helper
#
# Usage:
#  $ ./jib-aws-deploy needToLogin serviceANR clusterANR checkPeriod [buildParams]
# * needToLogin: contains yes if need to login before push into Docker registry
# * serviceANR: anr link to the service
# * clusterANR: anr link to the cluster
# * checkPeriod: health check grace period in seconds for the service
# * buildParams: comma-separated build options

if [ "$1" = "yes" ]; then
  $(aws ecr get-login --no-include-email --region eu-central-1)
  if [ $? -eq 1 ]; then
    echo "An error occurred while logging in to aws"
    exit 1
  fi
fi

if [ -z "$5" ]; then
  ./gradlew jib
else
  ./gradlew -P$5 jib
fi

if [ $? -eq 1 ]; then
  echo "An error occurred while building the Docker image"
  exit 2
fi

if ! aws ecs update-service --cluster "$2" --service "$3" --health-check-grace-period-seconds "$4" --force-new-deployment; then
  echo "An error occurred while restarting the service"
  exit 3
fi
