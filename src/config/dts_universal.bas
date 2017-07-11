/'* \file dts_universal.bas
\brief Tool for creating an universal device tree overlay (run-time pinmuxing)

This file contains the FB source code for a helper tool creating an
universal device tree overlay. Adapt this code for your needs, compile
it and run the executable. This will create a device tree overlay
source file in the current directory, and, if you execute the binary
with root privileges, this overlay gets compiled and installed in the
specified directory (usually /lib/firmware).

The created universal overlay provides pinmuxing capability at
run-time. The user can choose from a set of reasonable predefined pin
configurations (modes). Root privileges are required to change the
mode.

In order to create predefined (standard) overlays, compile the code by
executing

    fbc -w all dts_universal.bas

and run the executable

    ./dts_universal

This will create a complete (all header pins and the JTag pins) overlay
source file named `libpruio-00A0.dts` in the current directory.

In order to create and install that overlay, execute with root
privileges and add the destination path as parameter

    sudo ./dts_universal /lib/firmware

Such an (complete) overlay wont load since there're conflicts with pins
claimed for the board. In order to free those pins, specify your
BeagleBone model as second parameter

    sudo ./dts_universal /lib/firmware BBW

The available models are

- BBW for BeagleboneWhite
- BBB for BeagleboneBlack
- BBG for BeagleboneGreen

The latest command will also create a device tree source file named
`libpruio-00A0.dts` in the current directory and the compiled version
in file `/lib/firmware/libpruio-00A0.dtbo`.

If you want to free further pins (ie. to solve conflicts with a cape),
you can adapt the source code before compiling and running the tool. In
the code, first, the pin modes for all header pins get specified in
files `P8.bi`, `P9.bi` and `JTag.bi` (all header pins get declared).
Then the code frees unwanted pins, either by deleting the
configurations for a pin group (defined in pruio_pins.bi) by a line
like

    PIN_DEL(HDMI_Pins)

or you can free a single pin by deleting its declaration by a line like

    M(P9_41) = ""

Once you adapted the code to your needs, compile and run it by

    fbc -w all dts_universal.bas
    sudo ./dts_universal /lib/firmware

Then load the overlay by (kernel <= 3.8)

~~~{.txt}
sudo su
echo libpruio > /sys/devices/bone_capemgr.*/slots
exit
~~~

or on kernel versions > 3.8

~~~{.txt}
sudo su
echo libpruio > /sys/devices/platform/bone_capemgr/slots
exit
~~~

(Or execute this `echo ...` command in your boot sequence. Or use
capemgr to load the overlay. See \ref SecPreconditions for further
information.)

Licence: GPLv3

Copyright 2014-\Year by \Mail

\since 0.2
'/


#INCLUDE ONCE "pruiotools.bas"

'''''''''''''''''''''''''''''''''''''''''''''''''''''''' adapt this code

'* The file name.
#DEFINE FILE_NAME "libpruio"
'* The version.
#DEFINE VERS_NAME "00A0"
'* The folder where to place the compiled overlay binary.
VAR TARG_PATH = "./"
'* The BB model.
VAR COMPATIBL = ""

' quick & dirty: first create settings for all pins ...
#INCLUDE ONCE "P8.bi"
#INCLUDE ONCE "P9.bi"
#INCLUDE ONCE "JTag.bi"

''''''''''''''''''' ... then delete unwanted pin groups (or single pins)
SELECT CASE UCASE(COMMAND(2))
CASE "BBW"
  PIN_DEL(EMMC2_Pins)
  'PIN_DEL(I2C1_Pins)
  'PIN_DEL(MCASP0_Pins)
  COMPATIBL = "ti,beaglebone-white"
CASE "BBG"
  PIN_DEL(EMMC2_Pins)
  'PIN_DEL(I2C1_Pins)
  'PIN_DEL(MCASP0_Pins)
  COMPATIBL = "ti,beaglebone-green"
CASE "BBB"
  PIN_DEL(HDMI_Pins)
  PIN_DEL(EMMC2_Pins)
  'PIN_DEL(I2C1_Pins)
  'PIN_DEL(I2C2_Pins)
  PIN_DEL(MCASP0_Pins)
  COMPATIBL = "ti,beaglebone-black"
CASE ELSE ' all pins
END SELECT
''''''''''''''''''''''''''''''''''''''''''''''''''''''' end of adaptions

CREATE()
