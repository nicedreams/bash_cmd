#!/bin/bash
# ╔════════════════════════════════════════════════════════════════════════════╗
# ║ bash_cmd -- Function to store and run commands from file                   ║
# ║ Kenneth Bernier <kbernier@gmail.com>                                       ║
# ║ https://github.com/nicedreams/bash_cmd                                     ║
# ║ -------------------------------------------------------------------------- ║
# ║ Usage:                                                                     ║
# ║   Use as standalone script ~/bin/cmd                                       ║
# ║   or source this file inside your ~/.bashrc                                ║
# ║   Some options like history won't work unless script is sourced.           ║
# ║   Uses 'bash -c' when standalone or 'eval' when sourced.                   ║
# ║   Commands will use your current environment with eval when sourced.       ║
# ║ -------------------------------------------------------------------------- ║
# ║ This program is free software: you can redistribute it and/or modify       ║
# ║ it under the terms of the GNU General Public License as published by       ║
# ║ the Free Software Foundation, either version 3 of the License, or          ║
# ║ (at your option) any later version.                                        ║
# ║                                                                            ║
# ║ This program is distributed in the hope that it will be useful,            ║
# ║ but WITHOUT ANY WARRANTY; without even the implied warranty of             ║
# ║ MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the              ║
# ║ GNU General Public License for more details.                               ║
# ║                                                                            ║
# ║ You should have received a copy of the GNU General Public License          ║
# ║ along with this program.  If not, see <https://www.gnu.org/licenses/>.     ║
# ╚════════════════════════════════════════════════════════════════════════════╝
version="2021-07-25"
#------------------------------------------------------------------------------

# Set CMDLETS_DEFAULT_FILE variable if not already set from environment
if [[ ! "${CMDLETS_DEFAULT_FILE}" ]]; then export CMDLETS_DEFAULT_FILE="${HOME}/.cmdnotes"; fi
# Set CMDLETS variable if not already set from environment
if [[ ! "${CMDLETS_DIR}" ]]; then export CMDLETS_DIR="${HOME}/.cmdlets"; fi

# Help/Usage message
usage() {
  printf "\nbash_cmd - Store and run commands from file:\n\n"
  printf "USAGE:\n\n"
  printf "cmd <option>\t\t:Use default cmdlets file\n"
  printf "cmd <cmdlets> <option>\t:Use a different cmdlets file\n\n"
  printf "cmd\t\t\t:displays stored commands by number\n"
  printf "  #\t\t\t:run line number as command\n"
  printf "  -  |--cmdlets\t\t:List/Select available cmdlets (fzf) \n"
  printf "\n"
  printf "  -f |--fzf\t\t:run line | copy to clipboard | delete line (fzf|xclip)\n"
  printf "  -fh|--fzf-history\t:add line from history (fzf|sourced)\n"
  printf "\n"
  printf "  -hn|--history #\t:add command from history number (sourced)\n"
  printf "  -l |--last\t\t:add last entered command from history (sourced)\n"
  printf "\n"
  printf "  -a |--add \'command\'\t:add \'command\' in \"double\" or \'single\' quotes to cmd file\n"
  printf "  -c |--copy #\t\t:copy line number to clipboard (xclip)\n"
  printf "  -m |--move # <file>\t:move line number to another or new cmdlets file\n"
  printf "  -d |--delete #\t:delete command by line number\n"
  printf "\n"
  printf "      --note \"text\"\t:add quoted \"text\" as note (prepend #DATE before entry) \n"
  printf "\n"
  printf "  -n |--numbers\t\t:displays stored commands by number (same as no options)\n"
  printf "\n"
  printf "  -e |--edit\t\t:edit cmdlets file\n"
  printf "  -b |--backup\t\t:backup cmdlets file with timestamp\n"
  printf "      --remove\t\t:remove blank lines and trailing spaces from cmdlets file\n"
  printf "      --clear\t\t:clear cmdlets file contents\n"
  printf "\n"
  printf "  -V |--version\t\t:version information\n"
  printf "  -h |--help\t\t:this usage\n"
  printf "\n"
  printf "%sUsing as standalone script vs sourced: $([[ $- != *i* ]] && printf "[STATUS: standalone script]" || printf "[STATUS: sourced]")\n"
  printf "  Commands ran from cmdlets will use your current shell environment when sourced.\n"
  printf "  History options will not work unless sourced.\n"
  printf "  Uses \'bash -c\' when standalone or \'eval\' when sourced to run commands.\n"
  printf "  Source this script from ~/.bashrc or manually source when needed.\n"
  printf "\n"
}

# Check if sourced or file
check_source() {
  [[ $- != *i* ]] && printf '%s\n' "Script must be sourced to use this option: source $0" && exit 1
}

# Run line number in file as command
run_command() {
  line=$(sed -n "${case_option}"p "${cmdfile}")
  #eval "${line}"
  #bash -c "${line[@]}"
  if [[ $- != *i* ]]; then bash -c "${line[@]}"; else eval "${line}"; fi
}

