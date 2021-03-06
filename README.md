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

* auth\_token: _your-auth-token_

Optional:

* host: _hostname_ * 
* port: _hostport_
* proxy\_host: _proxyhost_
* proxy\_port: _proxyport_
* group: _your-default-group_

\*) ruby shoutbox-client: REQUIRED!

### Usage

#### Quick Install

    mkdir ~/bin
    cd ~/bin
    wget https://github.com/asaaki/shoutbox-client-lib/raw/master/bash/shout.sh
    chmod +x shout.sh

#### Try

`shout.sh green bash-test`

#### Help

`shout.sh -h`

    # shoutbox.io Bash Script
    # 2011 by Christoph Grabo <chris@dinarrr.com>
    # License: MIT/X11

    Usage:
      shout.sh STATUS NAME [MESSAGE] [OPTION]...

      STATUS
      
        *only: (green|yellow|red|remove)

        'green' can go without a MESSAGE
        'yellow' and 'red' really need a MESSAGE!
        'remove' deletes a NAME term from your shoutbox

      NAME
      
        short descriptive term
        for example your service names, websites, servers, ...
        put "quotation marks" around the term if spaces are used

      MESSAGE
      
        *optional for green status
        
        information about what went wrong
        put "quotation marks" around the message if spaces are used
        HINT: you can use HTML tags like <a href="{URL}">service-link</a>

      OPTIONS

        -g|--group GROUPNAME
        
          *optional
          you can group your shouts
          put "quotation marks" around the group if spaces are used
          
        -e|--expires|--expires_in SECONDS
        
          *optional
          you can group your shouts
          put "quotation marks" around the group if spaces are used


### Notes

Default group is: **Home**

No proxy settings integrated yet!

## PHP `shout.php`

A PHP Class for pushing to shoutbox.io

### Requirements

Really needs PHP5, minimum version of 5.1 because of an small curl issue for sending PUT requests.
No, no support for PHP4 - this version is outdated and should never be used!

PHP **libcurl** extension is optional but recommended. (Failsafe: Zend HTTP Client, see below)

### Install

Clone the repo and copy the php directory where you need it.

Follow the Usage instructions.

### Usage

    require 'php/shout.php'
    $shtbx = new ShoutboxClient();
    $shtbx->setAuthToken("<YOUR_AUTH_TOKEN>");
    
    $shtbx->shout(array(
      'status'      =>  'green',
      'name'        =>  'MyTask',
      'message'     =>  'MyMessage',
      'group'       =>  'MyGroup',
      'expires_in'  =>  seconds,
      'options'     =>  array()
    ));
    
    # or
    
    $shtbx->shout('green','MyTask','MyMessage','MyGroup',seconds,array());

Every call will return a boolean, so you can check if the call was successful.

### Shorties

There are some methods for direct status calls:

    $shtbx->green('MyTask','MyMessage');
    $shtbx->yellow('MyTask','MyMessage');
    $shtbx->red('MyTask','MyMessage');
    $shtbx->remove('MyTask');

### Notes

Default group is: **Home**

The *options* array has still no function now. This is for future purposes.
You can leave it away, it will never hurts anything and anybody.

The default configuration is hard-coded and points to the shoutbox.io server.

If you need other config values you can use the `->configure('key','value')` method call.

No proxy settings integrated yet!

#### Keep in mind

If you use the shorter non-array method call you have to set `NULL` for unused values.

Examples:

    $shtbx->green('MyTask',NULL,'OtherGroup');
    $shtbx->red('MyTask','MyMessage',NULL,3600);

Example 1: We don't want to have a *message* but a *group*.
Example 2: We don't want to set a *group* but an *expires_in* time value.

#### Zend HTTP Client lib

shout.php is shipped with some Zend lib files for doing HTTP request on systems where no libcurl is built in into PHP.

That should guarantee a wide range usage on many systems.

## WordPress plugin `wp-shoutbox`

**Planned**

Will be based on the **shout.php** class lib.

## Ruby

For the Ruby version use the corresponding repo/rubygem: [shoutbox-client](https://github.com/benjaminkrause/shoutbox-client)

It has also a standalone shell binary, but this one __needs__ an installed Ruby.

(The rubygem is also integrated here as submodule.)

Quick Install:

    gem install shoutbox-client

In Ruby:

    require 'shoutbox_client'

Try and play:

    ShoutboxClient.shout :name => "name", :status => "status", :group => "group", :message => "message", :expires_in => 3600

## Python `shout.py`

*Who will write it?*

## Perl `shout.pl`

*Who will write it? Who needs it?*

## Other languages

If you think, there should be an implementation in other languages:

Develop the stuff, publish it to github and let me know.

I'll then *submodule* them here if it's okay.

## Forks

Of course, you can fork the project and make it better.

Send me your improvements and enhancements as a pull request.

**Notice**

Try to use **[git flow](https://github.com/nvie/gitflow)**! It's cool and easy!
    
## Copyrights

### This library

Copyright (c) 2011 Christoph Grabo. See LICENSE.txt for details.

MIT License http://en.wikipedia.org/wiki/MIT_License

IN SHORT: It's free. You can use it commercially. Don't sue me.

### External parts

#### shoutbox ruby client (via submodule)

The **ruby client** is copyrighted by Benjamin Krause.

See ruby/LICENSE.txt for further details.

#### Zend stuff (used in PHP class)

The **Zend library files** are copyrighted by Zend Technologies USA Inc. and licensed under the *New BSD* license.

See php/Zend/LICENSE.txt or http://framework.zend.com/license/new-bsd for details.

