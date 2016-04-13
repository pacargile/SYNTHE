#!/bin/bash

rm -rf fort.*
rm -rf modatm

echo "SYNBEG"
../bin/synbeg.exe <<EOF
VAC       1495.0    1705.0    300000.     0.00    0     30    .0001     1    0
AIRorVAC  WLBEG     WLEND     RESOLU    TURBV  IFNLTE LINOUT CUTOFF        NREAD
EOF

echo ""

#echo "Reading atoms"
#ln -s ../data/gfall18feb16.dat fort.11
#../bin/rgfall.exe > /dev/null
#rm -f fort.11
#echo ""

echo "READ IN MASTER LL"
ln -s ../data/FullLL_1400_1900.bin fort.11
../bin/rpunchbin.exe 
rm -f fort.11
echo ""

#link various necessary files
cp ../data/he1tables.dat fort.18
cp ../data/molecules.dat fort.2
cp ../data/continua.dat  fort.17

echo "XNFPELSYN"
cp ../data/modatm.dat modatm
../bin/xnfpelsyn.exe < modatm > /dev/null
echo ""

echo "SYNTHE"
../bin/synthe.exe > /dev/null
echo ""

cp ../data/modatm.dat fort.5
cp ../data/spectrv.input fort.25
echo "SPECTRV"
../bin/spectrv.exe > /dev/null
echo ""

#convert the spectrum into an ascii file
mv fort.7 fort.1
echo "syntoascanga"
../bin/syntoascanga.exe > /dev/null

