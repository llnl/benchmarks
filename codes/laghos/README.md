# laghos build and run scripts for tuolumne

The directory contains shell scripts to clone, build, and run laghos on the tuolumne system.

---

## Table of Contents

- [Overview](#overview)
- [Scripts Description](#scripts-description)
- [Setup](#setup)
- [Usage](#usage)
- [Example Workflow](#example-workflow)
- [Notes](#notes)
- [Support](#support)
- [License](#license)

---

## Overview

The scripts automate the process of setting up the build environment, cloning the laghos repository, building the code, and running the executable. All scripts (except `laghos_env.sh`) automatically source the environment settings from `laghos_env.sh`.

---

## Scripts Description

| Script Name      | Description                                                          |
|------------------|----------------------------------------------------------------------|
| laghos_env.sh    | Configure environment variables (compiler, GPU architecture, etc.)   |
| laghos_clone.sh  | Clone the laghos repository into a specified workspace directory     |
| laghos_build.sh  | Build the laghos project in the specified workspace directory        |
| laghos_run.sh    | Run the laghos executable in the specified workspace directory       |

---

## Setup

**Edit `laghos_env.sh`**  
   Open `laghos_env.sh` and set the environment parameters as needed
```bash
   # Example laghos_env.sh
   export ROCM_PATH=/opt/rocm
   export ROCM_ARCH=gfx942
   export CXX=hipcc
   export MPICXX=mpicxx
   # Modify other environment variables as needed
```
---

## Usage

Each script requires e single argument: the path to the workspace directory.

- **Clone the repository:**
```bash
  ./laghos_clone.sh <workspace-dir>
```
- **Build the project:**
```bash
  ./laghos_build.sh <workspace-dir>
```
- **Run the code:**
```bash
  ./laghos_run.sh <workspace-dir>
```
---

## Example Workflow
```bash
# 1. Configure the environment
vim laghos_env.sh

# 2. Clone the repository
./laghos_clone.sh ~/laghos_workspace

# 3. Build the project
./laghos_build.sh ~/laghos_workspace

# 4. Run the executable
./laghos_run.sh ~/laghos_workspace
```
---

## Notes

- Scripts `laghos_clone.sh`, `laghos_build.sh`, `laghos_run.sh` automatically source `laghos_env.sh` to ensure the environment is set.
- Modify `laghos_env.sh` as needed for your system or project requirements.
- Each script expects the workspace directory as its only argument.

---

## Support

For questions or issues, please contact the project maintainer.
