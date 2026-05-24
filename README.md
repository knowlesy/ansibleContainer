# Ansible Testing Lab (Rundeck Edition)

A local, fully self-contained Ansible testing lab using Docker Compose and Rundeck.

## Overview

This lab provides:
1. **Rundeck:** A robust runbook automation platform. The container is customized to have Ansible and its dependencies installed natively.
2. **Managed Nodes:** 3 distinct Linux target containers (Ubuntu, AlmaLinux, Rocky Linux) pre-configured with SSH and Python for immediate Ansible management.
3. **Local Playbooks & Inventory:** A locally mounted directory (`./playbooks`) and inventory (`./inventory.yml`) synced directly into Rundeck.

## Getting Started

A `Makefile` is included to simplify managing the lab environment.

### 1. Build and Start the Lab

Because we install Ansible and pre-configure the project directly into the Rundeck image, you must build the container on the first run.

```bash
make build
```
*(For subsequent runs, you can just use `make up`)*

### 2. Access Rundeck

- **URL:** [http://localhost:4440](http://localhost:4440)
- **Username:** `admin`
- **Password:** `admin`

> ⚠️ **Note for Apple Silicon (M1/M2/M3) Users:** 
> The official Rundeck image is built for `amd64` architecture. Your Mac will use Rosetta 2 to emulate it. This means the very first time you start the container, Rundeck (which is a large Java application) may take **2 to 5 minutes** to fully boot up. 
> 
> If you try to access the web interface too early, you will see an `ERR_CONNECTION_RESET` error. This is normal. 
> 
> To watch the startup progress and know exactly when it is ready, run:
> ```bash
> make logs
> ```
> Wait until you see `Grails application running at http://localhost:4440` before trying to load the page.

### 3. Running Playbooks in Rundeck

The lab is pre-configured! You do not need to set up any projects or node sources manually. When you log in, you will automatically be in the **AnsibleLab** project, and the Nodes (Ubuntu, AlmaLinux, Rocky Linux) will already be discovered.

To run one of the included playbooks (e.g., `01-ping.yml`), you can create a Rundeck Job:

1. Click **Jobs** on the left menu, then **Create a new Job**.
2. **Details Tab:** Give it a name like `Run Ping Playbook`.
3. **Workflow Tab:** 
   - Scroll down to **Add a Step**.
   - Under **Node Steps** (or **Workflow Steps** depending on plugin version), choose **Ansible Playbook**.
   - **Playbook file path:** `/playbooks/01-ping.yml`
   - Click **Save** on the step.
4. **Nodes Tab:**
   - Select **Dispatch to Nodes**.
   - In the Node Filter box, type `.*` to target all nodes, or `tags: ubuntu` etc.
5. Click **Create** at the bottom to save the job.
6. Click **Run Job Now** to execute the playbook!

## Scaling Target Nodes

To test multi-node deployments, you can scale the target containers. For example, to spin up 3 Ubuntu containers at once:

```bash
make scale-ubuntu
```

To scale to a specific number of nodes, pass the `NODES` parameter:

```bash
make scale-ubuntu NODES=5
```
*Note: You would also need to manually add the new dynamically generated container hostnames to your `./inventory.yml`.*

---

## Example: Manual Configuration Reference

If you ever want to create a *new* project from scratch rather than using the pre-configured "AnsibleLab", here is how to do it manually in the UI:

### Step 1: Create a Project
1. Click **New Project**.
2. Set the **Project Name** (e.g., `MyCustomProject`).
3. Scroll down to **Default Node Executor** and select **Ansible Ad-Hoc Node Executor**. 
   *(Leave the defaults here; Ansible handles the SSH settings via the inventory).*
4. Scroll down to **Default Node Copier** and select **Ansible File Copier**.
5. Click **Save**.

### Step 2: Add the Ansible Inventory
1. In your new project, go to **Project Settings** (gear icon bottom left) -> **Edit Nodes**.
2. Click **Add a new Node Source**.
3. Select **Ansible Resource Model Source**.
4. Configure it as follows:
   - **Ansible Inventory File path:** `/inventory.yml`
   - **Format:** `yaml`
   - **Gather Facts:** `false` (to speed up node discovery)
5. Click **Save** on the plugin, and then **Save** at the bottom of the page.
6. Click the **Nodes** tab on the left menu. You should now see your target nodes.

### Step 3: Adding New Playbooks & Jobs
As you create more Ansible playbooks, you can easily integrate them:
1. Save your new `.yml` playbook file into the `./playbooks` folder on your host machine. (It will automatically sync into the Rundeck container).
2. In Rundeck, click **Jobs** -> **Create a new Job**.
3. Name your job appropriately.
4. Under the **Workflow** tab, add a new **Ansible Playbook** step.
5. Set the **Playbook file path** to `/playbooks/your-new-playbook.yml`.
6. Under the **Nodes** tab, select **Dispatch to Nodes** and configure your filter (e.g., `.*`).
7. Save the job.

## Stopping the Lab

To shut down all containers and clean up the networking:

```bash
make down
```
