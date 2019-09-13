# DataBridge

---

## Index

- [Project Overview](#project-overview)
- [Do I Need This?](#do-i-need-this)
- [Why Was This Made?](#why-was-this-made)
- [What Does This Do?](#what-does-this-do)
- [Disclaimers](#disclaimers)
- [Installation](#installation)
- [Keyboard Controls](#keyboard-controls)
- [Hardware Setup](#hardware-setup)
- [First Things First](#first-things-first)
- [Practical Example](#practical-example)
- [How Does This Work?](#how-does-this-work)

## Project Overview

**DataBridge** is an advanced MIDI control surface designed to provide a scalable, modular network of responsive connections between rack devices in **Propellerhead Reason 7+**.

In short, this system allows the user to make connections on the front of devices.

Connections can be responsive to either MIDI input or the rack environment itself.

Support for MIDI input was designed to be hardware agnostic wherever possible. This allows both legacy and modern hardware to be used interchangeably.

## Do I Need This?

This system is, at its heart, a gigantic workaround for many features that are still missing in Reason (to date). If you want to avoid workarounds, this will not be very much fun for you.

That said, it depends whether you want to incorporate pseudo-random _organic sound design_ into your projects and/or _live performance capabilities_ into your workflows. If you prefer to retain control and be more scientific with all aspects of your work, this might not suit your tastes.

## Why Was This Made?

This project represents the best efforts at answering the call for missing features within **Propellerhead Reason 7** upon its release by providing a strong and comprehensive implementation of MIDI response that allows for live performance and organic sound design.

In short, it was made to redefine what is possible in **Reason**.

## What Does This Do?

- #### Deep MIDI Integration

  - Interaction with MIDI is now hardware agnostic, allowing for easy setup of multiple simultaneously connected device types including TouchOSC.

- #### Support for Live Performance

  - Powerful implementation of chained control mappings allow for distributed networks of MIDI response whose expressive capabilities are only limited by one's own imagination and computer specs.
  - This concept was taken even further with long live sets and duos in mind by wrapping support for distributed MIDI response inside a system of virtual layers; enabling the entire rack to be controlled using a scene/page system.

- #### Auto Modulation

  - An optional advanced feature allows for interpolation between values for knobs, sliders, and any other controls that can receive Remote Overrides.
  - Smoothness can be controlled using a custom wave table and transition speed setting.
  - Automation can even be automated to modulate itself, eliminating the need for automation lanes -- _and the CPU consumption caused by them._

- #### Audio Warping

  - A second optional advanced feature allows samples to be pitched in nonlinear ways while still preserving their original timing. Think of it as audio transpose with note glide.
  - Different time-stretching algorithms will give different results, allowing audio captures through the technique to become metallic, robotic, or tonal

---

## Disclaimers

> This guide will show examples based on **MacOS Mojave 10.14** and a **Native-Instruments Maschine Mk2** as the connected MIDI device. _Please substitute your MIDI hardware where applicable._
>
> This guide also assumes that **no other MIDI settings have already been specified** prior to the addition of these control surfaces. Additional troubleshooting may be required if you have a unique MIDI configuration already present in Reason.

> **Use of this system effectively removes Undo functionality from Reason while it is in operation. _This change is not permanent and will not harm your install._ This system is provided open source as-is and without warranty.**

## Installation

1. #### Quit Reason

   - This installation process requires Reason to be closed completely.

2. #### Enable IAC Bus (Mac Only)

   - Press `Command + Space` and type `midi`.
   - Double-click `Audio MIDI Setup` from the list of applications.
   - Press `Command + 2` to open the MIDI Studio tab.
   - Double-click the `IAC Driver`.
   - Check the box marked **Device is online** to enable the driver.

More information on this [here](https://re-compose.desk.com/customer/portal/articles/1382244-setting-up-the-iac-bus-on-a-mac)

3. #### Physical MIDI Port (Windows, Mac Optional)

   - You can alternatively drive the system by attaching USB hardware that has a physical MIDI 5-pin In and Out port to your computer.
   - Physically loop these ports with a male-male **MIDI loopback cable** (Out port to In port)
     > **NOTE:**
     >
     > - **MIDI over IP with CopperLAN has been tested and is supported by the system.**
     > - **Unfortunately, LoopBe1 will not work.**

4. #### Install Package Locally

   - **Download** this project as a zip file and extract it into a directory of your choice.
   - You can also use `git clone` over **SSH** if you have `git` installed.

     <img src="./images/db-download.png" alt="clone and download options" width="400">

5. #### Install Files

   - Locate the `Codecs/Lua Codecs` folder in your local install of this project.
   - Move the `DataBridge` folder into the `Codecs/Lua Codecs` folder used by your install of **Reason**.
   - Locate the `Maps` folder in your local install of this project.
   - Move the `DataBridge` folder into the `Maps` folder used by your install of **Reason**.
     > **For Help with Step 5, Please See:** [Control Remote](https://www.propellerheads.com/blog/control-remote)

6. #### Configure Workspace File

   - Start **Reason**.
   - Navigate to the `Templates and Patches` folder in your local install of this project.
   - Open the `Local Workspace.reason` file.
   - Navigate to the **Options** menu and turn on **Enable Keyboard Control**.

      <img src="./images/enable-kb-option.png" alt="enable keyboard control" width="400">

   - Locate the `DB Main` Combinator in the rack.

      <img src="./images/db-console.png" alt="db main combinator" width="400">

   - Turn on **Show Devices** to reveal the patch contents.
   - Configure the output port of each **External MIDI Instrument** (**EMI**)to use the Out port you looped in [step 2](#enable-iac-bus-mac-only) or [step 3](#physical-midi-port-windows-mac-optional) of this section, as shown in the example below.

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

## Keyboard Controls

The following **Keyboard Controls** are embedded in the `Local Workspace.reason` template:

- ### Legend

  - #### Standard Interface

    | DB Main                                        |                |
    | :--------------------------------------------- | :------------- |
    | <a id="clock-on-off"></a>Clock On/Off          | **Shift + /**  |
    | <a id="edit-min"></a> Edit Min                 | **Shift + ,**  |
    | <a id="edit-max"></a> Edit Max                 | **Shift + .**  |
    | <a id="bipolar-unipolar"></a> Bipolar/Unipolar | **Shift + \\** |

  - #### Advanced Interface

    | DB Curve                           |               |
    | :--------------------------------- | :------------ |
    | <a id="edit-curve"></a> Edit Curve | **Shift + ;** |
    | <a id="edit-step"></a> Edit Step   | **Shift + [** |

  - Figure 1:

    <img src="./images/db-ui-kb-mappings.png" alt="keyboard controls" width="400">

  - #### Master Mono Mix

    **DataBridge** also includes a pre-configured **mastering suite** called `Send 10` that includes a master mono mix fader. The mastering suite can be deleted without compromising the functionality of DataBridge if you want to remove it.

    | Mono Mix                              |               |
    | :------------------------------------ | :------------ |
    | <a id="stereo-width"></a>Stereo Width | **Shift + M** |

  - Figure 2:

    <img src="./images/mixer-mono-kb-mapping.png" alt="mono mix stereo width" width="50">

## Hardware Setup

**DataBridge** uses a select number of **MIDI Control Change** (**CC**) values to perform editing functions from hardware. These CC values effectively duplicate the Combinator buttons found on `DB Main` and `DB Curve` in the rack. This enables performers or producers to achieve the same results without having to stop using their controller.

The following CC values are reserved by the DataBridge system:

- ### Legend

  - #### Surface: DataBridge MIDI Controller

    | Channel | CC Value | Action                         |
    | :-----: | :------: | :----------------------------- |
    |    1    |    94    | System Panic<sup>\*</sup>      |
    |    1    |    95    | Bipolar/Unipolar               |
    |    1    |    97    | Edit Curve                     |
    |    1    |    98    | Edit Step                      |
    |    1    |    99    | Navigate Layers<sup>\*\*</sup> |
    |    1    |   100    | Edit Min                       |
    |    1    |   101    | Edit Max                       |
    |    8    |   119    | Clock                          |

  - #### Surface: DataBridge MIDI Controller - Deck 2

    | Channel | CC Value | Action                         |
    | :-----: | :------: | :----------------------------- |
    |    9    |    94    | System Panic<sup>\*</sup>      |
    |    9    |    95    | Bipolar/Unipolar               |
    |    9    |    97    | Edit Curve                     |
    |    9    |    98    | Edit Step                      |
    |    9    |    99    | Navigate Layers<sup>\*\*</sup> |
    |    9    |   100    | Edit Min                       |
    |    9    |   101    | Edit Max                       |
    |   16    |   119    | Clock                          |

> \* **System Panic** halts all loaded control surfaces from transmitting any data or making any calculations. This can be useful to do A/B testing of the system on and off, freezing the system in its current state, or fixing low priority problems.

| **WARNING:**                                                                                                                                                                                                                            |
| :-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Be sure to cancel System Panic before loading any new surfaces after you have pressed it. Only the surfaces that are loaded and running will respond to user input, meaning the newest surfaces will be active while the rest will not. |

> \*\* **Navigate Layers** allows the user to move up and down through the page/scene system of virtual layers. This CC is expected to be a **relative** type with polarity and a step of 1. The jog wheel on the Native-Instruments Maschine Mk2 is used for this in the provided demo materials.

## First Things First

1. #### Best Practice

   > The recommended best practice for using this system is to always have all of the `DB Main` and `DB Curve` Combinator buttons disabled and your MIDI controller(s) set to their initial state (all toggles off) when opening or closing a song project. This is important because the state of the system depends on that default scenario in order to calibrate itself during the process of loading the surfaces.

2. #### Priming the Workspace

   > When starting _**any**_ and _**every**_ project, it is essential and _**very important**_ to perform these tasks right away:
   >
   > - Right-click on any device control in the rack
   > - Select **Edit Remote Override**
   > - _Uncheck **Learn from control surface input**_
   > - Cancel out of the Remote Override editing window.
   >
   >   <img src="./images/db-learn-disabled.png" alt="make sure learn is turned off" width="400">
   >
   >   This is a side effect of the current manner in which **Reason** manages application state regarding preferences.
   >
   >   In the event that a way to persist the end user preference of not wanting to learn from control surfaces by default becomes available, this step will no longer be necessary.
   >
   > **Trivia:**
   >
   > - The cause for concern over the **learn** option is because without turning it off, it would be impossible to select **Remote Overrides** from the list of possible options once the system is running. This is because **Reason** is trying to apply every connection where data exchange is being detected, simultaneously.

3. #### Loading the Control Surface Stack

   Control surfaces are queried in an internal array within **Reason** where the _first surfaces_ to appear in the list take priority over the _last surfaces_ to appear. Usually, any latency across surfaces is unnoticeable, but it becomes necessary to plan ahead when dealing with the large amount of Remote data that this project can utilize.

   In support of this important concept, we think of control surfaces as a "stack" where the surface at the top of the list is most important, while those toward the bottom are allowed to experience delays (if they occur) because they are not as critical in our setup.

   Here follows my best recommendation for the top entries of any custom stack you design:

- ### MIDI Controller

  - Navigate to **Preferences > Control Surfaces > Add**.

    <img src="./images/db-add-surface.png" alt="add new surface" width="400">

  - Locate the **DataBridge** manufacturer in the list.

    <img src="./images/db-manufacturer.png" alt="select data bridge manufacturer" width="400">

  - Select the **MIDI Controller** surface from the dropdown.

    <img src="./images/db-midi-in-list.png" alt="select midi controller surface" width="200">

  - Mac Users:

    If you have enabled the `IAC Bus` as described in [step 2 of Installation](#enable-iac-bus-mac-only), you can select the **IAC Bus Driver** option for both **Loopback Input** and **Loopback Output** for all control surfaces you load in.

    Otherwise:

    - Select the **Loopback Input** port that does **not** contain the word _"virtual"_
    - Select the **Loopback Output** port that does **not** contain the word _"virtual"_
    - Select the **UI Input** port that **does** contain the word _"virtual"_

      <img src="./images/midi-controller-add.png" alt="mac user port configuration" width="400">

  - Windows Users:

    - The same as Mac Users, but you can leave **UI Input** empty.

      > **NOTE:**
      >
      > - If you want to use **TouchOSC** on either _Mac_ or _Windows_, you will need to select it inside **UI Input** for it to work.
      > - You can have your **Loopback Input** and **Output** running together on a separate looped port and use a different controller with its own connection to bring in data from **UI Input**.

  - Click OK to add the surface to the list.

- ### (Optional) MIDI Controller - Deck 2

  - Same as above, but you'll need another looped port to drive the second controller.
  - This optional second deck can also have its own TouchOSC or similar setup, allowing 4 controllers at once as the maximum configuration possible.

- ### Reason Document

  - Follow the same steps as above with respect to the **Reason Document** surface

    <img src="./images/document-surface-default.png" alt="reason document surface" width="400">

- ### Reason Master Section or Reason Main Mixer

  - The same steps above apply to these surfaces, however, they are mutually exclusive and _only one can be loaded at a time_.
    > - The **Reason Master Section**
    >
    >   - Loads quickly.
    >   - Enables use of all functionality in the **Master Section** device in the rack.
    >   - Can be used in combination with the **Mix Channel** surface.
    >
    > - The **Reason Main Mixer**
    >
    >   - Loads _very slowly_.
    >   - _**Not recommended for practical use.**_
    >   - Enables use of all functionality in the **Master Section** device in the rack.
    >   - Enables use of all functionality across up to **64 Mix Tracks** in the **Main Mixer**.
    >   - Can be extended using the **Mix Channel** surface in case _64 channels_ aren't enough.
    >
    >     <img src="./images/master-surface-default.png" alt="reason master section surface" width="400">

- ### ReGroove Mixer

  - Repeat the same steps as above for the **ReGroove Mixer** surface.

    <img src="./images/regroove-surface-default.png" alt="regroove mixer surface" width="400">

4. #### Ignore Triangle Warnings

   - By now you will see a **yellow warning triangle** next to all of the surfaces in the list. You can ignore these. All they are alerting us to is the fact that all of the surfaces share the same MIDI port. This is actually a good visual reference, because without that yellow triangle the whole system wouldn't work.

       <img src="./images/db-ignore-triangles.png" alt="ignore triangle warnings" width="400">

5. #### Disabling Master Keyboard

   - Once all of these surfaces are loaded, make sure that you have chosen to **Use No Master Keyboard** before you close the **Control Surfaces** list.

   - Assigning a **Master Keyboard** instructs **Reason** to disable certain MIDI connections internally in favor of others. This can result in undesired behavior inside of **DataBridge**.

   - _**Be careful to check this each time you load a surface designed for an instrument. Reason currently does not have persisted state for this preference.**_

     <img src="./images/db-use-no-master-kb.png" alt="disable master keyboard" width="400">

6. #### Locking the Control Surface Stack

   - Navigate to **Options > Surface Locking...**
   - Here you can apply the following adjustments to the stack we loaded in step 4 of this section:

     | Surface                  | Device Lock Destination        |
     | :----------------------- | :----------------------------- |
     | MIDI Controller          | _(do not assign lock)_         |
     | MIDI Controller - Deck 2 | _(do not assign lock if used)_ |
     | Reason Document          | Hardware Interface II          |
     | Reason Master Section    | Master Section                 |
     | Reason Main Mixer        | Master Section _(if used)_     |
     | ReGroove Mixer           | ReGroove Mixer                 |

   - A possible example stack list follows:

       <img src="./images/surfaces-stack.png" alt="surface locking options" width="400">

## Practical Example

Finally, at long last we have arrived at the main event. This example is provided as a good starting point, but you can definitely take it a lot farther.

Once you get comfortable with the workflow, many new possibilities will begin to present themselves in future projects.

1. Basic Automatic Modulation Chain

- Add a BV512 surface and a PEQ2 surface to the default stack.

  <img id="addSurfacesExample" src="./images/add-bv512-and-peq2.png" alt="add surfaces for modulation" width="355">

- Load in a Subtractor and a PEQ2 with a BV512 loaded in as an insert effect for the Mix Channel, like so:

  **Front**

  <img id="modulationSetupFront" src="./images/loaded-devices.png" alt="front view of example setup" width="355">

  **Back**

  <img id="modulationSetupBack" src="./images/loaded-devices-back.png" alt="front view of example setup" width="355">

- Lock the BV512 surface to the Vocoder. You can verify it using **Options > Remote Override Edit Mode**, like this:

  <img id="vocoderEditMode" src="./images/verify-bv512-surface-lock.png" alt="check vocoder surface lock" width="355">

- Lock the PEQ2 surface to the EQ. It should look like this if you decide to double-check:

  <img id="eqEditMode" src="./images/verify-peq2-surface-lock.png" alt="check eq surface lock" width="355">

  Note: nevermind the lightning bolt. We will be creating these mappings in the following steps.

- Set the patch of the Subtractor to roughly these settings:

  <img id="subtractorPatch" src="./images/subtractor-settings.png" alt="subtractor patch settings">

- ### **Now for the fun part. Time to setup our first modulation chain!**

  - Map the following Remote Override connections:
  - **Remember to disable Learn From Incoming MIDI if it is on by default.**

    | Control Surface     | Control                         | Map Override to...         |
    | :------------------ | :------------------------------ | :------------------------- |
    | DataBridge BV512... | Mod Level 1 - Output 1          | PEQ2 - Filter A Gain       |
    | DataBridge BV512... | Mod Level 4 - Output 2          | Subtractor - Mod Wheel     |
    | DataBridge BV512... | Mod Level 8 - Output 1          | Subtractor - FM Amount     |
    | DataBridge BV512... | Mod Level 12 - Output 1         | Subtractor Osc Mix         |
    | DataBridge BV512... | Mod Level 16 - Output 1         | PEQ2 - Filter B Freq       |
    | DataBridge BV512... | Modulator Peak Meter - Output 1 | Subtractor - Mod Env Decay |
    | DataBridge PEQ2...  | Filter A Gain - Output 1        | Subtractor Osc 1 Phase     |
    | DataBridge PEQ2...  | Filter A Gain - Output 2        | Subtractor Osc 2 Phase     |

  - Press `Shift + /` or click the `Clock` button to enable it.
  - Press `Shift + ,` or click the `Edit Min` button to enable it.
  - When making the following adjustments, there may be some values that are the default. It is important to move the knobs anyway and then use `Command + Click` to restore the default, otherwise the edit function will not detect the correct value for that control:

    | Device       | Control       | Value |
    | :----------- | :------------ | :---: |
    | Subtractor 1 | Osc 1 Phase   |  44   |
    | Subtractor 1 | Osc 2 Phase   |  84   |
    | Subtractor 1 | Osc Mix       |  32   |
    | EQ 1         | Filter A Gain |   0   |

  * Press `Shift + ,` or click the `Edit Min` button to disable it.
  * Press `Shift + .` or click the `Edit Max` button to enable it.
  * Make the following adjustments, again moving knobs and restoring defaults if required for a specified default value:

    | Device       | Control       | Value |
    | :----------- | :------------ | :---: |
    | Subtractor 1 | Osc 1 Phase   |  84   |
    | Subtractor 1 | Osc 2 Phase   |  44   |
    | Subtractor 1 | FM Amount     |   4   |
    | Subtractor 1 | Osc Mix       |  96   |
    | EQ 1         | Filter A Gain |  -64  |

  * Press `Shift + .` or click the `Edit Max` button to disable it.
  * For the purposes of this example, we will add the extraneous step of disabling the `Clock` by pressing either `Shift + /` or clicking the `Clock` button.

    (In ordinary operation this is not necessary.)

  * Sequence any pattern of notes for the Subtractor you want, a simple loop of a single clip will do. We just need some sound coming out of the synth.
  * Begin looped playback of the Subtractor.
  * Once you have gotten used to the sound, press `Shift + /` or click the `Clock` button to enable the system.
  * If the system does not engage, troubleshoot your MIDI ports inside of the EMIs to make sure they do not show "offline" as in this example:

  <img id="troubleshootEMI" src="./images/midi-port-troubleshoot-tip.png" alt="troubleshoot emi port assignments" width="710">

  - If the system engaged, you can immediately hear the difference. An auto-modulated synth!

  - To A/B test the difference between the vanilla experience of "set and forget" patch settings and the new auto-modulated settings, toggle the `Hold` button on **Vocoder 1**.
  - For a more extreme A/B test, toggle the `Clock` button on and off.

  This is a very simple setup that doesn't explore a lot of exaggerated or crazy sound design concepts that this system is capable of. The intent here is to see how much more life can be breathed into even very simple instruments and effects if they are allowed to dynamically modulate their settings rather than sit static or only move in a linear way (pre Reason 11, at least).

  Here is what we have been able to learn through this simple exercise:

  - How we can connect two devices together (Locked Surface to Remote Override mapping).
  - How we can chain connections between devices to create modulation chains (BV512 to PEQ2 to Subtractor).
  - How we can make Combinator-like programming adjustments where we want, when we want.
  - How each mappable output from a control can have its own polarity (Osc 1 Phase, Osc 2 Phase).
  - How only the controls we have edited reflect our changes, otherwise they use their minimum and maximum possible values as default (Mod Wheel, Mod Env Decay, Filter B Freq).
  - How sources of data that were previous inaccessible to us can now be used to drive changes on other devices (Modulator Peak Meter).

You can now take the knowledge of what we've covered here and apply these same principles to things like subtle auto-modulation of ReGroove amounts for your percussion, or stopping the tale of your reverbs automatically when the stop button is pressed in the transport. You can even bind a simple button's automated "on / off" blink to create powerful Punch In / Punch Out during recording.

And the best part is, by using this system instead of standard automation lanes, you save the CPU that would be consumed by calculating those adjustments in the sequencer. This example is a very simple beginning compared to what you can do with it.

The previous simple exercise represents the core fundamentals of putting this system into practice. But how does all of this work?

## How Does This Work?

<img id="midiDiagram" src="./images/db-midi-flow.png" alt="block diagram of global midi flow" width="355">

_Figure A._

The implementation of the **Remote** protocol in **Reason** was designed to handle incoming MIDI data, so it is effectively blind to data changes within Reason because no incoming MIDI is received. To allow the locked surfaces of **DataBridge** to "see" data changes in the rack and read the values of those changes, we must send a pulse of MIDI into Reason (Clock On/Off button). Receiving this pulse triggers the following sequence of events as shown in the diagram:

- ### MIDI Flow

  - MIDI pulse from `Clock` **EMI** inside `DB Main` is looped in
  - Control surface "stack" is iterated
  - Each surface fires "**remote_set_state**" MIDI handler
  - Value of all **Inputs** for the surface are read
  - **Input** values are stored in a global variable ("**g_batch**")
  - "**remote_process_midi**" fires to handle the incoming MIDI
  - Contents of "**g_batch**" array are written to the surface **Outputs**
  - Surface **Outputs** are the **Remote Overrides** we map to make connections
  - **Result:**
    - changes in value on **Input(s)** are written as changes to mapped **Output(s)**

Because we can make such a large volume of changes at once, it would be impossible to send a MIDI value specific to each connection between device controls. Instead, we send a single global pulse of MIDI through the Loopback Output and Loopback Input ports, then read input values directly from the rack in all the locked surfaces before writing new output values to all of the mapped Remote Overrides.

This means that no MIDI data is being passed between devices when making changes. _All data is handled internally inside of all the locked surfaces_. Additionally, all unmapped Remote Overrides are ignored, reducing latency wherever possible.

> It is worthy to note that much of the complexity of installation and latency encountered when putting this system into heavy use within a project could be eased by allowing Remote to directly query the rack using a scripted loop instead of strictly requiring incoming MIDI.

Incoming MIDI information from either a controller or from the looped **EMI** signals found inside the `DB Main` and `DB Curve` **Combinators** (listed at top-left of diagram) are also handled in this same way, but since they are MIDI information themselves, they do not require a pulse from the `Clock` **EMI** to work.

To simplify these concepts, you can think of these input messages from controllers and in-rack interfaces as being merged with the looped pulse that runs the data handling.

## Mapping Connections in the Rack

This has been a lot of technical jargon. The following image can help us develop a stronger understanding of the general structure of how the locked surfaces and Remote Overrides work in this system:

  <img id="surfaceDiagram" src="./images/db-diagram.png" alt="block diagram of locked surface data flow" width="300">

_Figure B._

When a **DataBridge** surface is locked to a device, all of the device's controls become bound to the default **Inputs** in the surface script. These are the values that DataBridge reads using **remote_set_state** as explained in _Figure A_ in the previous section.

The locked surface then calculates a scalar value between 0 and 1 based on the data value for a given Input, as well as its associated minimum and maximum values as programmed by the user, if any.

This scalar value is then multiplied by the difference of the minimum and maximum values associated with each of the specific Remote Overrides that act as the "virtual outputs" for the given Input.

The resulting products of these multiplications are then stored into a global array named **g_batch** until the contents of the array are written to the Remote Overrides the next time **remote_process_midi** fires.

If the destination device where the Remote Overrides are mapped also has a DataBridge surface locked to it, a **modulation chain** can be established with more than one device connected in series.

The first device in a modulation chain can be driven by automation changes or direct MIDI input as well as Remote Overrides from a MIDI Controller surface provided by DataBridge.

> **NOTE:** Because Reason does not support instancing or concurrency of control surfaces, you must create a new surface for every device you want to control with this system. At this time, loading control surfaces in Reason does not afford any way of defining "packaged" configurations for quick loading. If this feature becomes available in the future it would greatly reduce the pain point of manually loading individual surfaces.

Now that we have covered how surfaces can be chained and the general functionality of how they handle data, you can begin creating connections between devices by mapping Remote Overrides however you would like.

There is only one rule that you must follow when mapping Remote Overrides.

- Remote Overrides must be mapped to another device, not the source device that is generating the Remote Overrides.
- To put it more simply, devices must not map Remote Overrides back to themselves.

While this won't break anything in a catastrophic way, the rule exists because any device that does map back to itself is not able to drive modulation chains. Some aspects of data handling may also behave unpredictably because the data is looping in on itself instead of broadcasting to an outer destination.

## Activating the DataBridge System

In the example we saw how activating the system is as simple as enabling the `Clock On/Off` button on the `DB Main` Combinator. Once activated, all surfaces loaded into **Reason** will begin processing data as expected, according to the pulse rate setting of the `Clock Rate` rotary knob.

> **WARNING:** It is absolutely imperative that you do not select or interact with any **External MIDI Instrument** (**EMI**) devices in the rack while the DataBridge system is activated. Doing so will create an endless loop of MIDI information inside of Reason that cannot be fixed without completely quitting the app and restarting it. This will cause all custom modulations in the open project to be lost.

## Programming Custom Modulations

Each device control that receives manipulations from a mapped "virtual output" Remote Override can be programmed to exhibit unique behavior as desired. All programming takes place where it is desired by manually adjusting affected controls. The basic adjustments that can be made are specifying minimum and maximum values.

To change the minimum or maximum value, simply activate either the `Edit Min` or `Edit Max` button while the `Clock On/Off` button is active, then adjust the control you want to program changes into. Once the value has been set, deactivate the `Edit Min` or `Edit Max` button to write the value into the DataBridge system.

If you activate both the `Edit Min` and `Edit Max` buttons at once, the device control will receive a static value that will not change in response to manipulations from hardware or automation clips.

If you set a larger minimum value than a smaller maximum value, the polarity of the modulation will be reversed for that control.

If no changes are applied, make sure you are adjusting a control that has a Remote Override supplied by a DataBridge surface mapped to it.

You can make as many changes to mapped controls as you like without destructive results, meaning any controls that you do not adjust will remain unaltered in their expected behavior. There is only one exception to this, as follows:

> If you activate `Edit Min` or `Edit Max` while utilizing automatic modulations as provided by the **BV512 Digital Vocoder**, the automatic adjustments will destructively reprogram all connections that are driven by the virtual outputs of the vocoder's DataBridge control surface.

That said, in order to apply automatic modulations in response to audio, you can easily map the `Mod Level` outputs of the BV512 unit to automatically drive modulation chains. Just be careful when reprogramming.

## Interpolating Modulations

Support for nonlinear automation changes similar to curved automation is included in DataBridge as an optional feature. Activation of this advanced tool is at the user's discretion.

To engage the optional interpolation of control changes, you must activate the `Edit Curve` or `Edit Step` buttons on the `DB Curve` Combinator in a very similar fashion to the way `Edit Min` and `Edit Max` are used to program custom modulations in the previous section.

Once `Edit Curve` is activated, adjusting the value of a control will set the type of curve applied to smooth between its values. The curve types are effectively a smooth and continuous custom wave table whose unique values are as follows:

| Value | Description                       |
| :---- | :-------------------------------- |
| 0     | Instant / On                      |
| 18    | Reciprocal / Fast Attack          |
| 36    | Logarithm / Ease-In               |
| 54    | Sine / Ease-In-Out                |
| 73    | Tangent / Hesitate                |
| 91    | Inverse Logarithm / Ease-Out      |
| 109   | Inverse Reciprocal / Fast Release |
| 127   | Hard Delay / Off                  |

The default setting is "Instant".

> **Note:** If you are adjusting interpolation values for a control that involves settings outside the range of 0 to 127, you will have to calculate corresponding settings within that range of values. Each value is evenly spaced one seventh (1/7) of the total range of values for the given control being edited.

When `Edit Step` is activated, adjusting the value of a control will change the speed of the interpolation between its values. The range of values varies as follows:

| Value | Description                                            |
| :---- | :----------------------------------------------------- |
| 0     | Slowest (127 pulses of `Clock` EMI in `DB Main`)       |
| 127   | Fastest (1 pulse, effectively an "Instant" curve type) |

The default setting is "Fastest".

It is important to understand that editing the `Curve` and `Step` for a control will not destructively edit the minimum or maximum values for those same controls. Each control that is adjusted during any given edit mode is only updated with respect to the modes that are currently active (buttons toggled on). All other features that are not in use will not be affected.

## Warped Audio Resampling in the Sequencer

DataBridge also includes support for an advanced method of warping audio. This is accomplished by applying a calculation that adjusts the BPM of the transport bar to match the playback speed of a sample, given an arbitrary pitch bend value.

**In short, it is possible to bind the recording speed of the song project to the pitch of a sample.**

The purpose behind this feature is to allow for nonlinear resampling where the pitch of a sampler and the recording speed of an audio track can be matched 1:1. The result, when played back at a fixed tempo using the time-stretch algorithms, is a "warped" version of the sample that exhibits nonlinear changes in pitch while preserving the original timing of the sample.

This is in stark contrast to the fixed, global change in root semitone that occurs when applying transpose to an audio sample. Also, under normal conditions, pitched samples exhibit faster or slower playback speeds compared to the original recording.

You can think of this as an abstract form of note glide, but for audio recordings.

This advanced functionality is made available inside of the DataBridge surfaces designed for use with the Combinator and the stock instruments. The instrument surfaces allow for a maximum range of plus or minus 24 semitones and will respond to changes in pitch bend range. The Combinator surface allows for a maximum range of plus or minus 60 semitones and restricts the base tempo of the song project to 32 BPM while in use.

The feature is activated by binding the `Pitch Bend - To Tempo BPM` and `Pitch Bend - To Tempo Decimal` Remote Overrides to their intended destinations on the transport bar. Please insure you have selected the correct surface if you have multiple instruments integrated into your DataBridge configuration.

> **Note:** If adjustment of the pitch wheel does not succeed in adjusting the tempo settings on first use, follow these steps:
>
> - Open Preferences > Control Surfaces.
> - Deactivate the surface mapped to the transport controls.
> - Activate `Clock On/Off` on `DB Main`.
> - Reactivate the surface mapped to the transport controls.
> - Confirm tempo changes by adjusting pitch wheel.
> - Repeatedly toggle the surface mapped to the transport controls until adjustment succeeds in changing tempo.

In order to make practical use of this feature, you must activate the **Rec Output** option on the device whose pitch wheel is bound to the transport speed controls. Record the output of the device on a dedicated Audio Track in order to print a "warped" clip based on the original audio source.

If you intend to use the Combinator surface with its larger plus or minus 60 semitone range, you must use a CV Spider Merger/Splitter to scale up the pitch wheel value to 2.5 times normal. This can be accomplished using three copies of the pitch from the splitter section passed through two values of 127 and one value of 63 for the three trim knobs on the merger section. Apply the final output of the spider's merger to the pitch input of the sampler or instrument you want to use.

Once the audio has been warped by capturing to audio track, you can either clear the Remote Overrides from the tempo controls, or otherwise deactivate the surface related to those mappings before playing back the result at the desired BPM. Experiment with different stretch algorithms to hear different textural results.

Be advised that warping upward will introduce a lot of harmonics because the playback speed will overtake the rate at which values of project tempo can be changed. In other words, the higher the pitch, the more chaos and imprecision the result will have.

Generally speaking, use of the instrument surfaces will be more predictable and musical, while use of the Combinator surface is intended for extreme manipulations or avant-garde applications.

The restriction of the project's working tempo to a setting of 32 BPM is a requirement imposed by the maximum pitch bend a sampler can achieve, which is roughly plus or minus 5 octaves (60 semitones). This is equivalent to a change in speed that ranges from one thirty-second (1/32) the original playback at its slowest, or a BPM of 1; and thirty-two (32) times the original playback at its fastest, or a BPM of 1024 (999 being maximum possible). This drastic range in possible speeds requires a baseline project speed of 32 BPM in order to maintain the preservation of original timing contained in the sample being warped.

While samples were the original focus of this technique, you can also warp the standard output of instruments or effects to achieve unexpected results.

## Persistence of State in Your Projects

Unfortunately, there is no support for persistence of state within control surfaces inside of Reason as of the time of this release. This is a limitation of the software as it currently stands.

_**All programmed/custom modulation settings and interpolation curve settings defined by the user will be lost under the following conditions:**_

- **Looped MIDI port is disconnected from the host computer**
- **Project is closed**
- **Computer is hibernated**
- **Computer is turned off**
- **User switches between accounts on same machine**

If future versions of Reason implement a state management system for control surfaces with support for embedding control surface configurations and data into project files to address this shortcoming, this section can be disregarded. Until then, use of DataBridge must be treated as volatile and sensitive to the time and place where it is used.

> **Capture all critical modulations to Audio Track to prevent loss of sound designs!**

If you want to be able to recreate a sound that is generated by the system, you will need to develop strategies for independent documentation of all pertinent details relating to your use of DataBridge that resulted in the sound you wish to reproduce. Only through manual reconfiguration of these settings will you be able to approximate the sound. Even once you reproduce a given sound, please understand that all modulations in this system are pseudo-random. No two sounds will be precisely identical even from one note to the next.

## Using the Command Terminal

The final feature set provided is a command terminal bound to the `Device Name` attribute of all surface types. Through this terminal, you can quickly setup the entire surface for immediate use, activate hidden options that allow for even more advanced control, or reset all custom modulations back to the default state when the surface was first loaded.

When using the `MIDI Controller` and `MIDI Controller - Deck 2` surfaces, you must configure them by temporarily locking them to any stock Reason device so that the command terminal can be accessed using the Device Name parameter.

> **It is important that you unlock these MIDI Controller surfaces from any rack devices once they are configured using the command terminal.**

Advanced settings that can be accessed include:

- Binding a surface to a precise midi channel.
- Unlocking the page/scene virtual layering system.
- Enabling variable speed sensitivity for compatibility with endless rotary encoders on modern hardware.

To make use of the terminal, enter one of the supported commands into the `Device Name` attribute using the syntax detailed below, then press `Enter`.

You can enter multiple commands, then name the device as you desire once programming is complete.

## Reset Surface

> **Syntax: \_r()**

| Parameter | Values |
| :-------- | :----- |
| bool      | 1      |

> **Example: \_r(1)**

Resets the surface to its initial default state.

## Global Edit of Surface

> **Syntax: \_g()**

| Parameter | Values                     | Description                |
| :-------- | :------------------------- | :------------------------- |
| channel   | 1 to 16                    | MIDI Channel               |
| bind      | 0 (false), 1 (true)        | Bind to virtual layer      |
| layer     | 1 to 8                     | Virtual layer address      |
| dataType  | enc (endless), abs (fixed) | Knob type                  |
| curve     | 1 to 128                   | Interpolation curve        |
| step      | 1 to 128                   | Interpolation speed (step) |
| inputMin  | 0 to 127                   | Input min value            |
| inputMax  | 0 to 127                   | Input max value            |
| outputMin | 0 to 127                   | Output min value           |
| outputMax | 0 to 127                   | Output max value           |

> **Example: \_g(16,1,128,enc,128,128,127,127,127,127)**

Applies all parameter values across all inputs and outputs.

## Parametric Edit of Surface

> **Syntax: \_p()**

| Parameter | Values                 | Description                                     |
| :-------- | :--------------------- | :---------------------------------------------- |
| name      | _text_                 | Name of data source                             |
| type      | sv, si, st, ov, oi, ot | Code string describing what to edit (see below) |
| arg 1     | 1 to 128               | Varies, see details below                       |
| arg 2     | 0 to 127               | Varies, see details below                       |
| arg 3     | 0 to 127               | Varies, see details below                       |

Code String Legend

| Code String | Arg 1 Val  | Arg 1 Desc                       | Arg 2 Val  | Arg 2 Desc                       | Arg 3 Val | Arg 3 Desc                      |
| :---------: | :--------: | :------------------------------- | :--------: | :------------------------------- | :-------: | :------------------------------ |
|   **sv**    |  0 to 127  | Edit min value of source (input) |  0 to 127  | Edit max value of source (input) |    N/A    | N/A                             |
|   **st**    | abs or enc | Knob type                        |    N/A     | N/A                              |    N/A    | N/A                             |
|   **ov**    |  1 to 128  | Virtual output address           |  0 to 127  | Edit min value of output         | 0 to 127  | Edit max value of output        |
|   **oi**    |  1 to 128  | Virtual output address           |  1 to 128  | Edit interpolation curve         | 1 to 128  | Edit interpolation speed (step) |
|   **ot**    |  1 to 128  | Virtual output address           | abs or enc | Knob type                        |    N/A    | N/A                             |

> **Example: \_p(Target Track Enable Automation Recording,ov,128,127,127)**

Provides a parametric editor for specific virtual outputs within the surface.

## MIDI Edit of Surface

> **Syntax: \_m()**

| Parameter | Values              | Description                          |
| :-------- | :------------------ | :----------------------------------- |
| channel   | 1 to 16             | MIDI channel                         |
| bind      | 0 (false), 1 (true) | Bind to virtual layer                |
| layer     | 1 to 8              | Virtual layer address                |
| keyboard  | 0 (false), 1 (true) | Enable/disable master keyboard input |
| keyLo     | 0 to 127            | Lowest key in keyboard split **\***  |
| keyHi     | 0 to 127            | Highest key in keyboard split **\*** |

\* = If keyLo is higher than keyHi, the surface auto-corrects to compensate. The surface will ignore keys outside of the keyboard split's range.

> **Example: \_m(16,1,128,1,0,127)**

Provides MIDI editing for the given surface.

You can create keyboard splits that are assigned to different layers using this utility.

## Keyboard Edit of Surface

> **Syntax: \_k()**

| Parameter | Values              | Description                          |
| :-------- | :------------------ | :----------------------------------- |
| keyboard  | 0 (false), 1 (true) | Enable/disable master keyboard input |
| keyLo     | 0 to 127            | Lowest key in keyboard split **\***  |
| keyHi     | 0 to 127            | Highest key in keyboard split **\*** |

\* = If keyLo is higher than keyHi, the surface auto-corrects to compensate. The surface will ignore keys outside of the keyboard split's range.

> **Example: \_k(1,0,127)**

Provides MIDI editing specific to the master keyboard for the given surface.

This is a very fast way to define finely grained keyboard splits of as little as one semitone.
