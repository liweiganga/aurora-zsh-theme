#!/usr/bin/env zsh
# =============================================================================
#  Aurora — A minimal Zsh theme with command timing and Git status
#  First line: user@host:[path] git status + last-command duration (right-aligned)
#  Second line: "> " prompt
#  Color palette: cyan + green + magenta (Aurora-like)
#  Designed for zi (Z-Shell Plugin Manager), fully self-contained.
# =============================================================================
# --- 防重复加载 ---
if [[ -n "${_AURORA_THEME_LOADED:-}" ]]; then
  return 0
fi
typeset -g _AURORA_THEME_LOADED=1



# =============================================================================
#  提示符：第一行显示 user@host:[路径] git 信息，耗时右对齐在同一行末尾
#  第二行是输入提示符 "> "
# =============================================================================
typeset -g _AURORA_PROMPT_LEFT='%B%F{white}%n%b%F{cyan}@%m%F{white}:%B%F{green}[%~]%b'
typeset -g _AURORA_PROMPT_CONT='\n%F{white}> %f'
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
  # ---- 把耗时右对齐拼到第一行末尾 ----
  local first_exp git_info
  git_info=$(_aurora_git_prompt_info)
  first_exp=$(print -P -- "${_AURORA_PROMPT_LEFT} ${git_info}%f")
  # 去掉 ANSI 转义序列后按显示宽度计数（${(m)#}）
  local plain=${first_exp//$'\e'\[[0-9;]*m/}
  local left_width=${(m)#plain}

  local duration=${AURORA_LAST_DURATION}
  local padded=""
  if [[ -n ${duration} ]]; then
    local dur_width=${(m)#duration}
    local pad=$(( COLUMNS - left_width - dur_width ))
    (( pad < 1 )) && pad=1
    padded=${(l.${pad}.)duration}
  fi

  # 拼接最终 PROMPT；把已有 % 加倍，避免路径中的 % 被当作转义
  local cont_exp
  cont_exp=$(print -P -- "${_AURORA_PROMPT_CONT}")
  local final="${first_exp}${padded}${cont_exp}"
  PROMPT=${final//\%/\%\%}
}

autoload -Uz add-zsh-hook
add-zsh-hook preexec _aurora_preexec
add-zsh-hook precmd _aurora_precmd

# =============================================================================
#  Git 状态显示（自包含，不依赖 Oh My Zsh）
# =============================================================================
# Git 样式设置（使用 zsh 内建 prompt 转义，不依赖 OMZ 的 $fg 数组）
typeset -g AURORA_GIT_PROMPT_PREFIX="%B%F{blue}git:(%F{red}"
typeset -g AURORA_GIT_PROMPT_SUFFIX="%f%b "
typeset -g AURORA_GIT_PROMPT_DIRTY="%F{blue}) %F{yellow}✗%f"
typeset -g AURORA_GIT_PROMPT_CLEAN="%F{blue})%f"

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
  add-zsh-hook -d preexec _aurora_preexec
  add-zsh-hook -d precmd _aurora_precmd
  unset PROMPT
  unsetopt PROMPT_SUBST
  unset _AURORA_PROMPT_LEFT _AURORA_PROMPT_CONT
  unset AURORA_LAST_DURATION _AURORA_CMD_START
  unset AURORA_GIT_PROMPT_PREFIX AURORA_GIT_PROMPT_SUFFIX
  unset AURORA_GIT_PROMPT_DIRTY AURORA_GIT_PROMPT_CLEAN
  unset _AURORA_THEME_LOADED
  unfunction _aurora_preexec _aurora_precmd _aurora_git_prompt_info 2>/dev/null
  print -P "%F{yellow}Aurora theme unloaded.%f"
}
