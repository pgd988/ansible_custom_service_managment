#####
Requirements:

dialog console utility (./requirements.sh)

#####
# If you enabled passwd auth on remote instances use vault service to secure your password.

#Tect run
ansible-playbook --check [role].yml -i inventory --vault-password-file roles/LB/vars/vault_pass


#Run  for PROD from . directory
ansible-playbook  [role].yml -i inventory --vault-password-file roles/LB/vars/vault_pass


################## Roles

default - default user creation and software install

monitoring - Deploys and condigures prometheus with grafana.

aws_nodes - Create new AWS EC2 nodes

##################
files/ - static configs
vars/ - dynamic configs data
templates/ - rules for dynamic config generation
##################
