## SYNTHE

Working end-to-end Fortran and Shell script for Bob Kurucz's SYNTHE code. This code has been compiled and tested on Harvard's Odyessy cluster and TACC Stampede

## Installation

Sync this GitHub and compile the code in src/ using make:

make synthe install clean

Requires Intel's IFORT as this is the only compiler that Bob supports for SYNTHE.

You will also need to grab either an rgfall line list from e.g., Bob's website, or a binary master line list for use with rpunchbin.for. Place these files in the data/ directory. Examples of these files have been placed on PAC's dropbox:

gfall file:

https://www.dropbox.com/s/ak237xfkkz1dnqj/gfall18feb16.dat

or 

binary master line list file:

https://www.dropbox.com/s/0fwqzorab1xdn8l/KuruczLL_1400_1900.bin.gz

(Be sure to gunzip the binary master line list file!)

## Tests

There is an example test script in test/ that runs end-to-end (No broadening right now, this will change).

## Contributors

- Phill Cargile
- Bob Kurucz
- Charlie Conroy
- Yuan-Sen Ting
