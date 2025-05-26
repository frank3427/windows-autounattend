# Windows 11 Auto Unattended Install

## Overview

This collection of files allows for an unattended installation of Windows 11 Pro, including automated software installation via Chocolatey. It is an update and adaptation of an existing Windows 10 automation project. The scripts are designed to streamline the setup process for new Windows 11 installations.

## Disclaimer

**USE THESE SCRIPTS AT YOUR OWN RISK.**

These scripts are designed to modify system settings, bypass the Out-of-Box Experience (OOBE), format Disk 0, create user accounts, and automate software installation. You should thoroughly review and understand each script before using them.

*   **System Modifications:** Scripts will alter system configurations, registry settings, and service states.
*   **Data Loss:** The `Autounattend.xml` is configured to wipe Disk 0. Ensure you back up any important data before proceeding.
*   **`disableWindowsUpdates.ps1`:** This script attempts to completely disable Windows Updates. Doing so can have significant security implications, leaving your system vulnerable. Windows 11 may also override these settings. It is highly recommended to understand the risks or consider alternative update management strategies (e.g., using `win-updates.ps1` manually or configuring group policies).
*   **Software Installation:** Applications are installed via Chocolatey. Ensure you trust the packages being installed.

The authors and contributors are not responsible for any damage or data loss that may occur from using these scripts.

## Hardware Requirements for Windows 11

This automation assumes your hardware meets the standard Windows 11 requirements, including:
*   TPM 2.0 (Trusted Platform Module)
*   Secure Boot enabled
*   Compatible CPU, RAM, and storage

Refer to Microsoft's official documentation for detailed Windows 11 hardware specifications.

## Internet Connection

An active internet connection is **required** during the installation process. This is necessary for:
*   Chocolatey to download and install packages.
*   Windows Setup to potentially download drivers and updates.

## Installation Steps

