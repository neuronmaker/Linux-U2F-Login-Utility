# Linux-U2F-Login-Utilities
Some utilities to make U2F configuration on Linux easier for casual user usecases

# u2f-enroll.sh
A BASH script that repeatedly runs the pamu2fcfg program and appends the output to a file, use this to generate the u2f_mappings file that libpam-u2f uses for authentication.

Run this program once for each user that should be in the mappings file, they can register as many U2F devices as your system's configuration supports (typically 24 U2F devices per user at any given time).
