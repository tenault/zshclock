[//]: # (                         dP                dP                   dP              )
[//]: # (                         88                88                   88              )
[//]: # (       d888888b .d8888b. 88d888b. .d8888b. 88 .d8888b. .d8888b. 88  .dP         )
[//]: # (          .d8P' Y8ooooo. 88'  `88 88'  `"" 88 88'  `88 88'  `"" 88888"          )
[//]: # (        .Y8P          88 88    88 88.  ... 88 88.  .88 88.  ... 88  `8b.        )
[//]: # (       d888888P `88888P' dP    dP `88888P' dP `88888P' `88888P' dP   `YP        )

[//]: # (                   copyright © 2025 Malakai Smith [[tenault]]                   )
[//]: # (                   originally forked from octobanana/peaclock                   )

[//]: # ( You discovered a secret! But, why are you looking at the README's source code? )

<img width="1284" height="244" alt="zshclock banner" src="https://github.com/user-attachments/assets/cc595c14-9f42-4f41-83ab-aacec4daed6d" />

> [!WARNING]
> _zshclock is in active development! Functionality is limited, and features may appear and disappear without warning._
> _Please wait patiently for the 1.0 release, or until the banner color switches from orange to purple._
>
> <sub>Curious eyeball-havers are encouraged to checkout the [`evolution`](https://github.com/tenault/zshclock/tree/evolution) branch and corresponding [project board](https://github.com/users/tenault/projects/3) to track current development.</sub>

<img width="1018" height="595" alt="screenshot" src="https://github.com/user-attachments/assets/7c650712-aec6-4602-aa60-22e2c04250d5" />

<details open>
<summary>Table of Contents</summary>

- [About](#about)
- [Installation](#installation)
- [Usage](#usage)
- [Contributing](#contributing-)
- [Acknowledgements](#acknowledgements)

</details>

## About

> [!NOTE]
> _Not all features and capabilities described here are currently implemented. Check the [wiki](https://github.com/tenault/zshclock/wiki) and/or [usage](https://github.com/tenault/zshclock/wiki/Usage) for details._

zshclock is a responsive and highly customizable timepiece for the terminal, written entirely in native zsh.

It boasts a multitude of features, from dazzling styles, layouts, and colors, to various modes and alternate behaviors.
Built from the ground up with customization in mind, every part of the clock can be tweaked and tailored for the ultimate experience in chronographic adoration.
Plus, it even tells the time.

Symbol | Meaning
:---: | :---
:white_check_mark: | Fully implemented
:white_circle: | Partially implemented
:o: | In progress
:x: | Not yet implemented

|| Features |
--- | :---
:white_check_mark: | Tells the time.
:white_check_mark: | Customizable date line.
:white_check_mark: | Built-in command bar for runtime customization.
:white_circle: | Navigate command bar history.
:o: | Clock, timer, stopwatch, and alarm modes.
:o: | Auto-size the clock based on window size, optionally preserving aspect ratio.
:o: | Customizable clock format (seconds on/off, 24-hour time, etc).
:o: | Shortcuts for rapid personalization.
:x: | Ascii, binary, digital, and analog clock faces.
:x: | Execute a shell command on alarm/timer completion.
:x: | Load settings from a config file.
:x: | Fuzzy search command bar history.
:x: | Excessive color options.

## Installation

| Requirements |
| --- |
| [zsh](https://www.zsh.org/) _(obviously)_ |

### Step 1: Get zshclock

If you have git installed, simply open your favorite terminal and run:
```zsh
git clone https://github.com/tenault/zshclock.git
```
<sup>_Alternatively, [download](https://github.com/tenault/zshclock/releases/tag/v0.2) the latest release._</sup>

### Step 2: Activate zshclock

<ins>_Method 1_ — Custom Function</ins>

Run the following to link the `ztc` command to zshclock in your `~/.zshrc`:
```zsh
echo "ztc() { ~/zshclock/zshclock.zsh }" >> ~/.zshrc
```
> [!TIP]
> If you saved zshclock somewhere else, make sure to change the path inside `{ ... }` accordingly.

:tada: That's it! :tada: zshclock is now fully installed. Restart your terminal to give it a try.

<sup>To uninstall, simply delete the zshclock folder and remove the `ztc()` line from `~/.zshrc`</sup>

<details>
<summary><ins><i>Method 2</i> — Local Binary</ins></summary>

Alternatively, the following set of commands will create a local bin folder and add zshclock to it:
```zsh
mkdir -p ~/.local/bin                          # Creates a local bin folder if one doesn't already exist
cp ~/zshclock/zshclock.zsh ~/.local/bin/ztc    # Copies zshclock into the local bin
echo "path+=~/.local/bin" >> ~/.zshrc          # Adds the local bin to the system PATH

rm -r ~/zshclock                               # Optional, removes the source folder
```

:tada: zshclock is now fully installed! :tada: Restart your terminal to give it a try.

<sub>To uninstall, simply delete the `ztc` program from `~/.local/bin`:</sub>
```zsh
rm ~/.local/bin/ztc
```
<sup>To remove the local bin folder entirely, delete `~/.local/bin` and remove the `path+=...` line in `~/.zshrc`</sup>

</details>

## Usage

- To start the clock, run `ztc`
- To stop the clock, type `q`

Yup. It's that simple.
zshclock will take a few seconds to compile the first time you run it, but every run after that will be lightning-fast.

At any point while zshclock is running, you can type `:` or press `<enter>` to open the command bar, which lets you customize different parts of the clock.
Currently, only one command is implemented:

```
Usage: date <format>

Arguments:
    format    A string containing strftime-compatible expansions
```

The `date` command lets you change the text under the clock to anything you want. Run the following to see it in action:
```zsh
date %a @b%b %d@r %p
```
<sup>_The symbols `@b` and `@r` in the above example are a special type of expansion unique to zshclock, called [flares](https://github.com/tenault/zshclock/wiki/Flaring)_</sup> \
<sup>_For a complete list of available expansions, refer to the wiki on [date formatting](https://github.com/tenault/zshclock/wiki/Date-Formatting)_</sup>

For a complete guide on using zshclock, including a list of available commands, refer to the wiki on [usage](https://github.com/tenault/zshclock/wiki/Usage)

## Contributing ♥

zshclock welcomes any and all contributions, so long as they adhere to the guidelines set forth in [Contributing](.github/CONTRIBUTING.md).
Contributors are highly encouraged to glance over them before submitting their first contribution.

Additionally, zshclock is governed by the [Code of Bill and Ted](.github/CODE_OF_CONDUCT.md), and as such, all contributors are expected to follow its rules without exception.

## Acknowledgements

zshclock is proudly forked from  [octobanana/peaclock](https://github.com/octobanana/peaclock) ♥

