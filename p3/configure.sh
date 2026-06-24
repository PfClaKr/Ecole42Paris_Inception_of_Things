#!/usr/bin/env bash


# 1. Installing docker

if command -v docker &>/dev/null; then
	echo "docker is already installed."
else
	echo "1. Installing docker"
	sudo apt update -y
	sudo apt install -y ca-certificates curl
	sudo install -m 0755 -d /etc/apt/keyrings
	sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
	sudo chmod a+r /etc/apt/keyrings/docker.asc

	# Add the repository to Apt sources:
	sudo tee /etc/apt/sources.list.d/docker.sources > /dev/null <<EOF
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: $(. /etc/os-release && echo "$VERSION_CODENAME")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF
	sudo apt update -y
	sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
	sudo systemctl enable --now docker
	if id -nG | grep -q "docker"; then 
		echo "User is in docker group"
	else
		sudo usermod -aG docker $USER
		echo "User add to docker group, please re run this script. restarting in 3 sec ..."
		sleep 3
		systemctl reboot
	fi
	docker --version

fi
# 2. Installing k3d
if command -v k3d &>/dev/null; then
	echo "k3d is already installed."
else
	echo "2. Installing k3d"
	curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
	k3d version
fi
# 3. Installing kubectl

if command -v kubectl &>/dev/null; then
	echo "kubectl is already installed."
else
	echo "3. Installing kubectl"
	os=$(uname -s | tr '[:upper:]' '[:lower:]')
	curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/${os}/amd64/kubectl"
	chmod +x kubectl
	sudo mv kubectl /usr/bin/
fi

# 4. create k3d cluster
echo "4. create k3d cluster"
k3d cluster create iot --servers 1 --agents 2 --api-port 6550 --port "8888:8888@loadbalancer" --port "8080:80@loadbalancer"

# 5. create namespace k3s
echo "5. create namespace k3s"
kubectl create namespace argocd
kubectl create namespace dev

# 6. Installing argocd
echo "6. Installing argocd"
kubectl apply -n argocd --server-side --force-conflicts -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

kubectl rollout status deployment/argocd-server -n argocd --timeout=300s

kubectl apply -f argocd.yaml

# 7. Open the port with port-forwarding
echo "7. Open the port"
kubectl port-forward -n argocd svc/argocd-server 9090:443 >/dev/null 2>&1 &
sleep 2

# 8. Get the password argocd. Id will be admin
echo "8. Argocd password"
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
echo
