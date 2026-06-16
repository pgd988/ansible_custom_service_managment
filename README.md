# Ansible Custom Service Management

This Ansible project is designed to configure Ubuntu Linux Virtual Dedicated Servers (VDS). It deploys essential security measures, monitoring stacks, and optional services to ensure the environment is robust and observable.

## Features
- **Security**: Disables password authentication, provisions users with SSH public keys, and installs SSHGuard (optional).
- **Monitoring Stack**: Deploys Node Exporter and cAdvisor.
- **Optional Services**:
  - Nginx
  - SSHGuard
  - Cloudflare Zero Trust agent

## Project Structure
- `config.yml`: Global toggle for optional features.
- `inventory`: Your list of target server IPs.
- `playbooks/`: Ansible playbooks (`def.yml` for default services, `monitoring.yml` for the monitoring stack).
- `roles/`:
  - `default`: Core security and base configuration (users, SSHGuard, etc.).
  - `monitoring`: Docker-based monitoring stack (Prometheus, Grafana, cAdvisor).
- `vault.yml`: A placeholder file for any encrypted private data using `ansible-vault`.

## Usage

1. **Configure Inventory**
   Update `inventory` with your target VDS IPs.

2. **Configure Variables**
   Copy `config.yml.example` to `config.yml` and enable or disable features as required:
   ```yaml
   enable_nginx: true
   enable_sshguard: true
   enable_cloudflare_zt: false
   ```

3. **User Management**
   Update `roles/default/vars/users_list.yaml` to define your users.
   Place user public SSH keys in `roles/default/files/pub_keys/<username>.pub`.
   *(Note: If you plan to use GitLab CI/CD, ensure you generate the pipeline's SSH key-pair and add the `ci_user` to your `users_list.yaml` before running the playbooks for the first time!)*

4. **Run Playbooks**
   To deploy the core server setup:
   ```bash
   ansible-playbook playbooks/def.yml -i inventory
   ```

   To deploy the monitoring stack:
   ```bash
   ansible-playbook playbooks/monitoring.yml -i inventory
   ```

## Docker CI Image

This repository includes a `Dockerfile` specifically designed to be used as the runner environment for your GitLab CI/CD pipeline. It contains a lightweight OS, Ansible, and the necessary SSH utilities.

Before the pipeline can run successfully, you must build this image and push it to your GitLab project's Container Registry so the `.gitlab-ci.yml` jobs can use it.

```bash
# 1. Login to your GitLab registry
docker login registry.gitlab.com

# 2. Build the image locally
docker build -t registry.gitlab.com/<your-group>/<your-repo>/ansible-runner:latest .

# 3. Push the image
docker push registry.gitlab.com/<your-group>/<your-repo>/ansible-runner:latest
```
*(The `.gitlab-ci.yml` is configured to dynamically pull this image using `$CI_REGISTRY_IMAGE/ansible-runner:latest`).*

## GitLab CI/CD & Vault Setup

To fully automate deployments with the included `.gitlab-ci.yml`, you must securely provide an SSH key to the runner via Ansible Vault:

1. **Generate a deployment key-pair:**
   ```bash
   ssh-keygen -t ed25519 -C "gitlab-ci" -f ci_ssh_key
   ```
2. **Provision the public key (Do this before running playbooks manually):**
   Rename the generated `ci_ssh_key.pub` to `ci_user.pub`, place it into `roles/default/files/pub_keys/ci_user.pub`. Then, run the playbooks manually from your local machine (using your personal admin access). This allows Ansible to create the `ci_user` on the server and append the public key to `~/.ssh/authorized_keys`, permitting the pipeline to log in later.
3. **Encrypt the private key with Ansible Vault:**
   ```bash
   ansible-vault encrypt ci_ssh_key
   ```
   *(You will be prompted to create a vault password. Remember this password.)*
4. **Commit the encrypted key:**
   Add the encrypted `ci_ssh_key` file to your repository. (Do **NOT** commit the unencrypted version!)
5. **Configure GitLab CI Variables:**
   In your GitLab project, go to **Settings > CI/CD > Variables** and add a new variable:
   - **Key**: `ANSIBLE_VAULT_PASSWORD`
   - **Value**: *(The password you used in step 2)*
   - **Masked**: Yes