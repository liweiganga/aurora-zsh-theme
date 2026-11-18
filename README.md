# Aurora Zsh Theme

A minimal Zsh theme using the **[Dracula](https://github.com/dracula/dracula-theme)** color palette (true-color `#rrggbb`).

![Dracula](https://img.shields.io/badge/theme-Dracula-282a36) ![purple](https://img.shields.io/badge/purple-bd93f9) ![pink](https://img.shields.io/badge/pink-ff79c6) ![green](https://img.shields.io/badge/green-50fa7b)

## Features

- **Minimal prompt** — first line: username@host, path, and git status, with the last command duration right-aligned; second line: `>` prompt
- **Command timing** — elapsed time of the last command, right-aligned on the first line (auto-hidden for <0.1s)
- **Git status** — branch name with dirty indicator, fully self-contained (no Oh My Zsh dependency)
- **Single file** — one `.plugin.zsh` entry point, no external dependencies

## Color Palette

| Element | Color |
|---------|-------|
| Username / `>` prompt | Foreground `#f8f8f2` |
| `@` separator / duration | Cyan `#8be9fd` |
| Path `[~]` | Green `#50fa7b` |
| `git:( )` frame | Purple `#bd93f9` |
| Git branch | Red `#ff5555` |
| Dirty indicator `✗` | Yellow `#f1fa8c` |

All colors are defined as `AURORA_COLOR_*` variables at the top of the plugin, so you can override them after loading the theme.

## Installation

### With [zi](https://github.com/z-shell/zi) (recommended)

```zsh
# In ~/.zshrc
source "$HOME/.zi/bin/zi.zsh"

zi light liweiganga/aurora-zsh-theme

zi ice wait lucid  # Optional: Turbo mode for faster startup
zi light liweiganga/aurora-zsh-theme
```

### Manual

```zsh
# In ~/.zshrc
source /path/to/aurora-theme.plugin.zsh
```

## Screenshot

```
aa@aa:[~/projects/aurora] git:(master) ✗                             3.2s
>
```

- First line: `user@host:[path] git:(branch) ✗` with the command duration right-aligned on the same line (magenta)
- Second line: `>` prompt

## Compatibility

- **Oh My Zsh**: If `git_prompt_info` is already defined (e.g., by OMZ), Aurora will use it. Otherwise the built-in implementation is used.
- **No framework required**: Works standalone with just Zsh.

## Uninstall

```zsh
_aurora_unload   # clean up hooks and variables
```

## License

MIT
