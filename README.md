## SYNTHE

Working end-to-end Fortran and Shell script for Bob Kurucz's SYNTHE code. This code has been compiled and tested on Harvard's Odyessy cluster and TACC Stampede

## Installation

Sync this GitHub and compile the code in src/ using make:

make synthe install clean

Requires Intel's IFORT as this is the only compiler that Bob supports for SYNTHE.

## Tests

There is an example test script in test/ that runs end-to-end (No broadening right now, this will change).

## Contributors

- Phill Cargile
- Bob Kurucz
- Charlie Conroy
- Yuan-Sen Ting
