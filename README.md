# Documentation Generator

## 1. Install Graphviz and Doxygen

**On Linux Distros**

```bash 
sudo apt update
sudo apt install Graphviz Doxygen
```

**On Windows**

Install [Graphviz](https://graphviz.org/download/) and [Doxygen](https://www.doxygen.nl/download.html) from the official websites

OR through the Powershell command

```Powershell
winget install Graphviz.Graphviz Doxygen.Doxygen
```

## 2. Setup Linux kernel source code

Clone specific Linux kernel subsystems using sparse checkout at a specific version tag to save disk space and time.

```bash
mkdir -p src && cd src  # Move to source code folder
git init
git remote add origin https://github.com/torvalds/linux.git
git sparse-checkout set <dirs seperated by whitespace> # checkout required directories
git fetch --filter=blob:none --depth=1 origin tag v7.0  # kernel version tag
git checkout FETCH_HEAD
cd ..   # Move back to project root
```

**Add folders in the sparse checkout**

Without re-cloning the source code, update sparse-checkout list new directories and fetch the source code. 

```bash
git sparse-checkout set <total dirs seperated by whitespace> # Update with all new and existing folders

git fetch --filter=blob:none --depth=1 origin tag v7.0 # Re-fetch target tag (downloads missing files for newly added paths)

git checkout FETCH_HEAD # populates working directory added dirs
```

**Automation**

See `.env` file for info on kernel source code to be fetched.  

## 3. Configure included file and folder paths

Create documentation focused on specific sub-modules. All entries start with the `src/` filepath.

- Add documented files  in `input_files.txt`
- add folders of specific modules in `include_path.txt`
- Avoid documentation of irrelevant sub-folders by adding them in the `exclude_path.txt`

## 4. Setup Doxygen file for relevant subfolders
Update the doxyfile configuration according to the need and execute it via  `doxygen <config-file-name> `, Then view generated documentation on the default browser

```bash
chmod +x doxygen_kernel_filter.sh   # execute script for code sanitation
chmod +x generate_flags.py  # populate Preemption Configuration site from kernel/Kconfig.preempt
python3 generate_flags.py
doxygen Doxyfile
xdg-open html/index.html
```

# Local Deployment

`act` (or an extension powered by act) is strictly required to run GitHub Actions locally.  The official GitHub Actions extension published by GitHub `GitHub.vscode-github-actions` only connects to GitHub’s cloud platform. It allows you to edit YAML schema, view remote runs, and trigger cloud workflows (workflow_dispatch), but it cannot execute code locally on your system. 

To run workflows locally inside Docker on your Ubuntu machine, you need `act` (the execution engine) paired with a local extension like GitHub Local Actions `(SanjulaGanepola.github-local-actions)` or Act `(samuelmeuli.vscode-act)`.

## 1. Prerequisites Setup (Ubuntu)

### Install and Configure Docker
 
`act` creates Docker containers that mirror GitHub’s ubuntu-latest execution environment.

Install Docker Engine. Enable Non-Root Docker Access. Allow VS Code and act to access the Docker daemon without using sudo. Apply Group Changes. Verify Docker

```Bash
sudo apt-get update
sudo apt-get install -y docker.io
sudo usermod -aG docker $USER
newgrp docker
docker run hello-world
```

### Install act (Local Execution Engine)

Install the act CLI binary on Ubuntu, or manually download the pre-built executible . Confirm act is installed

```Bash
sudo tar -xzf <prebuilt_exe.tar.gz> -C /usr/local/bin/ act
act --version
```

## 2. Build custom image and run container

Load custom local image via .actrc file, do not pull from remote registery,

```bash
docker build -t node-bookworm-act:local . # Build the image <image_name:version> locally with sudo, git and ca-certificates configured 
docker run --rm node-bookworm-act:local sudo apt-get update # run temp container and verify sudo is installed and passwordless
docker run --rm node-bookworm-act:local python3 --version # run temp container and verify sudo is installed and passwordless
act -j deploy-docs --reuse # run act with implicit port binding in workflow, else with explicit port binding include --pull=false
```


## Added sched-ext lavd-scx

File | Purpose
-|-
src/include/linux/sched/ext.h| Core sched-ext public header & ops
src/kernel/sched/ext.h | Core internal sched-ext data structures
src/kernel/sched/ext.c | Engine bridging core kernel to BPF schedulers
src/kernel/sched/syscalls.c | Contains sys_sched_setscheduler for SCHED_EXT
src/kernel/bpf/bpf_struct_ops.c | Resolves BPF ops registration & dispatch
sched-ext-repo/scheds/c/scx_lavd.bpf.c | LAVD BPF kernel-space scheduler implementation
sched-ext-repo/scheds/c/scx_lavd.c | LAVD user-space control program
sched-ext-repo/scheds/c/scx_lavd.h | Shared structures between LAVD & kernel