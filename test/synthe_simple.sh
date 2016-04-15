#!/bin/bash

rm -rf fort.*
rm -rf modatm

echo "SYNBEG"
../bin/synbeg.exe <<EOF
AIR       1550.0    1560.0    3000000.    0.00    0     30    .0001     1   72
AIRorVAC  WLBEG     WLEND     RESOLU    TURBV  IFNLTE LINOUT CUTOFF        NREAD
  1           -0.000
  2           -0.000
  3           -0.000
  4           -0.000
  5           -0.000
  6           -0.000
  7           -0.000
  8           -0.000
  9           -0.000
 10           -0.000
 11           -0.000
 12           -0.000
 13           -0.000
 14           -0.000
 15           -0.000
 16           -0.000
 17           -0.000
 18           -0.000
 19           -0.000
 20           -0.000
 21           -0.000
 22           -0.000
 23           -0.000
 24           -0.000
 25           -0.000
 26           -0.000
 27           -0.000
 28           -0.000
 29           -0.000
 30           -0.000
 31           -0.000
 32           -0.000
 33           -0.000
 34           -0.000
 35           -0.000
 36           -0.000
 37           -0.000
 38           -0.000
 39           -0.000
 40           -0.000
 41           -0.000
 42           -0.000
 43           -0.000
 44           -0.000
 45           -0.000
 46           -0.000
 47           -0.000
 48           -0.000
 49           -0.005
 50           -0.036
 51           -0.173
 52           -0.355
 53           -0.456
 54           -0.562
 55           -0.679
 56           -0.804
 57           -0.930
 58           -1.070
 59           -1.152
 60           -1.228
 61           -1.274
 62           -1.316
 63           -1.356
 64           -1.398
 65           -1.451
 66           -1.485
 67           -1.519
 68           -1.545
 69           -1.579
 70           -1.615
 71           -1.662
 72           -1.662
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

echo "ROTATE"
cp ./fort.7 ./fort.1
../bin/rotate.exe  <<EOF
    1
-2.020
EOF

#convert the spectrum into an ascii file
mv ROT1 fort.1
echo "running syntoascanga..."
../bin/syntoascanga.exe > /dev/null

