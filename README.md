# Data Bridge

---

## Overview

Data Bridge is an advanced MIDI control surface designed to provide a scalable, modular network of responsive feedback connections between rack devices in Propellerhead Reason 7+.

User feedback was made hardware agnostic wherever possible, allowing for both legacy and modern hardware to be used interchangeably.

## Why Was This Made?

The complexity of this design represents the best effort to facilitate solutions to the preference of creative spontaneity and immediacy of use that was at the forefront of discussion within the customer base of Reason 7 upon its release.

The specific areas that were addressed were:
- Cumbersome interaction with MIDI hardware
- Lack of support for live performance
- Inflexible automation

Typical use of control surfaces in Reason involve binding a surface to a given device for the purpose of providing specific control.

Data Bridge is so-named because it allows the state of a given device's control data (knob values, etc.) to be broadcast to additional devices.

Applying MIDI data as a distributed network allows for unprecedented expressive control, as well as organically random auto-modulation.

---

## Installation

1. Attach a physical MIDI 5-pin In and Out port to your computer.
2. Physically loop these ports with a MIDI cable (Out to In).
3. If **Reason** is running, exit the program.
4. Download this package locally.
5. Move the `DataBridge` folder in `Codecs/Lua Codecs` to the local `Codecs/Lua Codecs` folder used by your install of **Reason**.
6. Move the `DataBridge` folder in `Maps` to the local `Maps` folder used by your install of **Reason**.
    * For Help with 3 and 4, Please See:
    https://www.propellerheads.com/blog/control-remote
7. Start **Reason**.
8. Navigate to **Preferences > Control Surfaces > Add** and confirm that `DataBridge` appears as a manufacturer.
    * If this step fails, confirm folders were copied to the correct locations and restart **Reason**.
9. Exit **Preferences**.
10. Open the `Local Workspace` song project from the `Templates and Patches` folder in this package.
11. Expand the contents of the `UI Device` **Combinator** to reveal the **External MIDI Instruments** (**EMI**) within the patch.
12. Adjust the MIDI Port of all **EMI** units to reflect the physically looped port you attached in step 1.
    * NOTE: On **Mac**, select the port that does not contain the word _"virtual"_.
13. Save the song project where you would like, then close the file and open a new blank project.
14. Navigate to **Preferences > General** and set the template song project you saved in step 13 as your default template for new projects.

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