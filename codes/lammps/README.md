# lammps build and run scripts for tuolumne

The directory contains shell scripts to clone, build, and run lammps on the tuolumne system.

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

The scripts automate the process of setting up the build environment, cloning the lammps repository, building the code, and running the executable. All scripts (except `lammps_env.sh`) automatically source the environment settings from `lammps_env.sh`.

---

## Scripts Description

| Script Name      | Description                                                          |
|------------------|----------------------------------------------------------------------|
| lammps_env.sh    | Configure environment variables (compiler, GPU architecture, etc.)   |
| lammps_clone.sh  | Clone the lammps repository into a specified workspace directory     |
| lammps_build.sh  | Build the lammps project in the specified workspace directory        |
| lammps_run.sh    | Run the lammps executable in the specified workspace directory       |

---

## Setup

**Edit `lammps_env.sh`**  
   Open `lammps_env.sh` and set the environment parameters as needed
```bash
   # Example lammps_env.sh
   export ROCM_PATH=/opt/rocm
   export ROCM_ARCH=AMD_GFX942_APU
   export CXX=hipcc
   export MPICXX=mpicxx
   # Modify other environment variables as needed
```
---

## Usage

Each script requires e single argument: the path to the workspace directory.

- **Clone the repository:**
```bash
  ./lammps_clone.sh <workspace-dir>
```
- **Build the project:**
```bash
  ./lammps_build.sh <workspace-dir>
```
- **Run the code:**
```bash
  ./lammps_run.sh <workspace-dir>
```
---

## Example Workflow
```bash
# 1. Configure the environment
vim lammps_env.sh

# 2. Clone the repository
./lammps_clone.sh ~/lammps_workspace

# 3. Build the project
./lammps_build.sh ~/lammps_workspace

# 4. Run the executable
./lammps_run.sh ~/lammps_workspace
```
---

## Notes

- Scripts `lammps_clone.sh`, `lammps_build.sh`, `lammps_run.sh` automatically source `lammps_env.sh` to ensure the environment is set.
- Modify `lammps_env.sh` as needed for your system or project requirements.
- Each script expects the workspace directory as its only argument.

---

## Support

For questions or issues, please contact the project maintainer.
