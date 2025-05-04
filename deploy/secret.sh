# Delete the old secret (if it exists)
kubectl delete secret job-secrets --ignore-not-found

# Create a new one with updated values
kubectl create secret generic job-secrets \
  --from-literal=DB_USER=user \
  --from-literal=DB_PASSWORD=password \
  --from-literal=DB_HOST=jdatabase.cierwznyw7em.us-east-1.rds.amazonaws.com \
  --from-literal=DB_PORT=3306 \
  --from-literal=DB_NAME=jdatabase \
  --from-literal=SLACK_WEBHOOK_URL=https://hooks.slack.com/services/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 \
  --from-literal=NOTIFIER_URL=http://dev.notifier.sureshraja.live \
  --from-literal=BACKEND_URL=http://dev.backend.sureshraja.live \
  --from-literal=FRONTEND_URL=http://dev.app.sureshraja.live

kubectl apply -f infra/dev/job-backend/deployment-green.yaml


kubectl apply -f infra/job-frontend/service.yaml
kubectl rollout restart deployment job-frontend-blue