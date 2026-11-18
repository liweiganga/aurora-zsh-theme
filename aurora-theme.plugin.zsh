#!/usr/bin/env zsh
# =============================================================================
#  Aurora — A minimal Zsh theme with command timing and Git status
#  First line: user@host:[path] git status
#  Second line: "> " prompt
#  Color palette: Dracula (https://github.com/dracula/dracula-theme)
#  Designed for zi (Z-Shell Plugin Manager), fully self-contained.
# =============================================================================
# --- 防重复加载 ---
if [[ -n "${_AURORA_THEME_LOADED:-}" ]]; then
  return 0
fi
typeset -g _AURORA_THEME_LOADED=1



# =============================================================================
#  Dracula 调色板（zsh 支持 %F{#rrggbb}，256/真彩色终端均可）
# =============================================================================
typeset -g AURORA_COLOR_FG="#f8f8f2"        # foreground  用户名/提示符
typeset -g AURORA_COLOR_CYAN="#8be9fd"      # cyan        @/耗时
typeset -g AURORA_COLOR_GREEN="#50fa7b"     # green       路径
typeset -g AURORA_COLOR_PURPLE="#bd93f9"    # purple      git:
typeset -g AURORA_COLOR_RED="#ff5555"       # red         分支名
typeset -g AURORA_COLOR_YELLOW="#f1fa8c"    # yellow      ✗ 脏工作区

# =============================================================================
#  提示符：第一行显示 user@host:[路径] git 信息，耗时跟在行尾
#  第二行是输入提示符 "> "
# =============================================================================
typeset -g _AURORA_PROMPT_LEFT="%B%F{${AURORA_COLOR_FG}}%n%b%F{${AURORA_COLOR_CYAN}}@%m%F{${AURORA_COLOR_FG}}:%B%F{${AURORA_COLOR_GREEN}}[%~]%b"
typeset -g _AURORA_PROMPT_CONT=$'\n'"%F{${AURORA_COLOR_FG}}> %f"   # 真实换行符，不依赖 print -P 的转义解释
_aurora_precmd() {
  # ---- 第一行 + 第二行 ----
  local first_exp git_info
  git_info=$(_aurora_git_prompt_info)
  first_exp=$(print -P -- "${_AURORA_PROMPT_LEFT}${git_info:+ }${git_info}%f")
  local cont_exp
  cont_exp=$(print -P -- "${_AURORA_PROMPT_CONT}")
  local final="${first_exp}${cont_exp}"
  PROMPT=${final//\%/\%\%}
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd _aurora_precmd

# =============================================================================
#  Git 状态显示（自包含，不依赖 Oh My Zsh）
# =============================================================================
# Git 样式设置（使用 zsh 内建 prompt 转义，不依赖 OMZ 的 $fg 数组）
typeset -g AURORA_GIT_PROMPT_PREFIX="%B%F{${AURORA_COLOR_PURPLE}}git:(%F{${AURORA_COLOR_RED}}"
typeset -g AURORA_GIT_PROMPT_SUFFIX="%f%b "
typeset -g AURORA_GIT_PROMPT_DIRTY="%F{${AURORA_COLOR_PURPLE}}) %F{${AURORA_COLOR_YELLOW}}✗%f"
typeset -g AURORA_GIT_PROMPT_CLEAN="%F{${AURORA_COLOR_PURPLE}})%f"

_aurora_git_prompt_info() {
  # 兼容性：如果 Oh My Zsh 的 git_prompt_info 存在，优先使用它
  if (( ${+functions[git_prompt_info]} )); then
    git_prompt_info
    return
  fi
  # 自包含实现
  local branch
  branch=$(command git symbolic-ref --short HEAD 2>/dev/null) \
    || branch=$(command git rev-parse --short HEAD 2>/dev/null) \
    || return
  local dirty=""
  if [[ -n $(command git status --porcelain 2>/dev/null) ]]; then
    dirty="${AURORA_GIT_PROMPT_DIRTY}"
  else
    dirty="${AURORA_GIT_PROMPT_CLEAN}"
  fi
  print -n -- "${AURORA_GIT_PROMPT_PREFIX}${branch}${dirty}${AURORA_GIT_PROMPT_SUFFIX}"
}

# =============================================================================
#  卸载清理函数
# =============================================================================
_aurora_unload() {
  add-zsh-hook -d precmd _aurora_precmd
  unset PROMPT
  unsetopt PROMPT_SUBST
  unset _AURORA_PROMPT_LEFT _AURORA_PROMPT_CONT
  unset AURORA_COLOR_FG AURORA_COLOR_CYAN AURORA_COLOR_GREEN AURORA_COLOR_PURPLE
  unset AURORA_COLOR_RED AURORA_COLOR_YELLOW
  unset AURORA_GIT_PROMPT_PREFIX AURORA_GIT_PROMPT_SUFFIX
  unset AURORA_GIT_PROMPT_DIRTY AURORA_GIT_PROMPT_CLEAN
  unset _AURORA_THEME_LOADED
  unfunction _aurora_precmd _aurora_git_prompt_info 2>/dev/null
  print -P "%F{yellow}Aurora theme unloaded.%f"
}
