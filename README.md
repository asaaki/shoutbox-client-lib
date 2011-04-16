# Shoutbox Client Lib

Different [shoutbox.io](http://shoutbox.io) client implementations.

Keep in mind: **[shoutbox.io](http://shoutbox.io) is still beta!**

*Many thanks to [benjaminkrause](https://github.com/benjaminkrause) and [hagenburger](https://github.com/hagenburger) for this service!*

## When and why to use shoutbox.io

There can be many, many purposes.

Monitoring status of servers, services and applications.

Did the background job finished successful?
(And for example maybe with "yellow" status: is it currently running?)

Webserver still running?

Server system overloaded?

Is my inbox overflooded?

Is the fridge empty?

Is MY coffee brewed? AND: Did somebody took it away???

Or use it as a task planner and brainstorming area.

Implement an internal chat system.

So many ideas ...

## Bash `shout.sh`

The standalone shell script which only needs an installed `curl`.
(Debian/Ubuntu: `sudo apt-get install curl`)

This script can be used on systems where no Ruby available or should not be installed on.

It's for easier usage on a shell and tries to imitate the functionality of the Ruby standalone script.

### .shoutbox config file

Required:

* auth_token: _your-auth-token_

Optional:

* host: _hostname_ * 
* port: _hostport_
* proxy_host: _proxyhost_
* proxy_port: _proxyport_
* group: _your-default-group_

\*) ruby shoutbox-client: REQUIRED!

### Usage

Quick Install:

    wget https://github.com/asaaki/shoutbox-client-lib/raw/master/bash/shout.sh

(Put the script into your ~/bin directory and `chmod +x` the file)

Help: `shout.sh -h`

Try: `shout.sh green "shout.sh Test"`

Default group is: **Home**

## PHP `shout.php`

*Coming soon ...*

## Python `shout.py`

*Who will write it?*

## Ruby

For the Ruby version use the corresponding repo/rubygem: [shoutbox-client](https://github.com/benjaminkrause/shoutbox-client)

It has also a standalone shell binary, but this one __needs__ an installed Ruby.

Quick Install:

    gem install shoutbox-client

In Ruby:

    require 'shoutbox_client'

Try and play:

    ShoutboxClient.shout :name => "name", :status => "status", :group => "group", :message => "message", :expires_in => 3600
