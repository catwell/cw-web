<!--@
  title="Disabling graphical password prompts"
  published="2014-10-24 21:30:00"
  description = [[
    Some command-line programs open graphical password prompts.
    Here is how to disable them.
  ]]
  updated = "2015-08-31 21:30:00"
-->

These days Linux systems tend to open graphical password prompts when a CLI
application needs user authentication. I don't know about you but I really
don't like that.

The first offender is git, which uses x11-ssh-askpass if installed. The
simplest solution would be not to install it but it is a dependency of
virt-manager on Arch Linux... Thankfully you can tell git not to use it:

    git config --global core.askpass ""

The second one, in my case, was [pass](http://www.passwordstore.org/).
If you try to use it in Gnome, the keyring hijacks the GPG agent
and you get that message (plus a graphical prompt):

    gpg: WARNING: The GNOME keyring manager hijacked the GnuPG agent.
    gpg: WARNING: GnuPG will not work properly - please configure
    that tool to not interfere with the GnuPG system!

The Gnome keyring is an annoying piece of software that replaces password
prompts for several tools including SSH and GPG. you can disable it this way:

    mkdir -p ~/.config/autostart
    cd !$
    cp /etc/xdg/autostart/gnome-keyring-* .
    for i in *; do echo "Hidden=true" >> $i; done

... but then GPG will use yet another graphical prompt! To finally stay in your
terminal, create the file `~/.gnupg/gpg-agent.conf` with the following content:

    pinentry-program /usr/bin/pinentry-curses
