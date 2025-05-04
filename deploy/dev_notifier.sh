#!/bin/bash

set -e

SERVICE_NAME="job-notifier"
NAMESPACE="default"
IMAGE="425999196557.dkr.ecr.us-east-1.amazonaws.com/dev/job-notifier:latest"

# Step 1: Get current active version (blue or green)
ACTIVE_VERSION=$(kubectl get svc $SERVICE_NAME -n $NAMESPACE -o jsonpath='{.spec.selector.version}')
echo "✅ Current active version: $ACTIVE_VERSION"

if [[ "$ACTIVE_VERSION" == "blue" ]]; then
  NEW_VERSION="green"
else
  NEW_VERSION="blue"
fi

echo "🔁 Switching to: $NEW_VERSION"

# Step 2: Patch the inactive deployment with new image
echo "📦 Updating image in $SERVICE_NAME-$NEW_VERSION deployment..."
kubectl set image deployment/$SERVICE_NAME-$NEW_VERSION $SERVICE_NAME=$IMAGE -n $NAMESPACE

# Step 3: Wait for rollout to complete
echo "⏳ Waiting for $NEW_VERSION rollout..."
kubectl rollout status deployment/$SERVICE_NAME-$NEW_VERSION -n $NAMESPACE

# Step 4: Switch the service to point to new version
echo "🔀 Updating service to use version=$NEW_VERSION"
kubectl patch svc $SERVICE_NAME -n $NAMESPACE -p "{\"spec\": {\"selector\": {\"app\": \"$SERVICE_NAME\", \"version\": \"$NEW_VERSION\"}}}"

echo "✅ Blue/Green switch complete. $SERVICE_NAME now serving version: $NEW_VERSION"