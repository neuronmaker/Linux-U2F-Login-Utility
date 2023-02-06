Linux-U2F-Login-Utilities
=========================

Some utilities to make U2F configuration on Linux easier for casual user to
manage this type of authentication. It is my hope that someone from the more
beginner-friendly Linux distros will see this repository and build a more friendly
graphical program into their settings program to manage U2F authentication.

Until that happens, this repo will have to suffice.

u2f-enroll.sh
-------------

A BASH script that repeatedly runs the ```pamu2fcfg``` program and appends the output
to a file, use this to generate the ```u2f_mappings``` file that ```libpam-u2f``` uses for
authentication.

Run this program once for each user that should be in the mappings file, they can
register as many U2F devices as your system's configuration supports (typically
24 U2F devices per user at any given time). Once the file is created, it can be
installed to wherever your specific system is set up to look for it. Typically,
the preferred way is to move the output file to ```/etc/u2f_mappings``` and set
the permissions so that only the ```root``` user can edit or view the file.


