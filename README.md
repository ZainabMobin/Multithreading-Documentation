# Documentation Generator (Graphviz and Doxygen)

## Install Graphviz and Doxygen

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

## Setup Linux kernel source code

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

## Setup Doxygen file for relevant subfolders

Update the doxyfile configuration according to the need and execute it via  `doxygen <config-file-name> `, Then view generated documentation on the default browser

```bash
    chmod +x doxygen_kernel_filter.sh   # execute script for code sanitation
    doxygen Doxyfile
    xdg-open html/index.html
```