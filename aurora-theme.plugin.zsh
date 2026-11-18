#!/usr/bin/env zsh
# =============================================================================
#  Aurora — A minimal Zsh theme with command timing and Git status
#  Color palette: cyan + green + magenta (Aurora-like)
#  Designed for zi (Z-Shell Plugin Manager), fully self-contained.
# =============================================================================
# --- 防重复加载 ---
if [[ -n "${_AURORA_THEME_LOADED:-}" ]]; then
  return 0
fi
typeset -g _AURORA_THEME_LOADED=1
# =============================================================================
#  左侧提示符 (PROMPT)
# =============================================================================
PROMPT='%B%F{white}%n%b%F{cyan}@%m%F{white}:%B%F{green}[%~]%b'
PROMPT+=' $(_aurora_git_prompt_info)'
PROMPT+='
%F{white}> %f'
# =============================================================================
#  右侧提示符 (RPROMPT): 显示上一条命令的执行耗时
# =============================================================================
ZLE_RPROMPT_INDENT=0   # 去掉 zsh 默认预留的右侧空隙
RPROMPT=$'%{\e[1A%}%F{magenta}${AURORA_LAST_DURATION}%{\e[1B%}'
# =============================================================================
#  命令计时
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
    _AURORA_CMD_START=""
    if (( elapsed < 0.1 )); then
      AURORA_LAST_DURATION=""                                # 瞬时命令不显示
    elif (( elapsed < 60 )); then
      AURORA_LAST_DURATION=$(printf '%.1fs' $elapsed)        # 如 3.2s
    else
      AURORA_LAST_DURATION=$(printf '%dm%02ds' $((elapsed/60)) $((elapsed%60)))  # 如 1m05s
    fi
  fi
}
autoload -Uz add-zsh-hook
add-zsh-hook preexec _aurora_preexec
add-zsh-hook precmd _aurora_precmd
# =============================================================================
#  Git 状态显示（自包含，不依赖 Oh My Zsh）
# =============================================================================
# Git 样式设置
typeset -g AURORA_GIT_PROMPT_PREFIX="%{$fg_bold[blue]%}git:(%{$fg[red]%}"
typeset -g AURORA_GIT_PROMPT_SUFFIX="%{$reset_color%} "
typeset -g AURORA_GIT_PROMPT_DIRTY="%{$fg[blue]%}) %{$fg[yellow]%}✗"
typeset -g AURORA_GIT_PROMPT_CLEAN="%{$fg[blue]%})"
# 兼容性：如果 Oh My Zsh 的 git_prompt_info 存在，优先使用它
_aurora_git_prompt_info() {
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
  printf '%s%s%s' "${AURORA_GIT_PROMPT_PREFIX}" "${branch}" "${dirty}"
}
# =============================================================================
#  卸载清理函数
# =============================================================================
_aurora_unload() {
  add-zsh-hook -d preexec _aurora_preexec
  add-zsh-hook -d precmd _aurora_precmd
  unset PROMPT RPROMPT
  unset AURORA_LAST_DURATION _AURORA_CMD_START
  unset AURORA_GIT_PROMPT_PREFIX AURORA_GIT_PROMPT_SUFFIX
  unset AURORA_GIT_PROMPT_DIRTY AURORA_GIT_PROMPT_CLEAN
  unset _AURORA_THEME_LOADED
  unfunction _aurora_preexec _aurora_precmd _aurora_git_prompt_info 2>/dev/null
  print -P "%F{yellow}Aurora theme unloaded.%f"
}
