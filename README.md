# Data Bridge

---
## Contents

  - [Overview](#overview)
  - [Why Was This Made?](#why-was-this-made)
  - [Disclaimers](#disclaimers)
  - [Installation](#installation)
      - [Quit Reason](#quit-reason)
      - [Physical MIDI Port](#physical-midi-port)
      - [Install Package Locally](#install-package-locally)
      - [Install Files](#install-files)
      - [Configure Workspace File](#configure-workspace-file) 
  - [Basic Usage](#basic-usage)

## Overview

Data Bridge is an advanced MIDI control surface designed to provide a scalable, modular network of responsive connections between rack devices in Propellerhead Reason 7+.

Support for MIDI input is included and was designed to be hardware agnostic wherever possible. This allows both legacy and modern hardware to be used interchangeably.

## Why Was This Made?

The complexity of this design represents the best effort to facilitate solutions to the preference of creative spontaneity and immediacy of use that was at the forefront of discussion within the customer base of Reason 7 upon its release.

| Specific issues addressed in this build: |
| :--- |
| Cumbersome interaction with MIDI hardware |
| Lack of support for live performance |
| Inflexible automation |

Typical use of control surfaces in Reason involve binding a surface to a given device for the purpose of providing specific control.

DataBridge is so-named because it allows the state of a given device's control data (knob values, etc.) to be broadcast to additional devices.

Applying MIDI data as a distributed network allows for unprecedented expressive control, as well as organically random auto-modulation.

---
## Disclaimers

>This guide will present examples based on **MacOS Mojave 10.14** and a **Native-Instruments Maschine Mk2** as the connected MIDI device. _Please substitute your MIDI hardware where applicable._
>
>This guide also assumes that **no other MIDI settings have already been specified** prior to the addition of these control surfaces. Additional troubleshooting may be required if you have a unique MIDI configuration already present in Reason.

>**Use of this system effectively removes Undo functionality from Reason while it is in operation. _This change is not permanent and will not harm your install._ This system is provided open source as-is and without warranty.**

## Installation

1. #### Quit Reason
   - This installation process requires Reason to be closed completely.

2. #### Physical MIDI Port
   - Attach a physical MIDI 5-pin In and Out port to your computer.
   - Physically loop these ports with a male-male **MIDI loopback cable** (Out port to In port)
> **NOTE: virtual ports like LoopBe1 will not work.**

3. #### Install Package Locally
   - **Download** this project as a zip file and extract it into a directory of your choice.
   - You can also use `git clone` over **SSH** if you have `git` installed.

      <img src="./images/db-download.png" alt="clone and download options" width="400">

4. #### Install Files
   - Locate the `Codecs/Lua Codecs` folder in your local install of this project.
   - Move the `DataBridge` folder into the `Codecs/Lua Codecs` folder used by your install of **Reason**.
   - Locate the `Maps` folder in your local install of this project.
   - Move the `DataBridge` folder into the `Maps` folder used by your install of **Reason**.
> **For Help with Step 4, Please See:** [Control Remote](https://www.propellerheads.com/blog/control-remote)

5. #### Configure Workspace File
   - Start **Reason**.
   - Navigate to the `Templates and Patches` folder in your local install of this project.
   - Open the `Local Workspace.reason` file.
   - Navigate to the **Options** menu and turn on **Enable Keyboard Control**.

      <img src="./images/enable-kb-option.png" alt="enable keyboard control" width="400">

   - Locate the `DB Main` Combinator in the rack.

      <img src="./images/db-console.png" alt="db main combinator" width="400">

   - Turn on **Show Devices** to reveal the patch contents.
   - Configure the output port of each **External MIDI Instrument** (**EMI**)to use the Out port you looped in [step 2 of this section](#physical-midi-port), as shown in the example below.

      <img src="./images/db-console-patch.png" alt="db main patch" width="400">

   - Locate the `DB Curve` Combinator in the rack.

      <img src="./images/db-curve.png" alt="db curve combinator" width="400">

   - Configure its **EMI** outputs in the same manner as in the `DB Main` Combinator's patch.

      <img src="./images/db-curve-patch.png" alt="db curve patch" width="400">

   - Save the song file somewhere official. This will be your song template going forward.
   - Once `Local Workspace.reason` has been saved, close it.
   - Navigate to **Preferences > General > Default Song > Template**.
   - Set the `Local Workspace.reason` file as your new default song template as shown below.

      <img src="./images/default-template.png" alt="default song template" width="400">

> **NOTE:** _You can rename the `Local Workspace.reason` file to anything you prefer. File names remain standardized for the sake of readability._

---

## Basic Usage

Upon successful installation, simply load a stock device and lock its dedicated control surface to it from the `DataBridge` list of surfaces.
>**NOTE:** If the lock option isn't available, you will need to select _Disable Master Keyboard_ first.

Once this initial surface is locked, you can bind its outputs to any other rack unit by selecting them from the list when assigning **Remote Overrides**.

You can scale this process to create control chains of arbitrary length according to your computer's specs.

>**IMPORTANT:**
>- In order for data to propagate from one device to another, each device that is to send data out to a destination must have its own dedicated control surface locked to it.
>- A device receiving data from another device does not require a control surface by default.

Once all **Remote Overrides** have been mapped, you must prime the system by disconnecting your looped MIDI port, then plugging it back in.

Now simply activate the `Clock On/Off` button on the **Combinator** and adjust the control(s) whose outputs you mapped to a destination device.

You should see both controls moving even though you have only selected one.

>**NOTE:** You can access items that cannot be controlled by external hardware as sources for outgoing data from a device, such as VU Meters, LEDs, and others.