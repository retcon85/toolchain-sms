# Overview

The `toolchain-sms` Docker image provides a common set of tools for game development for the Sega Master System.

It has been created as part of the [Retcon85](https://github.com/retcon85) project.

# Source

https://github.com/retcon85/toolchain-sms

# Usage

## As a Visual Studio Code devcontainer (recommended)

This image works great as a Visual Studio Code devcontainer. If you've never used a devcontainer before, you're in for a treat! Devcontainers let you run Visual Studio Code in a container isolated mode where all terminals by default will run inside a Docker container.

For an example of how to set this up, please refer to the `.devcontainer` project inside the [quickstart-sms-devkitsms repo](https://github.com/retcon85/quickstart-sms-devkitsms/tree/main/.devcontainer).

## Pulling the image directly

`docker pull retcon85/toolchain-sms`

## Running directly as a tool wrapper

`docker run --rm -v /path/to/mount/folder/on/host:/path/to/mount/folder/in/container retcon85/toolchain-sms 'tool_command_here'`

e.g. if you want to run GNU `make build` in the current working directory, you might run:

`docker run --rm -v $(pwd):/home/sms-tk/host -w /home/sms-tk/host retcon85/toolchain-sms 'make build'`

## Using a shell alias / function

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


## Running as an interactive shell

`docker run --rm -it retcon85/toolchain-sms /bin/bash`

This will run the docker image interactively to the bash shell. You can run any of the tools from there directly.

If you want access to files (likely), you will need to mount a volume, i.e.

`docker run --rm -it -v /path/to/mount/folder/on/host:/path/to/mount/folder/in/container retcon85/toolchain-sms /bin/bash`

We don't recommend running the image as an interactive shell, because it can get confusing, and also your shell won't have access to resources on your host environment in the same way that your host shell does.

# Building the image from source

Run `./build.sh`

# Contents

## Base image

The base image supplies Python 3 as well as many common software development tools and libraries from the base distro.

## WLA-DX assembler

[WLA-DX](https://github.com/vhelin/wla-dx) is "yet Another GB-Z80/Z80/6502/65C02/65CE02/65816/6800/6801/6809/8008/8080/HUC6280/SPC-700/SuperFX Multi Platform Cross Assembler Package"

It is distributed under the [GPL 2.0 or later licence](https://spdx.org/licenses/GPL-2.0-or-later.html).

**You can switch between versions of WLA-DX by running the `use-wla-dx` command.**

### Executables (dependent on active version)

```
/opt/wla-dx/bin (included in $PATH):

wla-6502   wla-65c02   wla-6800   wla-6801  wla-8008  wla-gb       wla-spc700   wla-z80   wlab
wla-65816  wla-65ce02  wla-68000  wla-6809  wla-8080  wla-huc6280  wla-superfx  wla-z80n  wlalink
```

## DevkitSMS

[DevkitSMS](https://github.com/sverx/devkitSMS) is "a collection of tools and code (with a very presumptuous name) for SEGA Master System / SEGA Game Gear / SEGA SG-1000 / SEGA SC-3000 homebrew development using 'C' language (and the SDCC compiler)."

It is distributed under numerous (mostly permissive) licenses - see [here](https://github.com/sverx/devkitSMS/blob/master/LICENSES.txt) for more details.

### Executables (dependent on active version)

```
/opt/devkitsms/bin (included in $PATH):

assets2banks  folder2c  ihx2sms  makesms
```

### Other resources

```
/opt/devkitsms/include:

PSGlib.h  SMSlib.h

/opt/devkitsms/lib:

PSGlib.lib  SMSlib.lib  SMSlib_GG.lib  crt0_sms.rel  peep-rules.txt
```

## SDCC

SDCC (Small Device C Compiler) is "a retargettable, optimizing Standard C (ANSI C89, ISO C99, ISO C11) compiler suite that targets the Intel MCS51 based microprocessors (8031, 8032, 8051, 8052, etc.), Maxim (formerly Dallas) DS80C390 variants, Freescale (formerly Motorola) HC08 based (hc08, s08), Zilog Z80 based MCUs (Z80, Z180, SM83, Rabbit 2000, 2000A, 3000A, TLCS-90), Padauk (pdk14, pdk15) and STMicroelectronics STM8."

It is distributed under numerous licenses - see [here](https://sdcc.sourceforge.net/) for more details.

SDCC is required by [DevkitSMS](#DevkitSMS).

**You can switch between versions of SDCC by running the `use-sdcc` command.**

### Executables (dependent on active version)

```
/opt/sdcc/bin (included in $PATH):

as2gbmap  sdar      sdas8051   sdaspdk15   sdasz80   sdcdbsrc.el  sdldgb    sdnm        ucsim_51     ucsim_m6800    ucsim_m68hc12  ucsim_pdk   ucsim_tlcs
makebin   sdas390   sdasgb     sdasrab     sdcc      sdcpp        sdldpdk   sdobjcopy   ucsim_avr    ucsim_m6809    ucsim_mos6502  ucsim_rxk   ucsim_xa
packihx   sdas6500  sdaspdk13  sdasstm8    sdcdb     sdld         sdldstm8  sdranlib    ucsim_f8     ucsim_m68hc08  ucsim_p1516    ucsim_st7   ucsim_z80
s51       sdas6808  sdaspdk14  sdastlcs90  sdcdb.el  sdld6808     sdldz80   serialview  ucsim_i8085  ucsim_m68hc11  ucsim_pblaze   ucsim_stm8
```

### Other resources

```
/opt/sdcc/share/sdcc/include/*
/opt/sdcc/share/sdcc/lib/*
```

## Version switching

Some tools have multiple versions installed.

- You can switch between versions of WLA-DX by running the `use-wla-dx` command.
- You can switch between versions of SDCC by running the `use-sdcc` command.

Version switching is achieved through symlinks.

## Variants

There is a "slim" variant of the image, which is slightly smaller in terms of image size and should work for most if not all projects. We recommend using the slim variant unless you find that it doesn't support your needs.

# Changelog

## v1.0

- **Added `-c` to entrypoint**
- **Changed image user from `retcon` to `root`**
- **Upgrade to Python 3.13 from 3.11**
- Standardize on `bookworm` base image
- Install `gcc` on base image
- Moved WLA-DX location from `/usr/local/...` to `/opt/wla-dx/...`
- Added multiple versions of WLA-DX (10.5 and 10.6)
- Moved SDCC location from `/usr/local/...` to `/opt/sdcc/...`
- Added multiple versions of SDCC (4.3, 4.4 and 4.5)
- Moved devkitsms location from `/usr/local/...` to `/opt/devkitsms/...`
- Latest devkitsms snapshot (`1d65541a11800aa688d8649c4a393282717e2e5f`)