# Display each line listing by number
number_file_loop() {
  local number=0
  while IFS='' read -r LINE || [ -n "${LINE}" ]; do
    ((number++))
    printf '%+3s %s\n' "${number}": "${LINE}"
  done < "${cmdfile}"
}

# Copy line number to clipboard (xclip)
option_copy() {
  if [[ "${cmd_option}" ]]; then
    line=$(sed -n "${cmd_option}"p "${cmdfile}")
    printf '%s' "${line}" | xclip -selection clipboard | printf '\n' && printf '%s\n' "Line ${cmd_option} copied to clipboard (xclip)" || printf '\n' "Issue when copying to clipboard (xclip)"
    #echo "${line}" | xclip -selection clipboard && printf '%s\n' "Line ${cmd_option} copied to clipboard (xclip)" || printf '%s\n' "Issue when copying to clipboard (xclip)"
  else
    printf '%s\n' "Nothing entered to copy"
  fi
}

# Add/Append
option_add_command() {
  printf '%s\n' "${cmd_option[*]}" >> "${cmdfile}" && printf '%s\n' "Added last command to: ${cmdfile##*/}" || printf '%s\n' "Error adding command to: ${cmdfile##*/}"
}

# Display commands in file via fzf
option_fzf() {
  if [[ ! $(command -v fzf) ]]; then
    printf "Fzf not found and required for this option!"
  else
    runcmd=$(fzf \
      --header="<enter> Run | <ctrl-y> Xclip | <ctrl-d> Delete | <ctrl-e> EDITOR" \
      --bind="ctrl-e:execute-silent(${EDITOR} ${cmdfile} < /dev/tty > /dev/tty)+reload(cat ${cmdfile})" \
      --bind="ctrl-y:execute-silent(printf '%s' "{+}" | xclip -selection clipboard | printf '%s\n')+abort" \
      --bind="ctrl-d:execute-silent(grep -n {+} ${cmdfile} | cut -d: -f1 | xargs -I {} sed -i {}d ${cmdfile})+reload(cat ${cmdfile})" \
      --height 75% --reverse --exact --preview-window=hidden --multi=0 < "${cmdfile}")
    if [[ $- != *i* ]]; then bash -c "${runcmd[@]}"; else eval "${runcmd}"; fi
  fi
}

# Add command from history to file via fzf
option_fzf_add_history() {
  check_source
  if [[ ! $(command -v fzf) ]]; then
    printf "Fzf not found and required for this option!"
  else
    local histcmd
    #histcmd=$(fc -l -n 1 | tail -n1000 | sed 's/^\s*//' | fzf --header="<enter> Add line from history to cmd" --height 50% --reverse --exact --preview-window=hidden --multi=0)
    histcmd=$(history -w /dev/stdout | fzf --header="<enter> Add line from history to cmd" --height 50% --reverse --exact --preview-window=hidden --multi=0)
  fi
  if [[ "${histcmd}" ]]; then printf '%s\n' "${histcmd}" >> "${cmdfile}"; fi
}

# Add history number to cmdfile
option_add_history_number() {
  check_source
  if [[ ! "${cmd_option}" ]]; then printf '%s\n' "No history number entered!"; return ; fi
  if ! history | grep "^ ${cmd_option}" | cut -c8- | tee -a "${cmdfile}"; then printf '%s\n' "Issues adding history line!"; else printf '%s\n' "Added line ${cmd_option} from history"; fi
}

# Add/Append last command ran to file
option_last() {
  check_source
  #lastcmd=$(fc -ln | tail -2 | head -1)
  lastcmd=$(history -w /dev/stdout | tail -n2 | head -n1)
  printf '%s\n' "${lastcmd#"${lastcmd%%[![:space:]]*}"}" >> "${cmdfile}" && printf '%s\n' "Added last command to ${cmdfile##*/}" || printf '%s\n' "An error happened!"
}

# Delete command by line number from file
option_delete() {
  if [[ -z "${cmd_option}" ]]; then
    printf "No input entered\n"
  else
    sed -i "${cmd_option}"d "${cmdfile}" && printf "%sRemoved line ${cmd_option} from ${cmdfile##*/}\n" || printf "%sIssue removing line ${cmd_option} from ${cmdfile##*/}\n"
  fi
}

# Remove all double and trailing spaces in file
option_remove_blank() {
  #sed '$!N; /^\(.*\)\n\1$/!P; D' "${cmdfile}"
  sed -i '/^ *$/d' "${cmdfile}" || printf '%s\n' "Issue removing blank lines with sed"
  sed -i 's/[ \t]*$//' "${cmdfile}" || printf '%s\n' "Issue removing trailing spaces with sed"
  printf '%s\n' "Removed blank lines and trailing spaces from ${cmdfile##*/}"
}

