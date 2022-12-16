# Good Morning!

Good Morning is an addon for Windower4 that performs an action (or actions) after coming back from idle after a certain amount of time.

## Usage

The default state will display ls and ls2 MOTD's.

## Installation

1. Copy the files into your addons directory, usually in `C:\Program Files (x86)\Windower4\addons\`
2. Launch Windower 4
3. Execute `//lua l goodmorning` to start the addon, or add it to your `init.txt` file in your scripts to load it at startup.

## Commands

* Usage:  `//morning [command] [subcommand] [argument]`

| Command | Subcommand | Description |
| --- | --- | --- |
| set | [timeout/delay] | The amount of time in hours, or the amount of time between actions firing. |
| add, a, + | a windower command to execute | for example, `//morning add "input /servmes"` |
| del, d, - | an index | Removes the command at that index |
| test | nil | tests as though you were AFK for timeout+1second |

## Version

**Author:** rjt

**Version:** 1.0

**Date:** 15/12/2022
