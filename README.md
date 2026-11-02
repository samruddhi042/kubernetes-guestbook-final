# 📒 Kubernetes Guestbook Application
### IBM DevOps & Software Engineering — Coursera Final Project

A full-stack Guestbook web application built with **Go**, containerized with **Docker**, and deployed on **IBM Cloud Kubernetes Service**. The project demonstrates real-world DevOps practices including container registry management, autoscaling, rolling updates, and rollbacks.

---

## 🛠️ Technologies Used

| Tool | Purpose |
|------|---------|
| **Go (Golang)** | Backend web server |
| **Docker** | Multi-stage image builds |
| **Kubernetes (kubectl)** | Container orchestration |
| **IBM Cloud Container Registry** | Private image registry (us.icr.io) |
| **Horizontal Pod Autoscaler (HPA)** | Auto-scale pods based on CPU |
| **IBM Skills Network Labs** | Cloud IDE + Kubernetes cluster |

---

## ⚙️ How It Works & Automation

```
Developer pushes code
        │
        ▼
  Docker builds image        ← Multi-stage build (Go → Ubuntu)
        │
        ▼
  Push to IBM Cloud Registry ← us.icr.io/sn-labs-samruddhicha/guestbook
        │
        ▼
  kubectl apply deployment   ← Kubernetes pulls image & runs pods
        │
        ▼
  HPA monitors CPU usage     ← Scales from 1 → 10 pods automatically
        │
        ▼
  Rolling Update to v2       ← Zero-downtime deployment
        │
        ▼
  Rollback if needed         ← kubectl rollout undo
```

- **HPA** watches CPU every 15s — if usage exceeds 5%, it spins up more pods (up to 10), and scales back down when load drops
- **Rolling Updates** replace pods one by one with zero downtime — old pods stay alive until new ones are ready
- **Rollbacks** instantly revert to the previous ReplicaSet if something goes wrong

---

## 📁 Folder Structure

```
kubernetes-guestbook-final/
├── v1/
│   ├── Dockerfile          ✅ Fixed multi-stage Dockerfile
│   └── index.html          ✅ Guestbook - v1
├── v2/
│   ├── Dockerfile          ✅ Same structure
│   └── index.html          ✅ Guestbook - v2
├── deployment.yml          ✅ With cpu: 5m / 2m
└── run_all.sh              ✅ Complete automation script
```

---

## 🚀 Key Commands

```bash
# Build & push image
docker build -t us.icr.io/$MY_NAMESPACE/guestbook:v1 ./v1/guestbook
docker push us.icr.io/$MY_NAMESPACE/guestbook:v1

# Deploy to Kubernetes
kubectl apply -f deployment.yml

# Enable autoscaling
kubectl autoscale deployment guestbook --cpu-percent=5 --min=1 --max=10

# Rolling update to v2
kubectl apply -f deployment.yml   # (after updating image tag to v2)

# View rollout history
kubectl rollout history deployment/guestbook

# Rollback to v1
kubectl rollout undo deployment/guestbook
```

---

## 📊 What Was Demonstrated

- ✅ Multi-stage Docker builds to minimize image size
- ✅ Private image registry management on IBM Cloud
- ✅ Kubernetes Deployments, Pods & Services
- ✅ Horizontal Pod Autoscaling (HPA) based on CPU metrics
- ✅ Zero-downtime Rolling Updates
- ✅ Deployment Rollback using ReplicaSets

---

*Completed as part of the **IBM DevOps and Software Engineering Professional Certificate** on Coursera.*
