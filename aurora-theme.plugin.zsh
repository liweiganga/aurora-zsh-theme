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
  # 多行 PROMPT 时 RPROMPT 只会右对齐在最后一行，因此把耗时
  # 作为第一行的一部分，用空格填充推到行尾（宽度按可见字符数计算）
  setopt localoptions extendedglob
  local _left="%B%F{${AURORA_COLOR_FG}}%n%b%F{${AURORA_COLOR_CYAN}}@%m%F{${AURORA_COLOR_FG}}:%B%F{${AURORA_COLOR_GREEN}}[%~]%b"
  local _git=$(_aurora_git_prompt_info)
  typeset -g _AURORA_PROMPT_FIRST="${_left} ${_git}"
  if [[ -n ${AURORA_LAST_DURATION} ]]; then
    local expanded=${(%)_AURORA_PROMPT_FIRST}
    # 去掉 ANSI 转义序列，得到第一行可见宽度
    local plain=${expanded//$'\e'\[[0-9;]#m/}
    local pad=$(( COLUMNS - ${#plain} - ${#AURORA_LAST_DURATION} ))
    (( pad < 1 )) && pad=1
    typeset -g _AURORA_DURATION_PART="${(l:${pad}:: :)}%F{${AURORA_COLOR_CYAN}}${AURORA_LAST_DURATION}%f"
  else
    typeset -g _AURORA_DURATION_PART=""
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
#  耗时由 _aurora_precmd 填充进第一行行尾（多行 PROMPT 下 RPROMPT 只能
#  右对齐到最后一行，故不用 RPROMPT），不依赖任何光标转义
# =============================================================================
setopt prompt_subst
PROMPT='%B%F{${AURORA_COLOR_FG}}%n%b%F{${AURORA_COLOR_CYAN}}@%m%F{${AURORA_COLOR_FG}}:%B%F{${AURORA_COLOR_GREEN}}[%~]%b'
PROMPT+=' $(_aurora_git_prompt_info)${_AURORA_DURATION_PART}'
PROMPT+='
%F{${AURORA_COLOR_FG}}> %f'

# =============================================================================
#  卸载清理函数
# =============================================================================
_aurora_unload() {
  add-zsh-hook -d preexec _aurora_preexec
  add-zsh-hook -d precmd _aurora_precmd
  unset PROMPT RPROMPT
  unsetopt prompt_subst
  unset AURORA_LAST_DURATION _AURORA_CMD_START
  unset _AURORA_PROMPT_FIRST _AURORA_DURATION_PART
  unset AURORA_COLOR_FG AURORA_COLOR_CYAN AURORA_COLOR_GREEN AURORA_COLOR_PURPLE
  unset AURORA_COLOR_RED AURORA_COLOR_YELLOW
  unset AURORA_GIT_PROMPT_PREFIX AURORA_GIT_PROMPT_SUFFIX
  unset AURORA_GIT_PROMPT_DIRTY AURORA_GIT_PROMPT_CLEAN
  unset _AURORA_THEME_LOADED
  unfunction _aurora_preexec _aurora_precmd _aurora_git_prompt_info 2>/dev/null
  print -P "%F{yellow}Aurora theme unloaded.%f"
}
