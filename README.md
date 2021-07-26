# bash_cmd - Store and run commands from file

### Why

I wanted a way to store and run frequently, but changing complex commands based on different projects or computers I'm on.  Too much copy/pasting and don't want a bunch of aliases or other configs for things I want to keep simple and don't need permanent.  Commands stored in ~/.cmdnotes or any other file in ~/.cmdlets/ can be sync'd between computers.

-----------------------------------

### Installation

Use as standalone script `~/bin/cmd`

```
mv bash_cmd ~/bin/cmd
chmod +x ~/bin/cmd
```
or source this file inside your `~/.bashrc`

```
echo "source ${HOME}/bin/cmd" >> ~/.bashrc
```

- Optional Requirements:  [fzf](https://github.com/junegunn/fzf) [xclip](https://linux.die.net/man/1/xclip)
- Run script or function (if sourced in ~/.bashrc) by typing `cmd` in terminal.  Some options like history won't work unless script is sourced.  Manually source file by typing `source ~/bin/cmd` in your terminal when needed.

-----------------------------------

### Notes

- Uses 'bash -c' when used as standalone script or 'eval' when sourced.
- The script will let you know if certain options won't work unless script is sourced.
- Can use script without [fzf](https://github.com/junegunn/fzf) or xclip installed on your system, but [fzf](https://github.com/junegunn/fzf) should really be considered.
- You will get a message when trying to use options without required program installed.

-----------------------------------

### Usage

```
bash_cmd - Store and run commands from file:

USAGE:

cmd <option>            :Use default cmdlets file
cmd <cmdlets> <option>  :Use a different cmdlets file

cmd                     :displays stored commands by number
  #                     :run line number as command
  -  |--cmdlets         :List/Select available cmdlets (fzf) 

  -f |--fzf             :run line | copy to clipboard | delete line (fzf|xclip)
  -fh|--fzf-history     :add line from history (fzf|sourced)

  -hn|--history #       :add command from history number (sourced)
  -l |--last            :add last entered command from history (sourced)

  -a |--add 'command'   :add 'command' in "double" or 'single' quotes to cmd file
  -c |--copy #          :copy line number to clipboard (xclip)
  -m |--move # <file>   :move line number to another or new cmdlets file
  -d |--delete #        :delete command by line number

      --note "text"     :add quoted "text" as note (prepend #DATE before entry) 

  -n |--numbers         :displays stored commands by number (same as no options)

  -e |--edit            :edit cmdlets file
  -b |--backup          :backup cmdlets file with timestamp
      --remove          :remove blank lines and trailing spaces from cmdlets file
      --clear           :clear cmdlets file contents

  -V |--version         :version information
  -h |--help            :this usage

Using as standalone script vs sourced: [STATUS: sourced]
  Commands ran from cmdlets will use your current shell environment when sourced.
  History options will not work unless sourced.
  Uses 'bash -c' when standalone or 'eval' when sourced to run commands.
  Source this script from ~/.bashrc or manually source when needed.
```

-----------------------------------

### cmdlets

cmdlets are files with commands listed in them.  This is a way to organize and separate commands based on projects or different uses.  The default cmdlet file is `~/.cmdnotes` while the default cmdlets directory is `~/.cmdlets/`.

Configure the environment variables `CMDLETS_DEFAULT_FILE` and `CMDLETS_DIR` in your `~/.bashrc` to change the defaults.

```
export CMDLETS_DEFAULT_FILE="${HOME}/.cmdnotes"
export CMDLETS_DIR="${HOME}/.cmdlets"
```

#### Example directory tree of cmdlets
```
/home/user/.cmdlets/
├── bulkcmds
├── nmap
├── oneliners
├── openvpn
├── phython_env
├── project-alpha
├── samba
├── sar
├── sshfs
├── tools
└── vagrant
```

#### ~/.cmdlets/vagrant (example)

```
vagrant init           # Initial guest
vagrant up             # Start guest
vagrant destroy        # Remove guest
vagrant ssh-config     # View ~/.ssh/config of guest
```

#### ~/.cmdlets/sar

```
sar -h -u ALL     # CPU
sar -P ALL        # CPU All Cores
sar -h -r         # Mem
sar -h -S         # Swap
sar -b            # I/O
sar -h -p -d      # I/O Dev
sar -q            # Load
sar -h -n DEV     # Net
```

#### ~/.cmdnotes file contents example

```
#[2021-07-12] My test project commands
cd /srv/MyProject/sampledata
nmap -p 22 --open -sV 192.168.200.0/24 > ~/sshservers.txt
if [[ ! $(systemctl status myproject@user.service) ]]; then notify-send MyProject failed; fi
sudo journalctl -r -p emerg -p alert -p crit -p err
vim /etc/systemd/system/myproject.service
ssh user@192.168.200.31   # sambadc1 (debtest)
ssh user@192.168.200.32   # sambafs1 (debtest)
sshfs user@sambafs1:/home/user/ /home/user/sshfs/
```

--------------------------------

### Command examples

```
# Display stored commands by number
cmd
cmd -n

# Run command by number
cmd 3
cmd 12

# Use another cmdlets file as source
cmd ~/.cmdlets/nmap
cmd ~/.cmdlets/sar 5
cmd ~/.cmdlets/sshfs -d 3

# Use fzf to select from ~/.cmdlets/*
cmd -
cmd --cmdlets

# List|Run|Copy|Delete stored commands using fzf
cmd -f
cmd --fzf
cmd ~/.cmdlets/sar --fzf

# Add command from history using fzf
cmd -fa
cmd --fzf-add

# Add last command ran from shell
cmd -l
cmd --last

# Delete command by number
cmd -d 8
cmd --delete 8
cmd ~/.cmdlets/vagrant -d 4

# Edit cmd file (~/.cmdnotes)
cmd -e
cmd --edit
cmd ~/.cmdlets/samba -e

# Move command from one cmdlet file to another
cmd -m 4 .cmdlets/tools

# Create a timestamp note
cmd --note "Your note here"
```

--------------------------------

### Alias examples

# Start cmd with fzf (use cmd -n) to use default.
`alias cmd='cmd -f'`

# Add alias to start with `sar` commands.
`alias sarcmd='cmd ~/.cmdlets/sar'`

