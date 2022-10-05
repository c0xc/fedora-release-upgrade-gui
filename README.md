fedora-release-upgrade-gui
==========================

A simple script for starting a Fedora release upgrade.

It uses Zenity to show a dialog asking if the next release version
should be downloaded and installed. If you deny, nothing happens.

In a terminal environment without display (or with --cli),
all messages and questions are shown in your terminal.

No command line voodoo required:
This tool is supposed to allow an end user to upgrade Fedora using a gui,
without having to run commands as root (as described in the online documentation).

> The script determines the currently installed Fedora version
and assumes that the user wants to upgrade to the next one.
> It's up to the user to decide if it makes sense to upgrade to the next version.
> There's currently no check in the script that would determine
if the next release version is a stable release.
> **An upgrade to an unstable release is not recommended**.
> Even though personal files are not touched during a release upgrade,
**it is recommended to have a backup.**



Why
---

Every workstation OS (i.e., not designed for admins or such) comes with
a graphical update tool that not only provides a way to install package updates
but also allows the user to upgrade to the next release if one is available.

Unfortunately, Fedora does not have *one reliable tool for the job*.
- A long time ago, there used to be __PreUpgrade__. It was deprecated in Fedora 17.
- Then there was __FedUp__, which had to be used for upgrades to Fedora 17 and later.
  Sadly, it didn't have a graphical user interface, which means release upgrades
  had to be done by users who are comfortable using the command line.
  This quote from the official Fedora documentation shows that an upgrade GUI
  was not considered a priority:
  > At this time, only the fedup command-line interface is implemented but a GUI interface is expected...sometime.
- For quite some time, Fedora users had to install and use the command line
  tool __dnf-plugin-system-upgrade__, which is actually a DNF plugin.
- In Fedora 23, __GNOME Software__ (`gnome-software`) became the official upgrade tool.
  It's a graphical tool (it's actually a PackageKit frontend).
  Sadly, it often doesn't work.

If there's an official upgrade mechanism, a graphical upgrade tool that works,
definitely use that instead of this script.
This tool is a simple alternative to provide an upgrade GUI.

Another reason for using this script may be that the official tool
sometimes fails, showing an incomplete error message:

    Could not depsolve transaction; 1 problem detected:

What's the poor user supposed to do with that?
This script might help. Although it could also fail, it should at least
display the complete error message (which is also written to the log file).



Installation
------------

No installation required, just run the script file.
In most cases, it should be possible to execute the script file
(e.g., in a file manager like Caja) without first opening a terminal window.

In Caja, open the file "Properties" dialog, go to the "Permissions" tab
and check "Allow executing file as program".

It'll first try to get root access, which is required to prepare the upgrade
process. This is why it first asks for a password.
Don't worry, it'll ask you if you actually want to upgrade to the next release
(it'll say which release that would be) before actually doing anything.

It'll use gksu or similar to show a password prompt (in GUI mode).
If that doesn't work for some reason, you can still run the script in a
terminal window and it'll automatically ask for a sudo password.

To prevent that (to get a graphical password prompt), run it like that:

    ./fedora-release-upgrade <&-

If the script is not run in a terminal, it'll first try gksu/kdesu
(rather than gksudo/kdesudo), which means it'll expect the root password
rather than the user's (sudo) password.
This is because sudo usually isn't configured properly
in default Fedora installations.

Note that after the release upgrade files have been downloaded,
this tool will ask a second time if the upgrade process should really be started.
If you don't confirm, the system will not be changed.

To manually verify if the upgrade was completed during the reboot,
you could run something like:
- `cinnamon-settings info`
- ... or you could just check /etc/fedora-release.



What
----

What does the script actually do and why does it ask for the sudo password?

The first thing this script does is ask for the sudo password.
To be more precise, it creates a temporary script in /tmp and
attempts to run that script as root.
That script will first ask you if it can go ahead with the download process
and then it'll ask again before rebooting, so if if you don't confirm ("Y"),
nothing will happen. If you don't trust me (and maybe you shouldn't)
you can read the temporary script before typing in your sudo password.

Before it can download the release upgrade files, it has to make sure
the system-upgrade plugin is installed, which is why it needs to be root.

It goes through these steps:

0. Install system-upgrade plugin.
1. Download release files (may take over an hour).
2. Ask for confirmation and reboot to start the upgrade process (may take even longer).

If all goes well, the system will boot the new release after the offline upgrade process is complete.



Bugs
----

This is a very simple helper script that ideally shouldn't be necessary at all.
So there are quite a few things that it *could* do (but doesn't).

- The release check may fail from time to time
  ("A newer release could not be found").
- It should check online for the latest **stable** release.
- It could do some additional cleanup work.
- It could show some sort of message after the system has been rebooted
  to tell the user that it worked. The official way usually provides no feedback
  (besides hints like a new wallpaper), so the user has to manually check
  if the system was actually upgraded or not.
- It could offer help in case of dependency errors.
  System upgrades do fail sometimes (possibly during the actual upgrade phase
  while the system is booting).
  The actual error messages are not always shown to the user.
  A typical scenario is that many (hundreds of) error messages like:
  > file from A conflicts with file from B
  
  Package B is probably just one package, maybe two or three.
  It's almost always ok to uninstall package B in order
  to be able to run the upgrade.
  In many cases, package B is just an older or a different version of package A.



Author
------

Philip Seeger (philip@c0xc.net)



License
-------

Please see the file called LICENSE.

