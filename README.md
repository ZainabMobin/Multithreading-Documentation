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
git sparse-checkout set kernel include/linux include/uapi mm arch/x86/include   # checkout required dirs
git fetch --filter=blob:none --depth=1 origin tag v7.0  # kernel version tag
git checkout FETCH_HEAD
cd ..   # Move back to project root
```

## 3. Configure included file and folder paths

Create documentation focused on specific sub-modules. All entries start with the `src/` filepath.

- Add documented files  in `input_files.txt`
- add folders of specific modules in `include_path.txt`
- Avoid documentation of irrelevant sub-folders by adding them in the `exclude_path.txt` 

## 4. Setup Doxygen file for relevant subfolders
Update the doxyfile configuration according to the need and execute it via  `doxygen <config-file-name> `, Then view generated documentation on the default browser

```bash
chmod +x doxygen_kernel_filter.sh   # execute script for code sanitation
doxygen Doxyfile
xdg-open html/index.html
```

# Local Deployment

`act` (or an extension powered by act) is strictly required to run GitHub Actions locally.  The official GitHub Actions extension published by GitHub `GitHub.vscode-github-actions` only connects to GitHub’s cloud platform. It allows you to edit YAML schema, view remote runs, and trigger cloud workflows (workflow_dispatch), but it cannot execute code locally on your system. 

To run workflows locally inside Docker on your Ubuntu machine, you need `act` (the execution engine) paired with a local extension like GitHub Local Actions (SanjulaGanepola.github-local-actions) or Act (samuelmeuli.vscode-act).

## 1. Prerequisites Setup (Ubuntu)

### Step A: Install and Configure Docker
 
`act` creates Docker containers that mirror GitHub’s ubuntu-latest execution environment.

Install Docker Engine. Enable Non-Root Docker Access. Allow VS Code and act to access the Docker daemon without using sudo. Apply Group Changes. Verify Docker

```Bash
sudo apt-get update
sudo apt-get install -y docker.io
sudo usermod -aG docker $USER
newgrp docker
docker run hello-world
```

### Step B: Install act (Local Execution Engine)

Install the act CLI binary on Ubuntu, or manually download the pre-built executible . Confirm act is installed

```Bash
sudo tar -xzf <prebuilt_exe.tar.gz> -C /usr/local/bin/ act
act --version
```

## 2. Build custom image

Use custom local image, do not pull from remote registery,
```bash
docker build -t node-bookworm-act:local . # Build the image <image_name:version> locally with sudo configured 
docker run --rm node-bookworm-act:local sudo apt-get update #verify that sudo is installed and passwordless
act -j deploy-docs --reuse # run the container
```