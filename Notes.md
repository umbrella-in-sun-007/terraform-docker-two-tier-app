## **Why You Don’t See the Container in Docker Desktop**

### **1. Terraform may be using a different Docker context or socket**

Docker can connect to **multiple contexts** — for example:

* Docker Desktop (default on Windows/Mac)
* Docker Engine (Linux socket: `/var/run/docker.sock`)
* Remote Docker daemon
* Colima, Rancher, WSL, etc.

Terraform’s Docker Provider connects to the Docker daemon **via the `DOCKER_HOST` environment variable**.
If that variable points to a different socket than Docker Desktop, you’ll see the container running — but only from that daemon’s perspective.

---

## **Step-by-Step Diagnosis**

### **Step 1: Check if Terraform used a custom Docker host**

Run this in your terminal **before** `terraform apply` next time:

```bash
echo $DOCKER_HOST
```

#### Expected Output:

If it’s **empty**, Terraform will use the default Docker socket:

```
/var/run/docker.sock
```

If it shows something like:

```
tcp://localhost:2375
```

or

```
unix:///var/run/docker.sock
```

— that tells us which daemon it’s using.

If it’s not the same Docker socket used by Docker Desktop, that explains the issue.

---

### **Step 2: Check active Docker contexts**

Run:

```bash
docker context ls
```

You’ll see output like:

```
NAME                TYPE                DESCRIPTION                               DOCKER ENDPOINT
default             moby                Current DOCKER_HOST based configuration   unix:///var/run/docker.sock
desktop-linux *     moby                Docker Desktop                            unix:///Users/.../docker.sock
```

Look for the `*` — that marks the **active context** (where Docker Desktop is looking).

If Terraform used `default` but Docker Desktop uses `desktop-linux`, the container will run “invisible” to Desktop.

---

### **Step 3: Confirm container exists**

Run:

```bash
docker ps -a
```

If you don’t see it, try explicitly targeting the socket Terraform used:

```bash
DOCKER_HOST=unix:///var/run/docker.sock docker ps
```

or

```bash
DOCKER_HOST=tcp://localhost:2375 docker ps
```

Depending on which daemon Terraform connected to, one of those will show your running container.

---

## **How to Fix**

### **Option 1: Explicitly set Docker provider to use Desktop’s Docker socket**

Modify your `provider "docker"` block in `main.tf`:

```hcl
provider "docker" {
  host = "unix:///var/run/docker.sock"
}
```

> On **Mac/Windows**, it might instead be:
>
> ```hcl
> provider "docker" {
>   host = "unix:///${env("HOME")}/.docker/run/docker.sock"
> }
> ```

Then re-run:

```bash
terraform destroy -auto-approve
terraform apply -auto-approve
```

Now Docker Desktop should show the image and container.

---

### **Option 2: Ensure Terraform runs in the same Docker context**

If you’re using **Docker Desktop + WSL**, make sure Terraform runs **inside the same environment** (e.g., same WSL distribution).
If you ran Terraform from outside WSL, it may have used a Linux socket not tied to Docker Desktop.

---

## **Step 4: Verify Docker Desktop Sync**

After fixing the provider or context:

* Run `docker ps`
* Check Docker Desktop > **Containers/Apps** tab — your container should now appear.
* The image (`terraform-nginx-image`) should also appear under **Images**.
