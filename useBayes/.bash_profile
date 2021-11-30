# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile
umask 022

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f ~/.bashrc ]; then
	. ~/.bashrc
    fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d ~/bin ] ; then
    PATH=~/bin:"${PATH}"
fi



##
# Your previous /Users/longhai/.bash_profile file was backed up as /Users/longhai/.bash_profile.macports-saved_2013-08-15_at_09:34:37
##

# MacPorts Installer addition on 2013-08-15_at_09:34:37: adding an appropriate PATH variable for use with MacPorts.
export PATH=/opt/local/bin:/opt/local/sbin:$PATH
# Finished adapting your PATH environment variable for use with MacPorts.


##
# Your previous /Users/longhai/.bash_profile file was backed up as /Users/longhai/.bash_profile.macports-saved_2015-06-11_at_10:37:40
##

# MacPorts Installer addition on 2015-06-11_at_10:37:40: adding an appropriate PATH variable for use with MacPorts.
export PATH="/opt/local/bin:/opt/local/sbin:$PATH"
# Finished adapting your PATH environment variable for use with MacPorts.


##
# Your previous /Users/longhai/.bash_profile file was backed up as /Users/longhai/.bash_profile.macports-saved_2015-06-11_at_10:46:03
##

# MacPorts Installer addition on 2015-06-11_at_10:46:03: adding an appropriate PATH variable for use with MacPorts.
export PATH="/opt/local/bin:/opt/local/sbin:$PATH"
# Finished adapting your PATH environment variable for use with MacPorts.


##
# Your previous /Users/longhai/.bash_profile file was backed up as /Users/longhai/.bash_profile.macports-saved_2016-05-06_at_10:41:15
##

# MacPorts Installer addition on 2016-05-06_at_10:41:15: adding an appropriate PATH variable for use with MacPorts.
export PATH="/opt/local/bin:/opt/local/sbin:$PATH"
# Finished adapting your PATH environment variable for use with MacPorts.


# Setting PATH for Python 3.5
# The original version is saved in .bash_profile.pysave
PATH="/Library/Frameworks/Python.framework/Versions/3.5/bin:${PATH}"
export PATH
