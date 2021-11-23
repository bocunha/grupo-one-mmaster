#!/bin/bash
## VARIAVEIS
TFPATH="$PWD"
CHKSGNOK=`grep "sg" $TFPATH/0-terraform/sg-ok.tf | wc -l`
CHAVESSH="/var/lib/jenkins/.ssh/grupo-one.pem"
AMIID="cat /tmp/k8s-ami-id.tmp"
###########################

#PEGA O ESTADO DO TERRAFORM
cd $TFPATH/2-ansible/01-k8s-install-masters_e_workers
read 
ANSIBLE_OUT=$(ansible-playbook -i hosts kubernetes.yml -u ubuntu --private-key ${CHAVESSH})

# RETIRA A CHAVE DO K8S PARA FAZER OS JOINS
K8S_JOIN_MASTER=$(echo $ANSIBLE_OUT | grep -oP "(kubeadm join.*?certificate-key.*?)'" | sed 's/\\//g' | sed "s/', 't//g" | sed "s/'$//g" )
K8S_JOIN_WORKER=$(echo $ANSIBLE_OUT | grep -oP "(kubeadm join.*?discovery-token-ca-cert-hash.*?)'" | head -n 1 | sed 's/\\//g' | sed "s/', 't//g" | sed "s/ '$//g")

echo "CHAVA PARA JOIN DOS MASTERS"
echo $K8S_JOIN_MASTER
echo "CHAVE PARA JOIN DOS WORKERS"
echo $K8S_JOIN_WORKER

# PREPARA OS SCRIPTS DE AUTO JOIN
cat <<EOF > 2-provisionar-k8s-master-auto-shell.yml
- hosts:
  - ec2-k8s-m2
  - ec2-k8s-m3
  become: yes
  tasks:
    - name: "Reset cluster"
      shell: "kubeadm reset -f"

    - name: "Fazendo join kubernetes master"
      shell: '$K8S_JOIN_MASTER'

    - name: "Colocando no path da maquina o conf do kubernetes"
      shell: mkdir -p $HOME/.kube && sudo cp -f /etc/kubernetes/admin.conf $HOME/.kube/config && sudo chown $(id -u):$(id -g) $HOME/.kube/config && export KUBECONFIG=/etc/kubernetes/admin.conf
#---
- hosts:
  - ec2-k8s-w1
  - ec2-k8s-w2
  - ec2-k8s-w3
  become: yes
  tasks:
    - name: "Reset cluster"
      shell: "kubeadm reset -f"

    - name: "Fazendo join kubernetes worker"
      shell: $K8S_JOIN_WORKER

#---
- hosts:
  - ec2-k8s-m1
  become: yes
  tasks:
    - name: "Configura weavenet para reconhecer os nós master e workers"
      shell: kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=\$(kubectl version | base64 | tr -d '\n')"

    - name: Espera 30 segundos
      wait_for: timeout=30

    - shell: kubectl get nodes -o wide
      register: ps
    - debug:
        msg: " '{{ ps.stdout_lines }}' "
EOF

# RODA O SCRIPT PARA FAZER O JOIN
ansible-playbook -i hosts 2-provisionar-k8s-master-auto-shell.yml -u ubuntu --private-key ${CHAVESSH}

sleep 10

# ENTREGA O OUTPUT NA TELA
cd $TFPATH/0-terraform/
terraform output

##################
#### SEGUE PARA O TESTE