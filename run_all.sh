#!/bin/bash
# ============================================================
#   GUESTBOOK FINAL PROJECT - COMPLETE RUN SCRIPT
#   IBM Kubernetes on SN Labs / Coursera
#   Run this in your SN Labs terminal: bash run_all.sh
# ============================================================

set -e   # stop on first error

# ─── Step 0: Detect your namespace ──────────────────────────
export MY_NAMESPACE=sn-labs-$USERNAME
echo ""
echo "=============================================="
echo "  YOUR NAMESPACE: $MY_NAMESPACE"
echo "=============================================="
echo ""

# ─── Step 1: Log in to IBM Cloud Container Registry ─────────
echo ">>> Logging into IBM Cloud Container Registry..."
ibmcloud cr login
ibmcloud cr region-set us-south

# ─── TASK 1: Show Dockerfile ─────────────────────────────────
echo ""
echo "====== TASK 1: Dockerfile (screenshot this) ======"
cat v1/Dockerfile

# ─── TASK 2: Build & Push v1 ─────────────────────────────────
echo ""
echo ">>> Building guestbook:v1 image..."
docker build -t us.icr.io/$MY_NAMESPACE/guestbook:v1 ./v1

echo ""
echo ">>> Pushing guestbook:v1 to registry..."
docker push us.icr.io/$MY_NAMESPACE/guestbook:v1

echo ""
echo "====== TASK 2: ibmcloud cr images (screenshot this) ======"
ibmcloud cr images

# ─── TASK 3: Show index.html v1 ──────────────────────────────
echo ""
echo "====== TASK 3: index.html v1 - title and h1 (screenshot this) ======"
grep -n "<title>\|<h1>" v1/index.html

# ─── TASK 4: Deploy & Create HPA ──────────────────────────────
echo ""
echo ">>> Applying deployment..."
# Substitute namespace into deployment file
sed "s|\$MY_NAMESPACE|$MY_NAMESPACE|g" deployment.yml > deployment_ready.yml
kubectl apply -f deployment_ready.yml

echo ""
echo ">>> Waiting for deployment to be ready..."
kubectl rollout status deployment/guestbook

echo ""
echo ">>> Creating Horizontal Pod Autoscaler..."
kubectl autoscale deployment guestbook --cpu-percent=5 --min=1 --max=10

sleep 5

echo ""
echo "====== TASK 4: HPA with 0/low replicas (screenshot this) ======"
kubectl get hpa guestbook

# ─── TASK 5: Load test to trigger autoscaling ────────────────
echo ""
echo "====== TASK 5: Starting load generator to trigger autoscaling ======"
echo ">>> The load generator will run for 3 minutes, then stop."
echo ">>> Watch replicas increase in the output below..."
echo ""

# Run load in background
kubectl run load-generator --image=busybox:1.28 --restart=Never -- \
  /bin/sh -c "for i in \$(seq 1 2000); do wget -q -O- http://guestbook:3000; done" 2>/dev/null || true

# Poll HPA for 3 minutes
for i in $(seq 1 18); do
  sleep 10
  echo "--- Poll $i/18 (every 10s) ---"
  kubectl get hpa guestbook
done

echo ""
echo "====== TASK 5: Screenshot the line above showing increased REPLICAS ======"

# Clean up load generator
kubectl delete pod load-generator --ignore-not-found=true

# ─── TASK 6: Build & Push v2 ─────────────────────────────────
echo ""
echo ">>> Building guestbook:v2 image..."
docker build -t us.icr.io/$MY_NAMESPACE/guestbook:v2 ./v2

echo ""
echo "====== TASK 6: Docker push v2 with digest (screenshot this) ======"
docker push us.icr.io/$MY_NAMESPACE/guestbook:v2

# ─── TASK 7: Update deployment to v2 ─────────────────────────
echo ""
echo ">>> Updating deployment.yml to use v2..."
sed "s|\$MY_NAMESPACE|$MY_NAMESPACE|g; s|guestbook:v1|guestbook:v2|g" deployment.yml > deployment_v2.yml

echo ""
echo "====== TASK 7: kubectl apply v2 deployment (screenshot this) ======"
kubectl apply -f deployment_v2.yml

kubectl rollout status deployment/guestbook

# ─── TASK 8: Show index.html v2 ──────────────────────────────
echo ""
echo "====== TASK 8: index.html v2 - title and h1 (screenshot this) ======"
grep -n "<title>\|<h1>" v2/index.html

# ─── TASK 9: Rollout history ─────────────────────────────────
echo ""
echo "====== TASK 9: Rollout history (screenshot this) ======"
kubectl rollout history deployment/guestbook

echo ""
echo "--- Revision 2 details ---"
kubectl rollout history deployment/guestbook --revision=2

# ─── TASK 10: Rollback & get ReplicaSets ─────────────────────
echo ""
echo ">>> Rolling back to v1..."
kubectl rollout undo deployment/guestbook

sleep 5

echo ""
echo "====== TASK 10: ReplicaSets after rollback (screenshot this) ======"
kubectl get rs

echo ""
echo "=============================================="
echo "  ALL TASKS COMPLETE!"
echo "  Check the output above for each task."
echo "=============================================="
