# Prefill the bash history with some useful commands and set a motd message to remind the user of the most important commands

cat <<'EOF' >> /etc/skel/.bash_history
az login
az account set --subscription <subscription name or id>
az aks get-credentials --name <aks cluster name> --resource-group <resource group name>
kubectl get pods -A
helm plugin install https://github.com/databus23/helm-diff
git clone https://<pat>@github.com/Unique-AG/monorepo.git && cd monorepo
helmfile -e <env>-prod -f helmfiles/<file>.yaml diff
helmfile -e <env>-prod -f helmfiles/<file>.yaml --selector name=<release> diff
EOF

cat <<'EOF' >> /etc/motd
╭――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――╮
│ Hi and welcome back! Remember these commands to bootstrap the jumpbox for initial use:     │
│                                                                                            │
│   az login                                                                                 │
│   az account set --subscription <subscription name or id>                                  │
│   az aks get-credentials --name <aks cluster name> --resource-group <resource group name>  │
│   kubectl get pods -A # will prompt you to login                                           │
│   helm plugin install https://github.com/databus23/helm-diff                               │
│   git clone https://<pat>@github.com/Unique-AG/monorepo.git && cd monorepo                 │
│   helmfile -e <env>-prod -f helmfiles/<file>.yaml diff                                     │
│   helmfile -e <env>-prod -f helmfiles/<file>.yaml --selector name=<release> diff           │                                                   │
│                                                                                            │
│ Here are pseudo-commands with a fictional cluster "twookie" to help you:                   │
│                                                                                            │
│   az account set --subscription lz-twookie-prod                                            │
│   az aks get-credentials --name uq-twookie-prod --resource-group uq-twookie-prod           │
│   helmfile -e twookie-prod -f helmfiles/<file>.yaml diff                                   │
╰――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――╯

EOF