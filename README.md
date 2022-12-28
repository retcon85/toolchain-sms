# Overview

The `toolchain-sms` Docker image provides a common set of tools for game development for the Sega Master System.

It has been created as part of the [Retcon85](https://github.com/retcon85) project.

# Source

https://github.com/retcon85/toolchain-sms

# Usage

## Pulling the image

`docker pull retcon85/toolchain-sms`

## Using a shell alias / function (recommended)

Running native Docker commands is verbose. We recommend you set up a shell function to allow you to wrap container commands with a simple prefix. Here are some example instructions for the zsh shell. Steps for the bash shell are very similar.

1. Edit `~/.zshrc`
2. Add the following somewhere convenient:

```
export SMS_HOME="/Users/<your_username>/<your-sms-projects-folder>/"
function sms() {
  TMPVAR=$@;
  docker run --rm -it -v $SMS_HOME:/home/sms-tk/host/$SMS_HOME -w /home/sms-tk/host/$(pwd) retcon85/toolchain-sms -c $TMPVAR
}
```

3. Restart your shell
4. Run commands by prefixing them with `sms`, e.g. you can run `sms make build` in your current directory to run the `make build` command inside the container.

We recommend setting an `SMS_HOME` or similar variable, to point to a "root" location your projects will always be inside. This is because Docker cannot leave the context in which it is running, so you can't use so many `..` path segments that you leave the context.


## Running directly as a tool wrapper (verbose)

`docker run --rm -v /path/to/mount/folder/on/host:/path/to/mount/folder/in/container retcon85/toolchain-sms -c 'tool_command_here'`

e.g. if you want to run GNU `make build` in the current working directory, you might run:

`docker run --rm -v $(pwd):/home/sms-tk/host -w /home/sms-tk/host retcon85/toolchain-sms -c 'make build'`

## Running as an interactive shell (not recommended)

`docker run --rm -it retcon85/toolchain-sms`

This will run the docker image interactively to the bash shell. You can run any of the tools from there directly.

If you want access to files (likely), you will need to mount a volume, i.e.

`docker run --rm -it -v /path/to/mount/folder/on/host:/path/to/mount/folder/in/container retcon85/toolchain-sms`

We don't recommend running the image as an interactive shell, because it can get confusing, and also your shell won't have access to resources on your host environment in the same way that your host shell does.

# Contents

## Base image

The base image supplies Python 3 as well as many common software development tools and libraries from the base distro.

## WLA-DX assembler

[WLA-DX](https://github.com/vhelin/wla-dx) is "yet Another GB-Z80/Z80/6502/65C02/65CE02/65816/6800/6801/6809/8008/8080/HUC6280/SPC-700/SuperFX Multi Platform Cross Assembler Package"

It is distributed under the [GPL 2.0 or later licence](https://spdx.org/licenses/GPL-2.0-or-later.html).

### Executables

```
/usr/local/bin (included in $PATH):

wla-6502   wla-65ce02  wla-6809  wla-gb       wla-superfx  wlalink
wla-65816  wla-6800    wla-8008  wla-huc6280  wla-z80
wla-65c02  wla-6801    wla-8080  wla-spc700   wlab
```

## DevkitSMS

[DevkitSMS](https://github.com/sverx/devkitSMS) is "a collection of tools and code (with a very presumptuous name) for SEGA Master System / SEGA Game Gear / SEGA SG-1000 / SEGA SC-3000 homebrew development using 'C' language (and the SDCC compiler)."

It is distributed under numerous (mostly permissive) licenses - see [here](https://github.com/sverx/devkitSMS/blob/master/LICENSES.txt) for more details.

## Executables

```
/usr/local/bin (included in $PATH):

assets2banks  ihx2sms    folder2c      makesms
```

## Other resources

```
/usr/local/share/sdcc/include/sms:

PSGlib.h  SMSlib.h

/usr/local/share/sdcc/lib/sms:

PSGlib.rel  SMSlib.lib  crt0_sms.rel  peep-rules.txt
```

## SDCC

SDCC (Small Device C Compiler) is "a retargettable, optimizing Standard C (ANSI C89, ISO C99, ISO C11) compiler suite that targets the Intel MCS51 based microprocessors (8031, 8032, 8051, 8052, etc.), Maxim (formerly Dallas) DS80C390 variants, Freescale (formerly Motorola) HC08 based (hc08, s08), Zilog Z80 based MCUs (Z80, Z180, SM83, Rabbit 2000, 2000A, 3000A, TLCS-90), Padauk (pdk14, pdk15) and STMicroelectronics STM8."

It is distributed under numerous licenses - see [here](https://sdcc.sourceforge.net/) for more details.

SDCC is required by [DevkitSMS](#DevkitSMS).

## Executables

```
/usr/local/bin (included in $PATH):

as2gbmap      sdas6808    sdcdb.el     serialview  sstm8          ucsim_mos6502
assets2banks  sdas8051    sdcdbsrc.el  shc08       stlcs          ucsim_p1516
folder2c      sdasgb      sdcpp        sm6800      sxa            ucsim_pblaze
ihx2sms       sdaspdk13   sdld         sm6809      sz80           ucsim_pdk
makebin       sdaspdk14   sdld6808     sm68hc08    ucsim_51       ucsim_rxk
makesms       sdaspdk15   sdldgb       sm68hc11    ucsim_avr      ucsim_st7
packihx       sdasrab     sdldpdk      smos6502    ucsim_hc08     ucsim_stm8
s51           sdasstm8    sdldstm8     sp1516      ucsim_m6800    ucsim_tlcs
savr          sdastlcs90  sdldz80      spblaze     ucsim_m6809    ucsim_xa
sdar          sdasz80     sdnm         spdk        ucsim_m68hc08  ucsim_z80
sdas390       sdcc        sdobjcopy    srxk        ucsim_m68hc11
sdas6500      sdcdb       sdranlib     sst7        ucsim_mcs6502
```

## Other resources

```
/usr/local/share/sdcc/include/* (except sms folder - see above)
/usr/local/share/sdcc/lib/* (except sms folder - see above)
```