# Backup command file using date-time stamp
option_backup() {
  local date_time
  date_time="$(printf '%(%Y-%m-%d_%H.%M.%S)T' -1)"
  cp "${cmdfile}" "${cmdfile}"-"${date_time}" && printf "%sCreated backup of ${cmdfile##*/} to ${cmdfile}-${date_time}\n" || printf "Issue creating backup copy\n"
}

# Clear entire contents of file
option_clear() {
  read -r -p "Press Enter to clear/delete ${cmdfile##*/} or CTRL+C to cancel: "
  true > "${cmdfile}" && printf '%s\n' "Cleared ${cmdfile}"
}

option_note() {
  printf '%s\n' "#[$(printf '%(%Y-%m-%d)T' -1)] ${cmd_option[*]}" >> "${cmdfile}" && printf '%s\n' "Added entry as note: ${cmdfile##*/}" || printf '%s\n' "Error adding entry as note: ${cmdfile##*/}"
}

option_move_line() {
  if [[ ! "${cmd_option}" ]]; then printf '%s\n' "No cmd number entered!"; return ; fi
  if [[ ! "${cmd_option2}" ]]; then printf '%s\n' "No destination file entered!"; return ; fi
  if [[ "${cmd_option}" ]]; then
    line=$(sed -n "${cmd_option}"p "${cmdfile}")
    if ! printf '%s\n' "${line}" >> "${cmd_option2}"; then
      printf '%s\n' "Issue when moving line: ${cmd_option} to file: ${cmd_option2}!"
    else
      printf '%s\n' "Moved line: ${cmd_option} to file: ${cmd_option2}"
      sed -i "${cmd_option}"d "${cmdfile}" || printf "%sIssue removing line ${cmd_option} from ${cmdfile##*/}\n"
    fi
  else
    printf '%s\n' "No number entered to move!"
  fi
}

option_cmdlets() {
  #lsfile=$(ls "${cmdlets}"/ | fzf --preview="(cat ${cmdlets}/{})" --preview-window="down:70%")
  #lsfile=$(find "${cmdlets}" -type f -exec basename {} \; | fzf --preview="(cat ${cmdlets}/{})" --preview-window="down:70%")

  #lsfile=$(find "${cmdlets}" -type f -printf "%f\n" | sort | fzf --preview="(cat ${cmdlets}/{})" --preview-window="down:70%")
  #if [[ ${lsfile} ]]; then cmd "${cmdlets}"/"${lsfile}" -f; fi

  lsfile=$(find "${cmdfile}" "${cmdlets}" -type f | sort | fzf \
             --header="<enter> Select cmdlet | <ctrl-e> EDITOR" \
             --bind="ctrl-e:execute(${EDITOR} {} < /dev/tty > /dev/tty)+reload(find ${cmdfile} ${cmdlets} -type f | sort)" \
             --preview="(cat {})" \
             --height="75%" \
             --preview-window="down:65%")
  if [[ ${lsfile} ]]; then cmd "${lsfile}" -f; fi
}

case_options() {
  # Main command options
  case "${case_option}" in
    [1-9]*) run_command ;;
    -c|--copy) option_copy ;;
    -f|--fzf) option_fzf ;;
    -fh|--fzf-history) option_fzf_add_history ;;
    -n|--number|--numbers) number_file_loop ;;
    -m|--move) option_move_line ;;
    -a|--add) option_add_command ;;
    -hn|--history) option_add_history_number ;;
    --note) option_note ;;
    -l|--last) option_last ;;
    -d|--delete|-rm) option_delete ;;
    --remove) option_remove_blank ;;
    -b|--backup) option_backup ;;
    --clear) option_clear ;;
    -e|--edit) "${EDITOR}" "${cmdfile}" ;;
    -V|--version) printf '%s\n' "bash_cmd ${version}" ;;
    -h|--help) usage ;;
    -|--cmdlets) option_cmdlets ;;
    *)
    if [[ ! "${case_option}" ]]; then
      number_file_loop
    else
      printf '%s\n' "${case_option}: not a valid option (--help for usage)"
    fi
    ;;
  esac
}

# ------------------------------------------------------------------
# Main function
cmd() {
  if [[ ! -e "${CMDLETS_DEFAULT_FILE}" ]]; then touch "${CMDLETS_DEFAULT_FILE}"; fi

  # Set variables based on if using file or not
  if [[ -f "$1" ]]; then
    #local cmdfile cmdlets case_option cmd_option
    cmdfile="$1"
    case_option="$2"
    cmd_option="$3"
    cmd_option2="$4"
  else
    #local cmdfile cmdlets case_option cmd_option
    cmdfile="${CMDLETS_DEFAULT_FILE}"
    cmdlets="${CMDLETS_DIR}"
    case_option="$1"
    cmd_option="$2"
    cmd_option2="$3"
  fi

  case_options "$@"
}

# If file is sourced / if not running interactively, don't do anything!
[[ $- != *i* ]] && cmd "$@"
