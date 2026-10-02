# K8sQuest

[K8sQuest](https://github.com/Manoj-engineer/k8squest) is a game where every level hands you a broken
Kubernetes setup on a local kind cluster, and you fix it with kubectl. You read the briefing, dig
around, fix it, and the game checks the result. There are hints if you get stuck and a short debrief
after each level.

I did it after [Kubernetes The Hard Way](../kthw) and finished the first three worlds, levels 1 to 30.

## Levels

### World 1: basics (levels 1 to 10)

A pod in CrashLoopBackOff, a deployment with zero replicas,
ImagePullBackOff, a pod stuck in Pending, labels and selectors that don't match, wrong ports,
a broken sidecar, finding the cause in the logs, an init container that never finishes, the wrong
namespace.

### World 2: deployments and scaling (levels 11 to 20)

Rolling back a bad release, liveness and readiness
probes, HPA, rollouts, a PodDisruptionBudget, blue/green and canary deployments, a StatefulSet,
a ReplicaSet.

### World 3: networking (levels 21 to 30)

Service selectors, NodePort, DNS, Ingress, NetworkPolicy, session
affinity, reaching a service in another namespace, Endpoints, LoadBalancer, headless services.

## The commands I used most

Almost every level started the same way:

```bash
kubectl get pods -A -o wide
kubectl describe pod <pod>          # events at the bottom say what's wrong
kubectl logs <pod> -c <container> --previous
kubectl get events --sort-by=.lastTimestamp
kubectl get endpoints <service>     # empty = selector matches no pod
kubectl rollout status deployment/<name>
kubectl rollout undo deployment/<name>
kubectl run tmp --rm -it --image=busybox -- sh   # DNS and network checks
```

The biggest lesson from these 30 levels: when something doesn't work, the cluster almost always says
why. It's in the events, the pod status or an empty endpoints list, you just have to know where to
look.
