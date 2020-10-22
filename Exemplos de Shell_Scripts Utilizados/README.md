![In_Build](../Imagens/in_building.png)
Os arquivos .sh foram pensados para serem os mais universais possiveis, possuindo parametros que são alimentados via _Variaveis de Ambiente_ passandos nas configurações do _job_ no projeto do _Rundeck_, variaveis essas que possuem  seu inicio com 'RD_OPTION' e são necessarias para o funcionamento do _Shell Script_.

A baixo a função de cada variavel de ambiente:  

**RD_OPTION_NODE01/RD_OPTION_NODE02/RD_OPTION_NODE03**: Corresponde ao IP de cada NÓ do Cluster Docker Swarm(MASTER), IP esse que será usado para checagem de Nós online e para o envio dos comandos via ssh.

**RD_OPTION_RD-PATH**: Path do caminho no qual o projeto está localizado dentro do server ou containers que está o _Rundeck_. 
EX: /home/rundeck/projects/Projeto_Exemple

**RD_OPTION_GLUSTER-PATH**: 

**RD_OPTION_PROJETO**: Nome do projeto no Gitlab, esse nome será usado como nome do _Service_, _Volume_ no Docker Swarm e complemento para o path da variavel RD_OPTION_RD-PATH, assim tendo uma pariedade entre os nomes nos dois locais.

**RD_OPTION_IMAGE**: