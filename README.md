<h3 align="center">
  Pomalabs Web
</h3>

## 👨🏻‍💻 Sobre o projeto

O objetivo do projeto é de aplicar e exercitar os conhecimentos adquiridos através do **Programa de Desenvolvimento Itaú 2.0** aplicado pela **Gama Academy**.
As metas que deseja alcançar são:

- Criação de uma rede isolada para esta aplicação;
- Criação de uma pipeline de infraestrutura para provisionar uma imagem que será utilizada em um cluster kubernetes(single master);
- Criação de uma pipeline para provisionar um cluster multi master utilizando a imagem criada na pipeline de infraestrutura;
- Criação de uma pipeline para provisionar o banco de dados (dev, stage, prod) que será utilizado nas aplicações que estarão no kubernetes. Esta base de dados, será provisionada em uma instância privada, com acesso a Internet via Nat Gateway na mesma vpc do kubernetes multi master;
- Criação de  uma pipeline de desenvolvimento para deployar os ambientes de uma aplicação Java (dev, stage, prod) com ligação a um banco de dados mysql-server (utilizar o cluster kubernetes(multi master) provisionado pela pipeline de infraestrutura.

<p style="color: red;">Todo processo será feito via código e console.</p>

### 💻 Desenvolvedores
- [Allan Almeida](https://github.com/<ADD>)
- [André Luiz de Santi](https://github.com/<ADD>)
- [Bruno Hassan Mouazzem](https://github.com/brunohassan)
- [Bruno Ortale Cunha](https://github.com/bocunha)
- [Bruno Passianotto](https://github.com/<ADD>)

## 🚀 Tecnologias

Tecnologias que utilizamos para desenvolver esta API Rest:

- [Terraform](https://www.terraform.io)
- [Ansible](https://www.ansible.com)
- [Docker](https://www.docker.com)
- [Jenkins](https://www.jenkins.io)
- [Java](https://www.java.com/pt-BR/)
- [MySQL](https://www.mysql.com)
- Shell

## 💻 Iniciando

- As instruções a seguir irão te guiar para que você crie uma cópia do projeto na sua máquina local.

### Pré-requisitos

- Conta da [AWS](https://aws.amazon.com/) com acesso a VPCs e Subnets. [Atenção! As ferramentas utilizadas neste projeto podem gerar cobrança para o usuário da conta]
- Dependências instaladas na máquina na qual o Jenkins será executado.

**Fork do projeto e clone para a máquina**

- Crie um fork do projeto [grupo-one-mmaster](https://github.com/bocunha/grupo-one-mmaster.git) e faça um clone para a máquina de desenvolvimento.

**Atualização das informações nos códigos**

Edite o arquivo **"0-terraform/mainv2.tf"** com as configurações da instancia presente em sua EC2:
- Alterar ID de cada subnet;
- Alterar ID da AMI de uma máquina de desenvolvimento e suas especificações;

Edite on arquivos **.sh**:
- Alterar variável do shell CHAVESSH para o caminho de sua chave ssh privada;

Edite o arquivo **jenkinsfile**:
- Alterar URL do projeto do Git que está usando no estágio "Clone do Repositório";

Agora, só basta rodar a esteira de deploy no Jenkins e tudo pronto!

## ⚙️ Aplicação
A aplicaçã0 [spring-web-youtube](https://github.com/torneseumprogramador/spring-web-youtube/tree/deploy-docker) se trata de um sistema monolito simples onde contém uma área administrativa para administrar o CRUD de administradores(login, senha, cadastros).