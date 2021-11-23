#!/bin/bash -vx
## VARIAVEIS
TFPATH="/home/ec2-user/k8s-multi-master/0-k8s"
CHKSGNOK=`grep "sg" $TFPATH/0-terraform/sg-ok.tf | wc -l`
CHAVESSH="~/.ssh/grupo-one.pem"
AMIID=`cat /tmp/k8s-ami-id.tmp`
###########################
#LIMPA TEMPORARIOS
rm $TFPATH/tmp/tf*.tmp

#PEGA O ESTADO DO TERRAFORM
cd $TFPATH/0-terraform/
terraform init
terraform output > $TFPATH/tmp/tfoutput.tmp
CHKOUTPUT=`grep -i "No outputs found" $TFPATH/tmp/tfoutput.tmp | wc -l`

### RODA PRA CRIAR OS SECURITY GROUPS E SALVAR OS IDs
if [ ${CHKSGNOK} == 0 ] || [ ${CHKOUTPUT} == 1 ]; 
  then 
    # PREPARA OS ARQUIVOS PARA RODAR SOMENTE SG
    cp sg-nok.tf sg-nok.tf.bkp
    if [ ! -f mainv2.tf.disable ] ;then mv mainv2.tf mainv2.tf.disable; fi
    if [ ! -f outputmain.tf.disable ] ;then mv outputmain.tf outputmain.tf.disable; fi
    if [ -f sg.ok.tf ]; then rm sg.ok.tf; fi

    # RODA O TERRAFORM PARA CRIAR OS SG
    terraform init
    terraform apply -auto-approve

    # PEGA O OUTPUT PARA TRATAR
    terraform output | sed 's/\"//g' | sed 's/ //g' > $TFPATH/tmp/tfsgids.tmp
    SGWORKER=`grep security-group-acessos_workers $TFPATH/tmp/tfsgids.tmp | cut -d"=" -f2`
    SGMASTERS=`grep security-group-acessos-masters $TFPATH/tmp/tfsgids.tmp | cut -d"=" -f2`
    SGHAPROXY=`grep security-group-workers-e-haproxy1 $TFPATH/tmp/tfsgids.tmp | cut -d"=" -f2`

    # RENOMEIA ARQUIVO DO SG SUBSTITUINDO OS IDS CIRCULARES
    mv sg-nok.tf sg-ok.tf
    sed -i 's/#security-group-acessos_workers/"'${SGWORKER}'",/g' sg-ok.tf
    sed -i 's/#security-group-acessos-masters/"'${SGMASTERS}'",/g' sg-ok.tf
    sed -i 's/#security-group-workers-e-haproxy1/"'${SGHAPROXY}'",/g' sg-ok.tf

    CHKSGNOK=`grep "sg" $TFPATH/0-terraform/sg-ok.tf | wc -l`
fi

if [ ! -f $TFPATH/tmp/tfsgids.tmp ];
    then
      # PEGA O OUTPUT PARA TRATAR
      terraform output | sed 's/\"//g' | sed 's/ //g' > $TFPATH/tmp/tfsgids.tmp
fi

# LIBERA OS ARQUIVOS DO TERRAFORM PARA RODAR
if [ -f mainv2.tf.disable ] ;then mv mainv2.tf.disable mainv2.tf; fi
if [ -f outputmain.tf.disable ] ;then mv outputmain.tf.disable outputmain.tf; fi

cd $TFPATH/0-terraform/
CHKREFRESH=$(terraform refresh | wc -l)

if [ ${CHKSGNOK} -eq 5 ] && [ ${CHKREFRESH} -lt 15 ]; 
  then
    terraform init
    TF_VAR_amiid=$AMIID terraform apply -auto-approve
fi

echo  "Aguardando a criação das maquinas ..."
sleep 10

##########################################
#SEGUE PARA O SCRIPT HOSTS