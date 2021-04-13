# bash_cmd - Store and run commands from file

------------------------------------------------------

Function to be sourced from ~/.bashrc to manage commands for different projects or uses.

### Why

I wanted a way to store and run frequently used or complex commands based on different projects or computers I'm on.  Don't want a bunch of aliases or modify a bunch of different files like ~/.ssh/config for things I want to keep simple and don't need permanent.  Commands stored in ~/.cmdnotes or any other file can be sync'd between computers.

### Installation

Copy bash_cmd to ~/.bash_cmd or any location you choose.  Source the file from inside of your ~/.bashrc and use `cmd` to run function.

```
cp bash_cmd ~/.bash_cmd
echo "source ~/.bash_cmd" >> ~/.bashrc
```

### Usage

```
cmd                   :displays stored commands by number
  Text or Command     :any text after cmd will be added to file
  NUM                 :run line number as command
  -f |--fzf           :run line as command (fzf)
  -fa|--fzf-add       :add line from history to cmd file (fzf)
  -c |--copy          :copy line number to clipboard (xclip)
  -n |--numbers       :displays stored commands by number
  -a |--add-last      :add last command retaining double/single quotes
  -e |--edit          :edit command file
  -d |--delete #      :delete command by line number
  -b |--backup        :backup command file with timestamp
  -dd                 :delete blank lines from command file
  --clear             :clear command file contents
  --change PATH       :change PATH to a different command file
  --change            :set PATH to default command file
  -h |--help          :this usage
```

### Examples

Commands

```
# List stored commands by number
cmd
cmd -n
cmd --number

# List stored commands using fzf
cmd -f
cmd --fzf

# Add new command or note (anything entered after cmd is added)
cmd ln -s /home/user/some/folder/file /home/user/file
cmd echo "My Text Here"
cmd # Comment or not if recalled by number won't error #

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
cmd -c /home/user/myproject.cmd
cmd --change /home/user/myproject.cmd
cmd -c /home/user/anotherfile
```

~/.cmdnotes file contents

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
