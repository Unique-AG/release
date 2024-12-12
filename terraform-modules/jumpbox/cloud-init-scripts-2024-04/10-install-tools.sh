# Note: `-o DPkg::Lock::Timeout=300` is added to teh apt-get commands since during startup of a new VM, multiple scripts can run at the same time and cause apt-get to fail with a lock error
apt-get -o DPkg::Lock::Timeout=300 update
apt-get -o DPkg::Lock::Timeout=300 upgrade -y
apt-get -o DPkg::Lock::Timeout=300 install -y apt-transport-https unzip postgresql-client-common postgresql-client-14 bash-completion 

# add kubectl repo
KUBECTL_VERSION=1.29
curl -fsSL https://pkgs.k8s.io/core:/stable:/v$KUBECTL_VERSION/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v$KUBECTL_VERSION/deb/ /" | tee /etc/apt/sources.list.d/kubernetes.list

# add azure-cli repo
DISTRO_CODENAME=$(lsb_release -cs)
curl -sLS https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /etc/apt/keyrings/microsoft.gpg
echo "deb [arch=`dpkg --print-architecture` signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/azure-cli/ $DISTRO_CODENAME main" > /etc/apt/sources.list.d/azure-cli.list

# add helm repo
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor -o /usr/share/keyrings/helm.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" > /etc/apt/sources.list.d/helm-stable-debian.list

# install kubctl, azure-cli, helm
apt-get -o DPkg::Lock::Timeout=300 update
apt-get -o DPkg::Lock::Timeout=300 install -y kubectl azure-cli helm

# install kubelogin
KUBELOGIN_VERSION=0.0.30
wget -q https://github.com/Azure/kubelogin/releases/download/v${KUBELOGIN_VERSION}/kubelogin-linux-amd64.zip -O /tmp/kubelogin.zip;
unzip /tmp/kubelogin.zip -d /tmp/kubelogin
cp /tmp/kubelogin/bin/linux_amd64/kubelogin /usr/local/bin/kubelogin

# install kustomize
KUSTOMIZE_VERSION=5.1.0
wget -q https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv${KUSTOMIZE_VERSION}/kustomize_v${KUSTOMIZE_VERSION}_linux_amd64.tar.gz -O /tmp/kustomize.tar.gz;
tar -C /usr/local/bin -xpf /tmp/kustomize.tar.gz

# install helmfile
HELMFILE_VERSION=0.155.0
wget -q https://github.com/helmfile/helmfile/releases/download/v${HELMFILE_VERSION}/helmfile_${HELMFILE_VERSION}_linux_amd64.tar.gz -O /tmp/helmfile.tar.gz;
tar -C /usr/local/bin -xpf /tmp/helmfile.tar.gz

# install k9s
K9S_VERSION=0.27.4
wget -q https://github.com/derailed/k9s/releases/download/v${K9S_VERSION}/k9s_Linux_amd64.tar.gz -O /tmp/k9s.tar.gz;
tar -C /usr/local/bin -xpf /tmp/k9s.tar.gz


# setup bash completions
for tool in kubectl kubelogin kustomize helm helmfile k9s; do
    $tool completion bash > /etc/bash_completion.d/$tool
done
