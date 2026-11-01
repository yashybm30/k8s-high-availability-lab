# Reproducible experiments

Create a disposable cluster: `kind create cluster --name ha-lab --config k8s/kind.yaml`.
Build `docker build -t ha-api:local .`, then `kind load docker-image ha-api:local --name ha-lab` and `kubectl apply -f k8s/lab.yaml`.
Install metrics-server using its official installation instructions; for kind only, configure its kubelet certificate handling as documented by metrics-server. Confirm `kubectl top pods -n ha-lab` works before interpreting HPA results. An ingress controller is optional; `kubectl port-forward -n ha-lab service/api 3000:80` provides direct access but pins load to one selected pod, so it does not demonstrate service load balancing. For scale testing run k6 from inside the cluster or expose the Service using an ingress.

Run `k6 run scripts/load.js` against that service and watch `kubectl get hpa,pods -n ha-lab -w`. Save the k6 summary and HPA observations in `results/`.

Choose a worker without Redis and run `bash scripts/drain.sh ha-lab-worker`. A drain of the worker holding the singleton Redis is expected to block due to its PDB. This demonstrates eviction protection, **not Redis high availability**. Node failure can still lose the in-memory counter. Replace Redis with a managed HA deployment and persistence for production.

Delete an API pod during load and record error ratio and readiness convergence. Stop Redis and verify `/health/live` stays 200 while `/health/ready` returns 503. Rolling deployment must retain a ready replica. Do not infer recovery time or scale-up success without recording an actual run.

Results: API/Redis integration is validated separately; Kubernetes drain, HPA, ingress, and sustained k6 experiments require a running cluster and are not pre-certified by this document.
