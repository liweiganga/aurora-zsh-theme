# Aurora Zsh Theme

A minimal Zsh theme inspired by the **Aurora** (Northern Lights) color palette: **cyan + green + magenta**.

![Aurora color palette](https://img.shields.io/badge/cyan-cyan) ![green-green](https://img.shields.io/badge/green-green) ![magenta-magenta](https://img.shields.io/badge/magenta-magenta)

## Features

- **Minimal prompt** — username@host, path, and git status on the left; `>` on the next line
- **Command timing** — shows elapsed time of the last command on the right (auto-hidden for <0.1s)
- **Git status** — branch name with dirty indicator, fully self-contained (no Oh My Zsh dependency)
- **Single file** — one `.plugin.zsh` entry point, no external dependencies

## Color Palette

| Element | Color |
|---------|-------|
| Username / `>` prompt | White |
| `@` separator | Cyan |
| Path `[~]` | Green |
| Command duration (right) | Magenta |
| Git branch | Blue / Red |

## Installation

### With [zi](https://github.com/z-shell/zi) (recommended)

```zsh
# In ~/.zshrc
source "$HOME/.zi/bin/zi.zsh"

zi light <your-username>/aurora-zsh-theme

# Optional: Turbo mode for faster startup
zi ice wait lucid
zi light <your-username>/aurora-zsh-theme
```

### Manual

```zsh
# In ~/.zshrc
source /path/to/aurora-theme.plugin.zsh
```

## Screenshot

```
aa@aa:[~/projects/aurora] git:(master) ✗
>                          3.2s
```

- Left: `user@host:[path] git:(branch) ✗` then `>` on next line
- Right: command duration in magenta

## Compatibility

- **Oh My Zsh**: If `git_prompt_info` is already defined (e.g., by OMZ), Aurora will use it. Otherwise the built-in implementation is used.
- **No framework required**: Works standalone with just Zsh.

## Uninstall

```zsh
_aurora_unload   # clean up hooks and variables
```

## License

MIT
