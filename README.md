# Ecole42Paris_Inception_Of_Things

A 42 project for learning Kubernetes. Using Vagrant / K3s / K3d / Argo CD,
it stands up lightweight clusters and builds up step by step to Ingress routing
and GitOps deployment.

| Part | Goal | Key tools |
|------|------|-----------|
| **P1** | A 2-node K3s cluster (server + worker/agent) on Vagrant VMs | Vagrant, VirtualBox, K3s |
| **P2** | 3 apps on a single K3s server with host-based Ingress routing | K3s, Ingress (Traefik) |
| **P3** | Install Argo CD on a K3d cluster and sync it with a Git repo (GitOps) | Docker, K3d, kubectl, Argo CD |

---

## Environment

- **Windows WSL2**
  - WSL2 uses vt-x / Hyper-V based virtualization. To run nested VMs you must
    **disable** the features that hold Hyper-V.
- **VirtualBox 7.1** + Ubuntu 22.04 LTS
- **Nested VirtualBox 7.1** + **Vagrant 2.4.6**
  - Verify with `kvm-ok` that the image supports virtualization.
- References
  - [Install VirtualBox](https://www.virtualbox.org/wiki/Linux_Downloads#:~:text=Debian%2Dbased%20Linux%20distributions)
  - [Install Vagrant](https://developer.hashicorp.com/vagrant/install#:~:text=Download-,Linux,-Package%20manager)
  - Mismatched versions can push VirtualBox into a [guru meditation](https://askubuntu.com/questions/1521244/guru-meditation-on-virtualbox), so always check the versions.

> **Host-only network**: the local VirtualBox must have a Host-only network set up.
> Before running Vagrant, connect to the internet via NAT or a bridged adapter,
> then switch the configuration.

---

## P1 — Vagrant + K3s (Server / Worker)

Creates two VMs from the `bento/ubuntu-24.04` box and runs K3s over
`--flannel-iface eth1` (the private_network interface).

| Node | Role | IP |
|------|------|----|
| `ychunS` | K3s Server (controlplane) | `192.168.56.110` |
| `schaehunSW` | K3s Worker (agent) | `192.168.56.111` |

**How it works**
1. The server node installs K3s and generates a node-token.
2. The server shares the token on port 8080 from `/tmp/token-share` via Python's `http.server`.
3. The worker node polls `http://192.168.56.110:8080/node-token`, then joins the
   cluster using `K3S_URL=https://192.168.56.110:6443`.

**Run**
```bash
cd p1
vagrant up
vagrant ssh ychunS
kubectl get nodes -o wide   # both nodes showing Ready means success
```

- K3s is installed with `K3S_KUBECONFIG_MODE="644"` so the vagrant user can read the kubeconfig.
- Config references: [Configuration file](https://docs.k3s.io/installation/configuration#configuration-file),
  [Server](https://docs.k3s.io/cli/server), [Agent](https://docs.k3s.io/cli/agent)

---

## P2 — K3s Single Server + Ingress routing

Deploys 3 apps on a single server (`ychunS`, `192.168.56.110`) and routes
to different apps based on the Ingress **Host header**.

| Host | Service | Replicas |
|------|---------|----------|
| `app1.com` | app1 | 1 |
| `app2.com` | app2 | 3 |
| `app3.com` | app3 | 1 |
| (default, no host) | app3 | 1 |

- All three apps use the `paulbouwer/hello-kubernetes:1.10` image, container port 8080 → service port 80.
- During provisioning, `ingress.yaml` (Ingress + Service + Deployment) is applied automatically via `kubectl apply`.

**Run & test**
```bash
cd p2
vagrant up

# From the host machine, test access by setting the Host header
curl -H "Host: app1.com" http://192.168.56.110
curl -H "Host: app2.com" http://192.168.56.110
curl -H "Host: app3.com" http://192.168.56.110
curl http://192.168.56.110            # no host → app3
```

> To test from a browser, add `192.168.56.110 app1.com app2.com app3.com`
> to the host's `/etc/hosts`.

---

## P3 — K3d + Argo CD (GitOps)

Creates a K3d cluster on top of Docker, installs Argo CD, and continuously
syncs a Git repository into the cluster.

**What `configure.sh` does**
1. Install Docker (if not present)
2. Install K3d
3. Install kubectl
4. Create K3d cluster `iot` — 1 server / 2 agents, LB ports `8888` and `8080:80`
5. Create the `argocd` and `dev` namespaces
6. Install Argo CD, then apply `argocd.yaml` (the Application)
7. Port-forward `argocd-server` to `9090:443`
8. Print the initial admin password (ID: `admin`)

**Argo CD Application (`argocd.yaml`)**
- Name: `wil-playground`, namespace: `argocd`
- Source repo: `https://github.com/pfclakr/ychun_iot_chaehun.git` (path `.`, `HEAD`)
- Destination: the `dev` namespace inside the cluster
- `syncPolicy.automated`: `selfHeal: true`, `prune: true` — automatic sync

**Run**
```bash
cd p3
./configure.sh          # prints the admin password on the last line

# Open: https://localhost:9090  (user: admin)
kubectl get pods -n dev # check that the synced app appears in the dev namespace
```

> If the user is not in the docker group, `configure.sh` adds them and reboots
> automatically. Re-run the script after the reboot.

**Application repo (`p3/github`)**
- Linked as a Git submodule: `git@github.com:PfClaKr/ychun_iot_chaehun.git`
- To pull the submodule on the initial clone:
  ```bash
  git clone --recurse-submodules <this-repo>
  # or, if already cloned
  git submodule update --init --recursive
  ```

---

## Directory structure

```
.
├── p1/
│   └── Vagrantfile          # K3s server + worker, 2 nodes
├── p2/
│   └── Vagrantfile          # K3s single server + Ingress + 3 apps
├── p3/
│   ├── configure.sh         # Install Docker/K3d/kubectl/Argo CD & deploy
│   ├── argocd.yaml          # Argo CD Application definition
│   └── github/              # Deploy target app repo (git submodule)
├── .gitmodules
└── README.md
```
