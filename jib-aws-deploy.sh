#!/bin/sh

#================#
# Jib and deploy #
#================#
# Tool for building Docker container with Gradle and jib, and deploying to AWS ECS
#
# Requirements:
# * aws-cli
#
# Usage:
#  $ ./jib-aws-deploy needToLogin buildParams serviceANR clusterANR checkPeriod
# * needToLogin: contains yes if need to login before push into Docker registry
# * buildParams: comma-separated build options
# * serviceANR: anr link to the service
# * clusterANR: anr link to the cluster
# * checkPeriod: health check grace period in seconds for the service

if [ $1 -eq "yes"]; then
    $(aws ecr get-login --no-include-email --region eu-central-1)
    if [ $? -eq 1 ]; then
        echo "An error occurred while logging in to aws"
        exit 1
    fi
fi

if ! ./gradlew -P$2 jib; then
  echo "An error occurred while building the Docker image"
  exit 2
fi

if ! aws ecs update-service --cluster $3 --service $4 --health-check-grace-period-seconds $5 --force-new-deployment; then
  echo "An error occurred while restarting the service"
  exit 3
fi
