# SSH Quick Connect Script

## Overview

Welcome to the **SSH Quick Connect Script**! This bash script is your trusty sidekick in the quest to connect to remote servers without the fuss. If you’ve ever found yourself typing out a long SSH command with an IP address and a PEM key, this script is here to save you a few precious seconds of your life—because let’s be honest, who doesn’t want to spend less time typing and more time... well, not typing?

## Features

- **User-Friendly**: Pass your `user@ip` as an argument, and it handles the rest! (Don’t worry, we’ll default to “ubuntu” if you forget.)
- **IP Validation**: Validates the IPv4 address for you, because we all know it’s easy to mess that up.
- **PEM Key Handling**: Automatically finds a PEM key in the current directory, or you can specify one. And yes, it checks the permissions—no more worrying about your secrets being too exposed!
- **Minimalist**: Just a simple, straightforward script. No frills, no thrills—just SSHing away!

## Usage

To use the script, simply run:

```bash
./ssh_quick_connect.sh user@ip [optional_pem_key_path_or_-d]
