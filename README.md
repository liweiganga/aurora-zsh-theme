# Aurora Zsh Theme

A minimal Zsh theme using the **[Dracula](https://github.com/dracula/dracula-theme)** color palette (true-color `#rrggbb`).

![Dracula](https://img.shields.io/badge/theme-Dracula-282a36) ![purple](https://img.shields.io/badge/purple-bd93f9) ![pink](https://img.shields.io/badge/pink-ff79c6) ![green](https://img.shields.io/badge/green-50fa7b)

## Features

- **Minimal prompt** — first line: username@host, path, and git status; second line: `>` prompt
- **Git status** — branch name with dirty indicator, fully self-contained (no Oh My Zsh dependency)
- **Single file** — one `.plugin.zsh` entry point, no external dependencies

## Color Palette

| Element | Color |
|---------|-------|
| Username / `>` prompt | Foreground `#f8f8f2` |
| `@` separator | Cyan `#8be9fd` |
| Path `[~]` | Green `#50fa7b` |
| `git:( )` frame | Purple `#bd93f9` |
| Git branch | Red `#ff5555` |
| Dirty indicator `✗` | Yellow `#f1fa8c` |

All colors are defined as `AURORA_COLOR_*` variables at the top of the plugin, so you can override them after loading the theme.

## Installation

### 方式一：使用 [zi](https://github.com/z-shell/zi) 插件管理器（推荐）

**1. 基本安装**

```zsh
# 在 ~/.zshrc 中添加（zi 已初始化的前提下）
zi light liweiganga/aurora-zsh-theme
```

**2. 可选：Turbo 延迟加载模式**（与上面的基本安装二选一，不要叠加）

```zsh
zi ice wait lucid
zi light liweiganga/aurora-zsh-theme
```

> 说明：`zi ice` 只对紧随其后的那条命令生效，互不影响；`wait` 表示等 .zshrc 处理完、首个提示符出现后再加载，`lucid` 表示跳过加载提示信息。

**更新主题：**

```zsh
zi update --all
```

### 方式二：手动安装

```zsh
# 1. 克隆仓库到任意目录（例如 ~/liweigang）
git clone https://github.com/liweiganga/aurora-zsh-theme.git

# 2. 在 ~/.zshrc 中添加
source ~/liweigang/aurora-zsh-theme/aurora-theme.plugin.zsh
```

手动安装时更新主题：

```zsh
cd ~/liweigang/aurora-zsh-theme && git pull
```

两种方式安装后，执行 `exec zsh` 或 `source ~/.zshrc` 生效。

## Screenshot

```
max@arch:[~/projects/aurora] git:(main) ✗
>
```

- First line: `user@host:[path] git:(branch) ✗`
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
