# bash_cmd - Store and run commands from file

Function to be sourced from ~/.bashrc to manage commands for different projects or uses.

### Why

Wanted a way to store and run frequently used or complex commands based on different projects or computers I'm on.  Don't want a bunch of aliases or other configs for things I want to keep simple and don't need permanent.  Commands stored in ~/.cmdnotes or any other file can be sync'd between computers.

### Installation

Copy bash_cmd to ~/.bash_cmd or any location you choose.  Source the file from inside of your ~/.bashrc and use `cmd` to run function.

```
cp bash_cmd ~/.bash_cmd
echo "source ~/.bash_cmd" >> ~/.bashrc
```

### Usage

```
Store and run commands from file:

Usage:
  cmd <option>          :Use default file as source
  cmd <file> <option>   :Use another file as source

  cmd                   :displays stored commands by number
    ##                  :run line number as command
    -f |--fzf           :run line as command or copy to clipboard (fzf/xclip)
    -fa|--fzf-add       :add line from history to cmd file (fzf)
    -fd|--fzf-delete    :delete line from cmd file (fzf)
    -n |--numbers       :displays stored commands by number
    -c |--copy          :copy line number to clipboard (xclip)
    -l |--last          :add last command retaining double/single quotes
    -a |--alias #       :create named bash alias from cmd number
    -as|--alias-save #  :save named bash alias in ~/.bash_aliases
    -d |--delete #      :delete command by line number
    -e |--edit          :edit cmd file
    -b |--backup        :backup cmd file with timestamp
    -dd                 :delete blank lines and trailing spaces from cmd file
    --clear             :clear cmd file contents
    -h |--help          :this usage

Default: [/home/user/.cmdnotes]
 Source: [/home/user/.cmdnotes]
```

### Examples

#### Command examples

```
# List stored commands by number
cmd
cmd -n
cmd --number

# List stored commands using fzf
cmd -f
cmd --fzf

# Use another file as source
cmd ~/nmapcmd
cmd ~/nmapcmd -f
cmd ~/cmds/sshfs -d 2

# Add command from history
cmd -fa
cmd --fzf-add

# Add last command ran from shell
cmd -a
cmd --add

# Delete command from list by number
cmd -d 8
cmd --delete 8

# Edit cmd file (~/.cmdnotes)
cmd -e
cmd --edit

# Use a different cmd file
cmd -as 3
cmd --alias-save 3
```

#### ~/.cmdnotes file contents example

```
echo My Text Here
nmap -p 22 --open -sV 192.168.2.0/24 > ~/sshservers.txt
sudo openvpn --pull-filter ignore redirect-gateway --config myfile.ovpn
sudo journalctl -r -p emerg -p alert -p crit -p err
if [[ ! $(systemctl status myproject@user.service) ]]; then notify-send MyProject failed; fi

cd /srv/docker/MyProject
vim /etc/systemd/system/myproject.service

sshfs user@server:/home/user/ /home/user/sshfs/
ssh user@192.168.2.31   # sambadc1 (debtest)
ssh user@192.168.2.32   # sambafs1 (debtest)
```

#### ~/.bash Alias examples

```
alias cmdf='cmd -f'                     # Start cmd with fzf option
alias cmd-nmap='cmd ~/cmd/nmap'         # Use file with list of nmap commands
alias cmd-sshfs='cmd ~/cmd/sshfs -f'    # Use file with list of sshfs commands with fzf
```
