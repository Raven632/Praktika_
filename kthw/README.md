# Kubernetes The Hard Way

My run through [Kubernetes The Hard Way](https://github.com/kelseyhightower/kubernetes-the-hard-way)
during the internship: a Kubernetes cluster put together by hand, without kubeadm or any other
installer, on four VMs in the Proxmox lab.

| VM | What runs there |
|---|---|
| jumpbox | admin machine, all certificates and configs are made here |
| server | control plane: etcd, kube-apiserver, kube-controller-manager, kube-scheduler |
| node-0, node-1 | workers: containerd, kubelet, kube-proxy, CNI plugins |

## Steps

1. Set up the jumpbox and downloaded the binaries: Kubernetes, etcd, containerd, runc, CNI plugins.
2. Gave the VMs hostnames and an `/etc/hosts` table, so they find each other by name.
3. Made my own CA with openssl and issued a certificate for every component: admin, one per kubelet,
   kube-proxy, controller manager, scheduler, API server and the service account key.
4. Wrote a kubeconfig for each component, all pointing at the API server.
5. Generated an encryption key, so Secrets are stored encrypted in etcd.
6. Started etcd, then the control plane, all as systemd services on the server.
7. Started the workers: containerd, kubelet, kube-proxy and the CNI bridge config.
8. Set up kubectl on the jumpbox for remote access.
9. Added the routes for the pod networks by hand.
10. Ran the smoke test: a Secret is unreadable in etcd (checked with `hexdump`), a deployment comes up,
    port-forward, logs and exec work, and a NodePort service answers.

## What stuck with me

- Every component logs in with its own certificate, and the names inside it matter. A kubelet's
  certificate has to say `system:node:node-0`, otherwise the API server doesn't accept it as that
  node.
- Nothing starts without etcd, and the API server is the only thing that talks to it.
- Traffic between pods on different nodes isn't automatic. Normally the CNI plugin sets up the routes;
  here you add them yourself, and if one is missing, the pods simply can't reach each other.
- kubeadm or k3s do all of this in a minute. Having done it by hand once, error messages from a
  cluster make a lot more sense. That's why I moved on to [K8sQuest](../k8squest) right after.
