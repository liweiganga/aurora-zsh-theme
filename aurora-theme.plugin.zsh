#!/usr/bin/env zsh
# =============================================================================
#  Aurora — A minimal Zsh theme with command timing and Git status
#  First line: user@host:[path] git status          (right: last-command duration)
#  Second line: "+= " prompt
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
#  命令计时（整数秒，避免 EPOCHREALTIME 浮点余数导致 1m05.3s 之类的输出）
# =============================================================================
zmodload zsh/datetime
typeset -g AURORA_LAST_DURATION=""
typeset -g _AURORA_CMD_START=""
_aurora_preexec() {
  _AURORA_CMD_START=${EPOCHREALTIME:-$EPOCHSECONDS}
}
_aurora_precmd() {
  if [[ -n ${_AURORA_CMD_START} ]]; then
    local now=${EPOCHREALTIME:-$EPOCHSECONDS}
    local elapsed=$(( now - _AURORA_CMD_START ))
    elapsed=${elapsed%.*}   # 取整秒
    _AURORA_CMD_START=""
    if (( elapsed < 1 )); then
      AURORA_LAST_DURATION=""
    elif (( elapsed < 60 )); then
      AURORA_LAST_DURATION="${elapsed}s"
    else
      AURORA_LAST_DURATION="$((elapsed/60))m$((elapsed%60))s"
    fi
  fi
  # 每次提示符刷新前重算 RPROMPT（有空值/非空两种状态）
  if [[ -n ${AURORA_LAST_DURATION} ]]; then
    RPROMPT="%F{${AURORA_COLOR_CYAN}}${AURORA_LAST_DURATION}%f"
  else
    RPROMPT=""
  fi
}
autoload -Uz add-zsh-hook
add-zsh-hook preexec _aurora_preexec
add-zsh-hook precmd _aurora_precmd

# =============================================================================
#  Git 状态显示（自包含，不依赖 Oh My Zsh）
# =============================================================================
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
#  提示符 — 用 prompt_subst 让 zsh 在显示时统一展开所有 % 转义
#  RPROMPT 由 _aurora_precmd 按 AURORA_LAST_DURATION 动态生成，
#  zsh/zle 自动按终端宽度把它右对齐在第一行，不依赖任何空格填充或光标转义
# =============================================================================
setopt prompt_subst
PROMPT='%B%F{${AURORA_COLOR_FG}}%n%b%F{${AURORA_COLOR_CYAN}}@%m%F{${AURORA_COLOR_FG}}:%B%F{${AURORA_COLOR_GREEN}}[%~]%b'
PROMPT+=' $(_aurora_git_prompt_info)'
PROMPT+='
%F{${AURORA_COLOR_FG}}> %f'

# =============================================================================
#  ls 颜色（Dracula 配色，仅对 GNU ls 生效；设 AURORA_NO_LS_COLORS=1 可关闭）
# =============================================================================
if [[ -z ${AURORA_NO_LS_COLORS:-} ]] && command ls --color=auto >/dev/null 2>&1; then
  alias ls='ls --color=auto'
  # 117=cyan 120=green 141=purple 203=red 228=yellow 212=pink（256 色近似 Dracula）
  export LS_COLORS="di=1;38;5;141:fi=0;38;5;250:ln=38;5;212:or=38;5;203:ex=1;38;5;120:*.tar=38;5;228:*.gz=38;5;228:*.zip=38;5;228:*.xz=38;5;228:*.jpg=38;5;117:*.png=38;5;117"
fi

# =============================================================================
#  卸载清理函数
# =============================================================================
_aurora_unload() {
  add-zsh-hook -d preexec _aurora_preexec
  add-zsh-hook -d precmd _aurora_precmd
  unset PROMPT RPROMPT
  unsetopt prompt_subst
  unset AURORA_LAST_DURATION _AURORA_CMD_START
  unset AURORA_COLOR_FG AURORA_COLOR_CYAN AURORA_COLOR_GREEN AURORA_COLOR_PURPLE
  unset AURORA_COLOR_RED AURORA_COLOR_YELLOW
  unset AURORA_GIT_PROMPT_PREFIX AURORA_GIT_PROMPT_SUFFIX
  unset AURORA_GIT_PROMPT_DIRTY AURORA_GIT_PROMPT_CLEAN
  unset _AURORA_THEME_LOADED
  unfunction _aurora_preexec _aurora_precmd _aurora_git_prompt_info 2>/dev/null
  print -P "%F{yellow}Aurora theme unloaded.%f"
}