1.  **Download Windows 11 ISO:** Obtain the latest Windows 11 ISO file. You can use Microsoft's Media Creation Tool or download it from the official Microsoft website.
2.  **Create Bootable USB Drive:** Use a tool like [Rufus](https://rufus.ie/) to create a bootable USB drive from the Windows 11 ISO.
    *   Ensure you select a partition scheme compatible with your system (usually GPT for UEFI).
3.  **Copy Project Files:** Copy all the files from this project (including `Autounattend.xml` and all `.ps1`, `.cmd`, `.bat` files) to the **root** of the bootable USB drive.
4.  **Boot from USB:** Configure your computer's BIOS/UEFI to boot from the USB drive. The unattended installation process should begin automatically.

## File Descriptions

*   **`Autounattend.xml`**: The primary Windows answer file that automates the Windows 11 Pro setup.
    *   **Windows Version:** Configured for Windows 11 Pro. It uses a Generic Volume License Key (GVLK) `W269N-WFGWX-YVC9B-4J6C9-T83GX`, suitable for Key Management Service (KMS) activation scenarios or image testing. **If you have a Retail or MAK product key, you MUST edit this file to include your key.**
    *   **Disk Configuration:** Wipes Disk 0 entirely and creates partitions for the OS.
    *   **User Account:** Creates a local administrator account named `moe` with a **blank password** by default. It is **strongly recommended** to change the username and set a strong password within this file or immediately after the first login.
    *   **OOBE Skip:** Skips the standard Out-of-Box Experience (user setup questions, network setup, etc.).
    *   **UAC:** Temporarily disables User Account Control (UAC) during setup for silent installations. `enableUAC.ps1` is run at the end to re-enable it.

*   **`chocolatey.ps1`**: A PowerShell script that downloads and installs the Chocolatey package manager. This is executed by `Autounattend.xml` during the FirstLogonCommands phase.

*   **`chocolatey-apps.cmd`**: A command script that uses Chocolatey to install a predefined list of common applications.
    *   This script is executed by `Autounattend.xml`.
    *   The entries for `flashplayerplugin` (obsolete) and a duplicate `notepad2` have been removed.
    *   **Important:** Users should **review and customize** this list to install only desired software. Verify application compatibility with Windows 11 before adding new packages.

*   **`disableWindowsUpdates.ps1`**: A PowerShell script that attempts to disable automatic Windows Updates by modifying registry settings and interacting with a COM object.
    *   **Caution:** Completely disabling Windows Updates is generally **not recommended** due to security risks. Windows 11 may also be more aggressive in re-enabling updates or overriding these settings. Users should understand the implications or use alternative update management strategies. Its effectiveness in the long term on Windows 11 is not guaranteed.

*   **`enable-rdp.ps1`**: A PowerShell script that enables Remote Desktop Protocol (RDP) access and adds a firewall rule to allow RDP connections.

*   **`enableUAC.ps1`**: A PowerShell script that re-enables User Account Control (UAC). `Autounattend.xml` temporarily disables UAC for silent application installs; this script ensures UAC is turned back on at the end of the setup process.

*   **`fixnetwork.ps1`**: A PowerShell script that attempts to set the network location to 'Private'. The effectiveness and necessity of this script can vary depending on the Windows version and network configuration.

*   **`microsoft-updates.bat`**: This batch script configures the system to use the "Microsoft Update" service instead of the default "Windows Update" service. This allows the system to receive updates for other Microsoft products (e.g., Office) in addition to Windows OS updates. It also configures Windows Update to include "featured" and "recommended" updates. This script is called by `Autounattend.xml`.

*   **`removeOneDrive.ps1`**: A PowerShell script that sets a registry policy key to disable/hide OneDrive integration in the operating system.

*   **`win-updates.ps1`**: A PowerShell script designed to check for, download, and install Windows Updates. It also creates a log file (`C:\Windows\Temp\WindowsUpdates.log`).
    *   **Not Integrated:** This script is **not currently called** by `Autounattend.xml` or any other part of the automated setup. It would need to be run manually post-installation.
    *   **Hardcoded Path:** Contains a reference to `a:\openssh.ps1`. If a user wishes to use this script, they must review and correct this path or remove the related functionality.
    *   **Potential Conflict:** Running this script might conflict with `disableWindowsUpdates.ps1` if the latter has been executed and is effective.

*   **`oracle-publisher.cer`, `oracle-root.cer`**: These are certificate files. Their specific use or necessity within this automation is not detailed or referenced in any other scripts. They may be remnants from a previous version or an unimplemented feature. They are not actively used by the current set of scripts.

## Customization

It is highly recommended to customize the installation to your needs:

*   **`Autounattend.xml`**:
    *   **Product Key:** Change the product key under `UserData` -> `ProductKey` -> `Key` if you are not using KMS or want to use a specific retail key.
    *   **Username/Password:** Change the username and password for the local account under `OOBE` -> `UserAccounts` -> `LocalAccounts`. (e.g., change `moe` and set a password).
    *   **TimeZone:** Update the `TimeZone` setting under `OOBE` -> `Microsoft-Windows-Shell-Setup`.
    *   **ComputerName:** Change the default computer name under `specialize` -> `Microsoft-Windows-Shell-Setup` -> `ComputerName`.
    *   Review other settings like `RegisteredOrganization`, `RegisteredOwner`, etc.

*   **`chocolatey-apps.cmd`**:
    *   Edit this file to add, remove, or change the applications installed by Chocolatey. Refer to the [Chocolatey Community Package Repository](https://community.chocolatey.org/packages) for available packages.

## Troubleshooting (Optional)

*   **Log Files:**
    *   Windows Setup logs: `%WINDIR%\Panther\` (especially `setuperr.log` and `setupact.log`)
    *   Chocolatey logs: `%ProgramData%\chocolatey\logs\`
    *   `win-updates.ps1` (if run manually) creates `C:\Windows\Temp\WindowsUpdates.log`.
*   **Common Issues:**
    *   **Incorrect USB Creation:** Ensure Rufus (or your chosen tool) is configured correctly for your system's firmware (UEFI/BIOS) and the Windows ISO.
    *   **BIOS Boot Order:** Verify your computer's BIOS/UEFI settings are configured to boot from the USB drive first.
    *   **Missing Files:** Double-check that all project files are copied to the root of the USB drive.
    *   **Hardware Compatibility:** Ensure your hardware fully supports Windows 11.
    *   **Internet Connectivity:** A stable internet connection is crucial, especially for Chocolatey.

This README provides a starting point. Users are encouraged to explore the scripts further and adapt them to their specific requirements.
