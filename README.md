# aesd-assignments
This repo contains public starter source code, scripts, and documentation for Advanced Embedded Software Development (ECEN-5713) and Advanced Embedded Linux Development assignments University of Colorado, Boulder.

### 🛠 **Linux Kernel and Embedded Root Filesystem Project (Assignment 3 – AELD Course)**  
**Technologies:** Linux Kernel 5.15, QEMU (AArch64), BusyBox, Make, Bash, Docker, Git, C, Cross-Compilation, GitHub Actions (Self-hosted Runner), System Programming

**Description:**  
Developed a complete embedded Linux system for the ARM64 architecture, including a custom kernel, root filesystem, and user-space applications. The project involved deep integration of system-level components, focusing on automation, configuration, and validation in an emulated embedded environment.

**Responsibilities & Accomplishments:**

- 🔧 **Linux Kernel Compilation**:  
  - Cross-compiled the Linux 5.15 kernel for the ARM64 architecture using the official ARM GNU toolchain.  
  - Configured kernel options to include support for `initramfs`, virtual devices, and essential drivers.

- 🗃️ **Custom Root Filesystem (initramfs)**:  
  - Built a minimal rootfs from scratch with a correct UNIX directory hierarchy (`/bin`, `/lib64`, `/etc`, etc.).
  - Integrated and configured **BusyBox** for providing shell and core Unix utilities.
  - Manually resolved and installed ELF dependencies (`libc.so.6`, `libm.so.6`, etc.) by analyzing binary output with `readelf`.

- 🚀 **Cross-Compilation Toolchain Usage**:  
  - Cross-compiled custom C applications such as `writer.c` and integrated them into the rootfs.
  - Detected required interpreters and shared libraries programmatically and copied them dynamically from the sysroot.

- 🔄 **Automation with Bash Scripts**:  
  - Wrote a full automation script (`manual-linux.sh`) to build the kernel, generate the rootfs, copy necessary binaries/libraries, and package everything into `initramfs.cpio.gz`.
  - Script ensured reproducibility and was compatible with CI pipelines.

- 🖥️ **Emulated Target Environment (QEMU)**:  
  - Deployed the system using `qemu-system-aarch64` with virt configuration, launching directly into a shell via `rdinit=/bin/sh`.
  - Validated execution of custom binaries inside the emulated environment.

- ⚙️ **CI Integration with GitHub Self-Hosted Runners**:  
  - Installed and configured a self-hosted GitHub Actions runner on an Ubuntu host.  
  - Debugged Docker-integration issues and adjusted system setup for GitHub’s embedded grading toolchain.

- 🧪 **Unit and System Test Integration**:  
  - Compiled and executed unit tests using the Unity framework integrated via CMake.
  - Validated `writer.sh`, `finder.sh`, and `finder-test.sh` scripts using `full-test.sh` and `assignment-autotest`.

**Outcome:**  
Successfully booted a fully functional embedded Linux environment inside QEMU, running BusyBox shell and executing custom applications. Passed all automated tests via self-hosted GitHub Actions, demonstrating solid understanding of embedded systems, Linux internals, automation, and cross-platform development.
