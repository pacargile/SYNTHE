      PROGRAM RPUNCHBIN
c     PROGRAM RGFALLDEL
c     scroll down to XX to make global changes to punch files
c     revised 4nov14  constants given D exponents
c     revised 14nov13  GS can be too big for high series members
c     revised 18may11  John Lester error in ion pot lookup for high ions
c     revised 28oct09  error in isotope shift in vacuum
c     revised 25jun05  isoshift is now wavelength shift in mA instead of mK
c     revised 25may97
c     this program is a quick and dirty demonstration of replacing programs
c     RNLTE and RLINE while keeping all the other SYNTHE programs the same.
C      READS LINES FROM UNIT 11 AND WRITES THEM ON UNIT 19 IF THE LINE
C      WAS ORIGINALLY FROM THE FILE NLTELINES.DAT OR TO UNIT 12 IF NOT,
C      IF IFNLTE=0 UNIT 19 IS READ BY SYNTHE AND THE LINES ARE
C      TREATED IN LTE.  IF IFNLTE=1 UNIT 19 IS READ BY SPECTR AND THE
C      LINES ARE TREATED IN NLTE IF THE MODEL IS NLTE.
C        THESE LINES ARE TREATED WITH EXACT VOIGT OR FANO PROFILES
C     WL IS THE AIR WAVELENGTH IF WL .GT. 200 NM
C        IF THE SWITCH IFVAC=1 THE WAVELENGTH USED BY THE PROGRAM WILL
C        BE THE VACUUM WAVELENGTH OBTAINED FROM THE DIFFERENCE OF
C        THE ENERGY LEVELS
C     A SUFFIX P STANDS FOR PRIME INDICATING THE SECOND CONFIGURATION
C     J IS ANGULAR MOMENTUM
C     E IS ENERGY IN WAVENUMBERS
C     LABEL IS A LABEL FOR THE CONFIGURATION
C          THE GF TAPE DOES NOT KEEP LABEL AND LABELP DISTINCT
C     CODE FOR ATOM OR MOLECULE
C     NELION IS THE STORAGE LOCATION OF ELEM IN ARRAYS XNFPEL AND DOPPLE
C     GAMMAR IS THE RADIATIVE DAMPING CONSTANT
C     GAMMAW IS THE DAMPING CONSTANT PER HYDROGEN ATOM FOR VAN DER WAALS
C            BROADENING BY HYDROGEN AT T=10000K.
C            FOR HELIUM MULTIPLY BY .42
C            FOR H2 MULTIPLY BY .85
C     GAMMAS IS THE STARK DAMPING CONSTANT PER ELECTRON ASSUMED TO BE
C            TEMPERATURE INDEPENDENT
C     TO CONVERT GRIEM"S HALF WIDTH TO GAMMAS  FOR DLAM AND LAM IN A
C     GAMMAS=3767.*DLAM/LAM**2
C     LOG(GAMMA) IS READ IN
C     IF NOT READ IN GAMMAR IS CLASSICAL, GAMMAW IS FROM ALLER, AND
C            GAMMAS IS FROM PEYTREMANN
C     REF ARE A REFERENCE OR REFERENCES FOR GF AND DAMPING CONSTANTS
C     NBLO AND NBUP REFER TO DEPARTURE COEFFICIENT ARRAYS FOR THE LOWER
C        AND UPPER LEVELS (NOT FIRST AND SECOND)
C     ISO1 AND ISO2 ARE ISOTOPE NUMBERS FOR UP TO 2 COMPONENTS
C     X1 AND X2 ARE LOG FRACTIONAL ISOTOPIC ABUNDANCES THAT ARE ADDED TO
C        LOG GF TO OBTAIN AN ISOTOPIC ABUNDANCE
C     OTHER1 AND 2 ARE ADDITIONAL LABEL FIELDS OR QUANTUM NUMBERS OR
C        WHATEVER
C        OTHER1 IS NOW USED TO STORE LANDE G VALUES AS 2 I5 INTEGERS IN UNITS
C        OF .001 .  EXAMPLE  GLANDE=-.007 GLANDEP=2.499   OTHER1=   -7 2499
C     DWL  CORRECTION TO WL
C     DLOGGF  CORRECTION TO LOGGF
C     DGAMMAR  LOG CORRECTION TO GAMMAR
C     DGAMMAS  LOG CORRECTION TO GAMMAS
C     DGAMMAW  LOG CORRECTION TO GAMMAW
C     ISOSHIFT  IS ISOTOPE SHIFT OF WAVELENGTH IN MK = 0.001 CM-1  changed to mA
C     ISOSHIFT  IS ISOTOPE SHIFT OF WAVELENGTH IN MA = 0.001 Angstrom = 0.0001 nm
CC     SAMPLE CARDS
C 396.8470 -0.162  0.5       0.000  1.5   25191.541    20.01 4S        4P
C 396.8470 116  8.24 -4.44 -7.80 REF
      PARAMETER (kw=99)
      COMMON /LINDAT/WL,E,EP,LABEL(2),LABELP(2),OTHER1(2),OTHER2(2),
     1        WLVAC,CENTER,CONCEN, NELION,GAMMAR,GAMMAS,GAMMAW,REF,
     2      NBLO,NBUP,ISO1,X1,ISO2,X2,GFLOG,XJ,XJP,CODE,ELO,GF,GS,GR,GW,
     3        DWL,DGFLOG,DGAMMAR,DGAMMAS,DGAMMAW,DWLISO,ISOSHIFT,EXTRA3
      REAL*8 LINDAT8(14)
      REAL*4 LINDAT4(28)
      EQUIVALENCE (LINDAT8(1),WL),(LINDAT4(1),NELION)
      REAL*8 RESOLU,RATIO,RATIOLG,SIGMA2,WLBEG,WLEND
      REAL*8 WL,E,EP,WLVAC,CENTER,CONCEN,WAVENO
      REAL*8 LABEL,LABELP,OTHER1,OTHER2
      REAL*8 POTION
      CHARACTER*20 NOTES
      CHARACTER*10 COTHER1,COTHER2
      EQUIVALENCE (COTHER1,OTHER1(1)),(COTHER2,OTHER2(1))
      CHARACTER*3 AUTO
      CHARACTER*6 IXFIXFP
      DIMENSION DECKJ(7,kw)
      INTEGER TYPE
      EQUIVALENCE (GAMMAS,ASHORE),(GAMMAW,BSHORE)
      EQUIVALENCE (GF,G,CGF),(TYPE,NLAST),(GAMMAR,XSECT,GAUNT)
C     correction 18 May 2011  plus new version of subroutine ionpots.
      COMMON /POTION/POTION(999)
C     COMMON /POTION/POTION(594)
      DIMENSION CODEX(17)
      DIMENSION DELLIM(7)
      DIMENSION NTENS(10)
      DATA NTENS/1,10,100,1000,10000,100000,1000000,10000000,
     1 100000000,1000000000/
      DATA CODEX/1.,2.,2.01,6.,6.01,12.,12.01,13.,13.01,14.,14.01,
     1 20.,20.01,8.,11.,5.,19./
      DATA DELLIM/100.,30.,10.,3.,1.,.3,.1/
C    ADDED FOLLOWING OPEN STATEMENTS
      OPEN(UNIT=11,FILE='fort.11',STATUS='OLD',READONLY,
     $     FORM='UNFORMATTED',ACCESS='sequential',RECL=243)
      OPEN(UNIT=12,FILE='fort.12',STATUS='OLD',FORM='UNFORMATTED'
     $     ,ACCESS='APPEND')
      OPEN(UNIT=14,FILE='fort.14',STATUS='OLD',FORM='UNFORMATTED'
     $     ,ACCESS='APPEND')
      OPEN(UNIT=19,FILE='fort.19',STATUS='OLD',FORM='UNFORMATTED'
     $     ,ACCESS='APPEND')
      OPEN(UNIT=20,FILE='fort.20',STATUS='OLD',FORM='UNFORMATTED'
     $     ,ACCESS='APPEND')
C
      OPEN(UNIT=93,FILE="fort.93",STATUS='OLD',
     $     FORM='UNFORMATTED',POSITION='REWIND')
      READ(93)NLINES,LENGTH,IFVAC,IFNLTE,N19,TURBV,DECKJ,IFPRED,
     1     WLBEG,WLEND,RESOLU,RATIO,RATIOLG,CUTOFF,LINOUT
      CLOSE(UNIT=93)
C      READ(93)NLINES,LENGTH,IFVAC,IFNLTE,N19,TURBV,DECKJ,IFPRED,
C     1WLBEG,WLEND,RESOLU,RATIO,RATIOLG,CUTOFF,LINOUT
      IXWLBEG=DLOG(WLBEG)/RATIOLG
      IF(DEXP(IXWLBEG*RATIOLG).LT.WLBEG)IXWLBEG=IXWLBEG+1
      DELFACTOR=1.
      IF(WLBEG.GT.500.)DELFACTOR=WLBEG/500.
      N14=0
C      OPEN(UNIT=11,STATUS='OLD',READONLY,SHARED,RECL=201)
C      OPEN(UNIT=12,STATUS='OLD',FORM='UNFORMATTED',ACCESS='APPEND')
C      OPEN(UNIT=14,STATUS='OLD',FORM='UNFORMATTED',ACCESS='APPEND')
C      OPEN(UNIT=19,STATUS='OLD',FORM='UNFORMATTED',ACCESS='APPEND')
C      OPEN(UNIT=20,STATUS='OLD',FORM='UNFORMATTED',ACCESS='APPEND')
      OTHER1(2)=(8H        )
      OTHER2(1)=(8H        )
      OTHER2(2)=(8H        )
      DWL=0.
C
C     DLOGGF=0.
      DGFLOG=0.
C
      DGAMMAR=0.
      DGAMMAS=0.
      DGAMMAW=0.
      DWLISO=0.
C
CXXXXX  GLOBAL FUDGES
C      PRINT *,' XXXX double van der Waals in atoms XXXX'
C      PRINT *, 'XXXX increase strength of C2, DGFLOG=+0.250 XXXX'
C      PRINT *, 'XXXX increase strength of MgH, DGFLOG=+0.140 XXXX'
CXXXXX
      DO 900 ILINE=1,10000000
C
C     201 character record,  last 2 still available
      READ(11,END=145)WL,DWL,GFLOG,DGFLOG,CODE,E,XJ,LABEL,
     1 EP,XJP,LABELP,GR,DGAMMAR,GS,DGAMMAS,GW,DGAMMAW,WAVENO,
     2 REF,NBLO,NBUP,ISO1,X1,ISO2,X2,OTHER1,OTHER2,ISOSHIFT,NELION
      READ(COTHER2,'(A6,I1,A3)')IXFIXFP,LINESIZE,AUTO
C
CXXXXX  GLOBAL FUDGES
C     PRINT *,' XXXX double van der Waals in atoms XXXX'
C     IF(DGAMMAW.EQ.0..AND.CODE.LT.100)DGAMMAW=+0.300
C      IF(DGAMMAW.EQ.0..AND.CODE.LT.100.AND.AUTO.NE.'AUT')DGAMMAW=+0.300
C
C     PRINT *, 'XXXX increase strength of C2, DGFLOG=+0.250 XXXX'
C      IF(CODE.EQ.606.00)DGFLOG=+.250 
C
C     PRINT *, 'XXXX increase strength of MgH, DGFLOG=+0.140 XXXX'
C      IF(CODE.EQ.112.00.AND.DGFLOG.EQ.0.)DGFLOG=+.140 
C     IF(CODE.EQ.112.00.AND.DGFLOG.EQ.0.)DGFLOG=+.100 
CXXXXX
C     OTHER1 IS HYPERFINE SHIFTS
C     IXFIXFP IS HYPERFINE NOTATION
      READ(COTHER1,'(2I5)')ISHIFT,ISHIFTP
C     READ(COTHER2,'(A6,I1,A3)')IXFIXFP,LINESIZE,AUTO
      ESHIFT=ISHIFT*.001
      ESHIFTP=ISHIFTP*.001
c
c     definition of dwliso changed, now in mA and WL aleady includes dwliso
c     DWLISO=-ISOSHIFT*.001*ABS(WL)**2/1.D7   wrong
c     DWLISO=-ISOSHIFT*.0001*ABS(WL)**2/1.D7
c     WLVAC=ABS(WL)+DWL+DWLISO
c     error in isotope shift  28oct09
c     DWLISO=ISOSHIFT*.001
c     1 mA = 0.0001 nm 
      DWLISO=ISOSHIFT*.0001
      WLVAC=ABS(WL)+DWL
      IF(IFVAC.EQ.1.OR.LABELP(1).EQ.8HCONTINUU)WLVAC=
     1 1.D7/DABS(DABS(EP)+ESHIFTP-DABS(E)+ESHIFT)+DWL+DWLISO
      IF(WLVAC.GT.WLEND+DELLIM(1))GO TO 145
      IXWL=DLOG(WLVAC)/RATIOLG+.5D0
      NBUFF=IXWL-IXWLBEG+1
      LIM=MIN(8-LINESIZE,7)
      IF(CODE.EQ.1.)LIM=1
      IF(WLVAC.LT.WLBEG-DELLIM(LIM)*DELFACTOR)GO TO 900
      IF(WLVAC.GT.WLEND+DELLIM(LIM)*DELFACTOR)GO TO 900
C     CORONAL APPROXIMATION LINE
      IF(AUTO.EQ.'COR')GO TO 900
C
C     14NOV13   Stark width GS is sometimes too large for high series members       
      IF(GS.NE.0.)GS=MIN(GS,-3.)
C
C
      GF=10.**(GFLOG+DGFLOG+X1+X2)
      ELO=DMIN1(DABS(E),DABS(EP))
c     11sep05  changed exponentiation style and corrected for negative asymmetry
c     22oct04  changed exponentiation style and corrected for negative asymmetry
C     GAMMAS=ASHORE for autoionizing lines  
C     GAMMAW=BSHORE for autoionizing lines
C      GAMMAR=10.**(GR+DGAMMAR)
C      GAMMAS=10.**(GS+DGAMMAS)
C      GAMMAW=10.**(GW+DGAMMAW)

C     IF ASYMMETRY PARAMETER ASHORE IS NEGATIVE, INPUT GAMMAS IS POSITIVE LOG
      IF(AUTO.EQ.'AUT'.AND.GS.GT.0.)GAMMAS=-10.**(-GS+DGAMMAS)
      IF(GR.EQ.0.)THEN
      GAMMAR=2.223D13/WLVAC**2
      GR=ALOG10(GAMMAR)
      ENDIF
      NELEM=CODE
      ICHARGE=(CODE-FLOAT(NELEM))*100.+.1
      ZEFF=ICHARGE+1
C     NELION=NELEM*6-6+IFIX(ZEFF)
      IF(NELEM.GT.19.AND.NELEM.LT.29.AND.ICHARGE.GT.5)NELION=
     1 6*(NELEM+ICHARGE*10-30)-1
      IF(GS.NE.0.)GO TO 138
      IF(CODE.GE.100.)GO TO 137
      EUP=DMAX1(DABS(E),DABS(EP))
      EFFNSQ=25.
c     bug found by John Lester 18 May 2011
      IZ=CODE
      IF(IZ.LE.30)INDEX=IZ*(IZ+1)/2+ICHARGE
      IF(IZ.GT.30)INDEX=IZ*5+341+ICHARGE
      DELEUP=POTION(INDEX)-EUP
C     DELEUP=POTION(NELION)-EUP
c
      IF(DELEUP.GT.0.)EFFNSQ=109737.31D0*ZEFF**2/DELEUP
      GAMMAS=1.0D-8*EFFNSQ**2*SQRT(EFFNSQ)
      GS=LOG10(GAMMAS)
C
C     14NOV13   Stark width GS is sometimes too large for high series members       
      GS=MIN(GS,-3.)
C
C
      GO TO 138
  137 GAMMAS=1.0D-5
      GS=-5.
  138 IF(GW.NE.0.)GO TO 141
      IF(CODE.GE.100.)GO TO 139
      EUP=DMAX1(DABS(E),DABS(EP))
      EFFNSQ=25.
c     bug found by John Lester 18 May 2011
      IZ=CODE
      IF(IZ.LE.30)INDEX=IZ*(IZ+1)/2+ICHARGE
      IF(IZ.GT.30)INDEX=IZ*5+341+ICHARGE
      DELEUP=POTION(INDEX)-EUP
C     DELEUP=POTION(NELION)-EUP
      IF(DELEUP.GT.0.)EFFNSQ=109737.31D0*ZEFF**2/DELEUP
      EFFNSQ=AMIN1(EFFNSQ,1000.)
      RSQUP=2.5*(EFFNSQ/ZEFF)**2
      DELELO=POTION(INDEX)-ELO
C     DELELO=POTION(NELION)-ELO
      EFFNSQ=109737.31D0*ZEFF**2/DELELO
      EFFNSQ=AMIN1(EFFNSQ,1000.)
      RSQLO=2.5*(EFFNSQ/ZEFF)**2
      NSEQ=CODE-ZEFF+1.
      IF(NSEQ.GT.20.AND.NSEQ.LT.29)THEN
      RSQUP=(45.-FLOAT(NSEQ))/ZEFF
      RSQLO=0.
      ENDIF
      IF(LABELP(1).EQ.8HCONTINUU)RSQLO=0.
      IF(RSQUP.LT.RSQLO)RSQUP=2.*RSQLO
      GAMMAW=4.5D-9*(RSQUP-RSQLO)**.4
      GW=LOG10(GAMMAW)
      GO TO 141
  139 GAMMAW=1.D-7/ZEFF
      GW=LOG10(GAMMAW)
  141 CONTINUE

C    unlog the shifted values
      GAMMAR=10.D0**(GR+DGAMMAR)
      GAMMAS=10.D0**(GS+DGAMMAS)
      GAMMAW=10.D0**(GW+DGAMMAW)

C       WRITE(6,144)WL,GFLOG,CODE,E,XJ,LABEL,EP,XJP,LABELP,GR,GS,GW,REF
C      1 GAMMAR,GAMMAS,GAMMAW,REF,NBLO,NBUP,ISO1,X1,ISO2,X2,OTHER1,OTHER2
  144 FORMAT(F11.4,F7.3,F6.2,F12.3,F5.1,1X,A8,A2,F12.3,F5.1,1X,A8,A2,
     1 F6.2,F6.2,F6.2,A4,I2,I2,I3,F7.3,I3,F7.3,A8,A2,A8,A2)
C     TYPE=-6  3HE II LINE
C     TYPE=-5  4HE I LINE
C     TYPE=-4  3HE I LINE
C     TYPE=-3  4HE I LINE
C     TYPE=-2  DEUTERIUM LINE
C     TYPE=-1  HYDROGEN LINE
C     TYPE=0  NORMAL LINE
C     TYPE=1  AUTOIONIZING LINE
C     TYPE=2  CORONAL APPROXIMATION LINE
C     TYPE=3  PRD LINE
C     TYPE.GT.3 = NLAST  CONTINUUM
      TYPE=0
      IF(CODE.EQ.1.00)TYPE=-1
      IF(CODE.EQ.1.00.AND.ISO1.EQ.2)TYPE=-2      
      IF(CODE.EQ.2.00)TYPE=-3
      IF(CODE.EQ.2.00.AND.ISO1.EQ.3)TYPE=-4      
      IF(CODE.EQ.2.01)TYPE=-6
      IF(CODE.EQ.2.01.AND.ISO1.EQ.3)TYPE=-6      
      IF(AUTO.EQ.'COR')TYPE=2
      IF(AUTO.EQ.'AUT')TYPE=1
      IF(AUTO.EQ.'PRD')TYPE=3
      IF(LABELP(1).EQ.8HCONTINUU)NLAST=XJP
      IF(LABELP(1).EQ.8HCONTINUU)GF=GF*(XJ+XJ+1.)
      NCON=0
      IF(ISO1.EQ.0.AND.ISO2.GT.0)NCON=ISO2
      IF(TYPE.EQ.1)GO TO 17
      IF(TYPE.GT.3)GO TO 17
      FRELIN=2.99792458D17/WLVAC
      CGF=.026538D0/1.77245D0*GF/FRELIN
C     GR IS GAUNT FACTOR FOR CORONAL LINES
      IF(TYPE.EQ.2)GAMMAR=GR
      IF(TYPE.EQ.2)GO TO 1253
      GAMMAR=GAMMAR/12.5664D0/FRELIN
      GAMMAS=GAMMAS/12.5664D0/FRELIN
      GAMMAW=GAMMAW/12.5664D0/FRELIN
   17 NBUP=IABS(NBUP)
      NBLO=IABS(NBLO)
      NELIONX=0
      IF(TYPE.EQ.1)GO TO 1253
      IF(NBLO+NBUP.EQ.0)GO TO 1260
      DO 1250 I=1,17
      IF(CODE.EQ.CODEX(I))GO TO 1252
 1250 CONTINUE
      IF(TYPE.EQ.1)GO TO 1253
      WRITE(6,1251)CODE
 1251 FORMAT(9H BAD CODE,F10.2)
      CALL EXIT
 1252 NELIONX=I
 1253 WRITE(19)WLVAC,ELO,GF,NBLO,NBUP,NELION,TYPE,NCON,NELIONX,
     1GAMMAR,GAMMAS,GAMMAW,NBUFF,LIM
      IF(LINOUT.GE.0)WRITE(20)LINDAT8,LINDAT4
      N19=N19+1
C     WRITE(6,5555)WLVAC,ILINE
 5555 FORMAT(112X,F10.4,I10)
      GO TO 900
C     PLAIN LINE
 1260 WRITE(12)NBUFF,CGF,NELION,ELO,GAMMAR,GAMMAS,GAMMAW
C      PRINT 1261,NBUFF,CGF,NELION,ELO,GAMMAR,GAMMAS,GAMMAW
 1261 FORMAT(I10,1PE12.3,I10,4E12.3)
      IF(LINOUT.GE.0)WRITE(14)LINDAT8,LINDAT4
      N14=N14+1
      NLINES=NLINES+1
  900 CONTINUE
  145 WRITE(6,1118)N14
 1118 FORMAT(I10,' LINES ADDED TO TAPE 14')
      WRITE(6,1120)NLINES
 1120 FORMAT(I10,' LINES TOTAL ON TAPE 12')
      WRITE(6,1119)N19
 1119 FORMAT(I10,' LINES TOTAL ON TAPE 19')
C      IF(LINOUT.LT.0.)GO TO 1125
C      IF(N19.GT.0)THEN
C      REWIND 20
C      DO 1121 I=1,N19
C      READ(20)LINDAT8,LINDAT
C 1121 WRITE(13)LINDAT8,LINDAT
C      ENDIF
C      IF(NLINES.GT.0)THEN
C      REWIND 14
C      DO 1122 I=1,NLINES
C      READ(14)LINDAT8,LINDAT
C 1122 WRITE(13)LINDAT8,LINDAT
C      ENDIF
C 1125 CONTINUE
C      IF(IFNLTE.EQ.1)N19=0
      OPEN(UNIT=93,FILE="fort.93",STATUS='OLD',
     $     FORM='UNFORMATTED',POSITION='REWIND')
      WRITE(93)NLINES,LENGTH,IFVAC,IFNLTE,N19,TURBV,DECKJ,IFPRED,
     1     WLBEG,WLEND,RESOLU,RATIO,RATIOLG,CUTOFF,LINOUT
      CLOSE(UNIT=93)
      WRITE(6,*)"RGFALLDEL OUTPUT UNIT-93: ,NLINES,LENGTH,IFVAC,
     $IFNLTE,N19,IFPRED,WLBEG,WLEND,RESOLU,RATIO,RATIOLG,
     $CUTOFF,LINOUT"
      WRITE(6,*)NLINES,LENGTH,IFVAC,IFNLTE,N19,
     $     IFPRED,WLBEG,WLEND,RESOLU,RATIO,RATIOLG,
     $     CUTOFF,LINOUT
C      REWIND 93
C      WRITE(93)NLINES,LENGTH,IFVAC,IFNLTE,N19,TURBV,DECKJ,IFPRED,
C     1WLBEG,WLEND,RESOLU,RATIO,RATIOLG,CUTOFF,LINOUT
      CALL EXIT
      END
      SUBROUTINE IONPOTS
C
C     Kramida, A., Ralchenko, Yu., Reader, J., and NIST ASD Team (2014).
C     NIST Atomic Spectra Database (ver. 5.2).  physics.nist.gov/asd
C     2014, November 4.
C
      IMPLICIT REAL*8 (A-H,O-Z)
      COMMON /POTION/POTION(999)
      DIMENSION POTH ( 2),POTHe( 3),POTLi( 4),POTBe( 5),POTB ( 6)
      DIMENSION POTC ( 7),POTN ( 8),POTO ( 9),POTF( 10),POTNe(11)
      DIMENSION POTNa(12),POTMg(13),POTAl(14),POTSi(15),POTP (16)
      DIMENSION POTS (17),POTCl(18),POTAr(19),POTK (20),POTCa(21)
      DIMENSION POTSc(22),POTTi(23),POTV (24),POTCr(25),POTMn(26)
      DIMENSION POTFe(27),POTCo(28),POTNi(29),POTCu(30),POTZn(31)
      DIMENSION POTGa(5),POTGe(5),POTAs(5),POTSe(5),POTBr(5)
      DIMENSION POTKr(5),POTRb(5),POTSr(5),POTY (5),POTZr(5)
      DIMENSION POTNb(5),POTMo(5),POTTc(5),POTRu(5),POTRh(5)
      DIMENSION POTPd(5),POTAg(5),POTCd(5),POTIn(5),POTSn(5)
      DIMENSION POTSb(5),POTTe(5),POTI (5),POTXe(5),POTCs(5)
      DIMENSION POTBa(5),POTLa(5),POTCe(5),POTPr(5),POTNd(5)
      DIMENSION POTPm(5),POTSm(5),POTEu(5),POTGd(5),POTTb(5)
      DIMENSION POTDy(5),POTHo(5),POTEr(5),POTTm(5),POTYb(5)
      DIMENSION POTLu(5),POTHf(5),POTTa(5),POTW (5),POTRe(5)
      DIMENSION POTOs(5),POTIr(5),POTPt(5),POTAu(5),POTHg(5)
      DIMENSION POTTl(5),POTPb(5),POTBi(5),POTPo(5),POTAt(5)
      DIMENSION POTRn(5),POTFr(5),POTRa(5),POTAc(5),POTTh(5)
      DIMENSION POTPa(5),POTU (5),POTNp(5),POTPu(5),POTAm(5)
      DIMENSION POTCm(5),POTBk(5),POTCf(5),POTEs(5)
      EQUIVALENCE (POTION(  1),POTH (1))
      EQUIVALENCE (POTION(  3),POTHe(1))
      EQUIVALENCE (POTION(  6),POTLi(1))
      EQUIVALENCE (POTION( 10),POTBe(1))
      EQUIVALENCE (POTION( 15),POTB (1))
      EQUIVALENCE (POTION( 21),POTC (1))
      EQUIVALENCE (POTION( 28),POTN (1))
      EQUIVALENCE (POTION( 36),POTO (1))
      EQUIVALENCE (POTION( 45),POTF (1))
      EQUIVALENCE (POTION( 55),POTNe(1))
      EQUIVALENCE (POTION( 66),POTNa(1))
      EQUIVALENCE (POTION( 78),POTMg(1))
      EQUIVALENCE (POTION( 91),POTAl(1))
      EQUIVALENCE (POTION(105),POTSi(1))
      EQUIVALENCE (POTION(120),POTP (1))
      EQUIVALENCE (POTION(136),POTS (1))
      EQUIVALENCE (POTION(153),POTCl(1))
      EQUIVALENCE (POTION(171),POTAr(1))
      EQUIVALENCE (POTION(190),POTK (1))
      EQUIVALENCE (POTION(210),POTCa(1))
      EQUIVALENCE (POTION(231),POTSc(1))
      EQUIVALENCE (POTION(253),POTTi(1))
      EQUIVALENCE (POTION(276),POTV (1))
      EQUIVALENCE (POTION(300),POTCr(1))
      EQUIVALENCE (POTION(325),POTMn(1))
      EQUIVALENCE (POTION(351),POTFe(1))
      EQUIVALENCE (POTION(378),POTCo(1))
      EQUIVALENCE (POTION(406),POTNi(1))
      EQUIVALENCE (POTION(435),POTCu(1))
      EQUIVALENCE (POTION(465),POTZn(1))
      EQUIVALENCE (POTION(496),POTGa(1))
      EQUIVALENCE (POTION(501),POTGe(1))
      EQUIVALENCE (POTION(506),POTAs(1))
      EQUIVALENCE (POTION(511),POTSe(1))
      EQUIVALENCE (POTION(516),POTBr(1))
      EQUIVALENCE (POTION(521),POTKr(1))
      EQUIVALENCE (POTION(526),POTRb(1))
      EQUIVALENCE (POTION(531),POTSr(1))
      EQUIVALENCE (POTION(536),POTY (1))
      EQUIVALENCE (POTION(541),POTZr(1))
      EQUIVALENCE (POTION(546),POTNb(1))
      EQUIVALENCE (POTION(551),POTMo(1))
      EQUIVALENCE (POTION(556),POTTc(1))
      EQUIVALENCE (POTION(561),POTRu(1))
      EQUIVALENCE (POTION(566),POTRh(1))
      EQUIVALENCE (POTION(571),POTPd(1))
      EQUIVALENCE (POTION(576),POTAg(1))
      EQUIVALENCE (POTION(581),POTCd(1))
      EQUIVALENCE (POTION(586),POTIn(1))
      EQUIVALENCE (POTION(591),POTSn(1))
      EQUIVALENCE (POTION(596),POTSb(1))
      EQUIVALENCE (POTION(601),POTTe(1))
      EQUIVALENCE (POTION(606),POTI (1))
      EQUIVALENCE (POTION(611),POTXe(1))
      EQUIVALENCE (POTION(616),POTCs(1))
      EQUIVALENCE (POTION(621),POTBa(1))
      EQUIVALENCE (POTION(626),POTLa(1))
      EQUIVALENCE (POTION(631),POTCe(1))
      EQUIVALENCE (POTION(636),POTPr(1))
      EQUIVALENCE (POTION(641),POTNd(1))
      EQUIVALENCE (POTION(646),POTPm(1))
      EQUIVALENCE (POTION(651),POTSm(1))
      EQUIVALENCE (POTION(656),POTEu(1))
      EQUIVALENCE (POTION(661),POTGd(1))
      EQUIVALENCE (POTION(666),POTTb(1))
      EQUIVALENCE (POTION(671),POTDy(1))
      EQUIVALENCE (POTION(676),POTHo(1))
      EQUIVALENCE (POTION(681),POTEr(1))
      EQUIVALENCE (POTION(686),POTTm(1))
      EQUIVALENCE (POTION(691),POTYb(1))
      EQUIVALENCE (POTION(696),POTLu(1))
      EQUIVALENCE (POTION(701),POTHf(1))
      EQUIVALENCE (POTION(706),POTTa(1))
      EQUIVALENCE (POTION(711),POTW (1))
      EQUIVALENCE (POTION(716),POTRe(1))
      EQUIVALENCE (POTION(721),POTOs(1))
      EQUIVALENCE (POTION(726),POTIr(1))
      EQUIVALENCE (POTION(731),POTPt(1))
      EQUIVALENCE (POTION(736),POTAu(1))
      EQUIVALENCE (POTION(741),POTHg(1))
      EQUIVALENCE (POTION(746),POTTl(1))
      EQUIVALENCE (POTION(751),POTPb(1))
      EQUIVALENCE (POTION(756),POTBi(1))
      EQUIVALENCE (POTION(761),POTPo(1))
      EQUIVALENCE (POTION(766),POTAt(1))
      EQUIVALENCE (POTION(771),POTRn(1))
      EQUIVALENCE (POTION(776),POTFr(1))
      EQUIVALENCE (POTION(781),POTRa(1))
      EQUIVALENCE (POTION(786),POTAc(1))
      EQUIVALENCE (POTION(791),POTTh(1))
      EQUIVALENCE (POTION(796),POTPa(1))
      EQUIVALENCE (POTION(801),POTU (1))
      EQUIVALENCE (POTION(806),POTNp(1))
      EQUIVALENCE (POTION(811),POTPu(1))
      EQUIVALENCE (POTION(816),POTAm(1))
      EQUIVALENCE (POTION(821),POTCm(1))
      EQUIVALENCE (POTION(826),POTBk(1))
      EQUIVALENCE (POTION(831),POTCf(1))
      EQUIVALENCE (POTION(836),POTEs(1))
      DATA POTH / 109678.772D0,0./
      DATA POTHe/ 198310.666D0, 438908.879D0,0./
      DATA POTLi/  43487.114D0, 610078.526D0, 987661.014D0,0./
      DATA POTBe/  75192.640D0, 146882.86D0,1241256.600D0, 
     1            1756018.822D0, 0./
      DATA POTB /66928.040D0,202887.40D0,305930.80D0,2091972.D0,
     1            2744107.936D0, 0./
      DATA POTC /90820.42D0,196674.D0,386241.0D0,520175.8D0,
     1             3162423.30D0,3952061.670D0, 0./
      DATA POTN / 117225.70D0,238750.20D0,382672.D0,624866.D0,
     1             789537.D0,4452723.30D0,5380089.80D0, 0./
      DATA POTO / 109837.02D0,283270.90D0,443085.0D0,624382.0D0,
     1              918657.D0,1114004.D0,5963073.00D0,7028394.70D0, 0./
      DATA POTF / 140524.50D0,282058.6D0,505774.0D0,703110.D0,921480.D0,
     1             1267606.0D0,1493632.D0,7693706.60D0,8897242.50D0, 0./
      DATA POTNe/173929.750D0,330388.60D0,511544.D0,783890.D0,
     1          1018250.D0,1273820.D0,1671750.D0,1928447.D0,9644840.7D0,
     2           10986877.20D0,0./
      DATA POTNa/ 41449.451D0,381390.2D0,577654.D0,797970.D0,1116300.D0,
     1             1389100.D0,1681700.D0,   2130850.D0,  2418500.D0,
     2          11817106.70D0,13297680.0D0,0./
      DATA POTMg/61671.050D0,121267.61D0,646402.D0,881285.D0,1139900.D0,
     1            1506300.D0, 1814900.D0, 2144820.D0, 2645400.D0, 
     2            2964000.D0,14209914.7D0, 15829950.D0, 0./
      DATA POTAl/48278.48D0,151862.50D0,229445.70D0,967804.D0,
     1           1240684.D0,1536400.D0, 1949900.D0, 2295800.D0, 
     2           2663300.D0, 3215300.D0,3565010.D0, 16824539.3D0, 
     3         18584143.0D0, 0./
      DATA POTSi/65747.76D0,131838.14D0,270139.30D0,364093.10D0,
     1           1345070.D0,1655590.D0, 1986700.D0, 2449200.D0, 
     2           2831800.D0, 3237400.D0,3840600.D0, 4221630.D0, 
     3          19661038.9D0, 21560631.0D0, 0./
      DATA POTP /  84580.83D0,159451.70D0,243600.70D0,414922.8D0, 
     1             524462.9D0,1777890.D0, 2125800.D0, 2497100.D0, 
     2             3002900.D0, 3423000.D0,3867000.D0, 4521700.D0, 
     3             4934020.D0, 22719901.6D0,24759942.D0,0./
      DATA POTS /  83559.1D0,188232.7D0,281100.D0,380870.D0,585514.D0,
     1      710195.D0, 2266050.D0, 2651900.D0, 3063600.D0, 3611300.D0,
     2     4069500.D0, 4552200.D0, 5258400.D0, 5702290.D0,26001545.1D0,
     3    28182526.D0, 0./
      DATA POTCl/ 104591.00D0,192070.0D0,321000.D0,429400.D0,545800.D0,
     1       781900.D0, 921096.D0, 2809280.D0, 3233080.D0, 3683000.D0,
     2     4274000.D0, 4771400.D0, 5293400.D0, 6051000.D0, 6526620.D0,
     3    29506532.5D0, 31828983.D0, 0./
      DATA POTAr/ 127109.842D0,222848.3D0,328550.D0,480600.D0,603700.D0,
     1      736300.D0, 1003400.D0, 1157056.D0, 3408500.D0, 3869500.D0,
     2     4359000.D0, 4992000.D0, 5528700.D0, 6090500.D0, 6899800.D0,
     3     7407190.D0, 33235410.D0, 35699895.D0, 0./
      DATA POTK / 35009.814D0,255072.8D0,369427.D0,491330.D0,666700.D0,
     1       802000.D0, 948200.D0, 1249100.D0, 1418063.D0, 4062400.D0,
     2     4562000.D0, 5090000.D0, 5764000.D0, 6342000.D0, 6943800.D0,
     3     7805000.D0, 8344140.D0, 37189176.0D0,39795784.D0, 0./
      DATA POTCa/ 49305.924D0,95751.870D0,410642.3D0,542595.D0,
     1      680200.D0,877400.D0, 1026000.D0, 1187600.D0, 1520600.D0, 
     2     1704050.D0,4771600.D0, 5309000.D0, 5877000.D0, 6591000.D0, 
     3     7210000.D0,7853000.D0, 8766000.D0, 9337690.D0,41367028.D0,
     4     44117409.D0,0./
      DATA POTSc/52922.00D0,103237.1D0,199677.37D0,592732.D0,741600.D0,
     1       892700.D0, 1113000.D0, 1275000.D0, 1452000.D0, 1816200.D0,
     2      2014760.D0, 5543900.D0, 6111000.D0, 6720000.D0, 7473000.D0,
     3      8135000.D0, 8820000.D0, 9784000.D0,10388070.D0,45771185.D0,
     4     48665510.D0, 0./
      DATA POTTi/  55072.50D0,109494.D0,221735.6D0,348973.3D0,800900.D0,
     1        964100.D0, 1134700.D0, 1375000.D0, 1549000.D0,1741500.D0,
     2       2137900.D0, 2351110.D0, 6353000.D0, 6969000.D0,7618000.D0,
     3      8408000.D0, 9116000.D0, 9842000.D0,10859000.D0,11495470.D0,
     4     50401766.D0, 53440740.D0, 0./
      DATA POTV / 54411.67D0,117900.D0, 236410.D0, 376730.D0,526532.0D0,
     1     1033400.D0, 1215700.D0,  1399800.D0, 1661000.D0, 1859000.D0,
     2     2055000.D0, 2488200.D0,  2712230.D0, 7227000.D0, 7882000.D0,
     3     8573000.D0, 9398000.D0, 10153000.D0,10922000.D0,11991000.D0,
     4    12660130.D0, 55259549.D0, 58443920.D0, 0./
      DATA POTCr/  54575.6D0,132971.02D0,249700.D0, 396500.D0,560200.D0,
     1        731020.D0,1292800.D0, 1490200.D0, 1690100.D0, 1972000.D0,
     2       2184000.D0,2393000.D0, 2860500.D0, 3098480.D0, 8159000.D0,
     3       8850000.D0,9582000.D0,10443000.D0,11247000.D0,12059000.D0,
     4      13180000.D0,13882280.D0, 60345293.D0,63675850.D0, 0./
      DATA POTMn/  59959.4D0,126145.00D0,271550.D0,413000.D0, 584000.D0,
     1        771100.D0, 961440.D0, 1577000.D0, 1789600.D0, 2005400.D0,
     2      2308000.D0, 2536000.D0, 2771000.D0, 3250000.D0, 3509900.D0,
     3     9144000.D0, 9873000.D0, 10649000.D0,11541000.D0,12398000.D0,
     4    13253000.D0,14427000.D0, 15162200.D0,65659877.D0,69137430.D0,
     5    0./
      DATA POTFe/ 63737.704D0,130655.40D0,247220.D0,442900.D0,604900.D0,
     1       798370.D0, 1008000.D0, 1218380.D0, 1884000.D0, 2114000.D0,
     2      2346000.D0, 2668000.D0, 2912000.D0, 3163000.D0, 3680000.D0,
     3      3946570.D0,10184000.D0,10951000.D0,11770000.D0,12708000.D0,
     4     13607000.D0,14505000.D0,15731000.D0,16500160.D0,71204137.D0,
     5     74829550.D0, 0./
      DATA POTCo/  63564.6D0,137795.D0, 270200.D0, 413500.D0, 641200.D0,
     1       822700.D0, 1040000.D0, 1273000.D0, 1501300.D0, 2221000.D0,
     2      2462600.D0, 2711000.D0, 3053000.D0, 3307000.D0, 3558000.D0,
     3      4129200.D0, 4408530.D0,11269000.D0,12135000.D0,12950000.D0,
     4     13900000.D0,14873000.D0,15815000.D0,17094000.D0,17896440.D0,
     5     76979030.D0,80753210.D0, 0./
      DATA POTNi/ 61619.77D0,146541.56D0,283800.D0,443000.D0,613500.D0,
     1           871000.D0,1065000.D0,1307000.D0,1558000.D0,1812000.D0,
     2          2577000.D0,2836100.D0,3102000.D0,3463000.D0,3732000.D0,
     3        3995000.D0,4606000.D0,4895950.D0,12429000.D0,13274000.D0,
     4   14180000.D0, 15170000.D0, 16196000.D0,1718300.D0,18515000.D0,
     5        19351330.D0, 82985464.D0, 86909350.D0, 0./
      DATA POTCu/ 62317.460D0,163669.20D0,297140.D0,462800.D0,644000.D0,
     1           831000.D0,1121000.D0,1339000.D0,1597000.D0,1873000.D0,
     2          2140000.D0,2960000.D0,3234000.D0,3517000.D0,3897000.D0,
     3         4184000.D0,4458000.D0,5101000.D0,5408820.D0,13635000.D0,
     4     14518000.D0,15470000.D0,16480000.D0,17578000.D0,18610000.D0,
     5     19995000.D0,20865190.D0,89224526.D0,93299090.D0, 0./
      DATA POTZn/75769.328D0,144892.6D0,320390.0D0,480490.D0,666000.D0,
     1            871000.D0,1080000.D0,1403000.D0,1637000.D0,1920000.D0,
     2           2213000.D0,2507000.D0,3368000.D0,3657000.D0,3957000.D0,
     3           4355000.D0,4660000.D0,4946000.D0,5626000.D0,5947260.D0,
     4      14896000.D0,15820000.D0,16820000.D0,17860000.D0,19019000.D0,
     5      20095000.D0,21534000.D0,22438310.D0,95697194.D0,99923450.D0,
     6             0./
      DATA POTGa/ 48387.634D0,165465.8D0,247820.0D0,510070.D0,693700.D0/
      DATA POTGe/ 63713.24D0, 128521.30D0,274693.D0,368720.D0,729930.D0/
      DATA POTAs/ 78950.0D0, 149932.D0, 228650.D0, 404500.D0, 506200.D0/
      DATA POTSe/ 78658.35D0,170960.D0, 255650.D0, 346390.D0, 550900.D0/
      DATA POTBr/ 95284.80D0,174140.D0, 282000.D0, 385400.D0, 480670.D0/
      DATA POTKr/112914.433D0,196475.4D0,287700.D0, 410100.D0,521800.D0/
      DATA POTRb/ 33690.81D0,220105.00D0,316550.D0, 421000.D0,552000.D0/
      DATA POTSr/45932.204D0,88965.180D0,345879.0D0,453930.D0,570000.D0/
      DATA POTY / 50145.60D0,  98590.D0,165540.5D0, 488830.D0,604700.D0/
      DATA POTZr/ 53506.00D0,105900.D0, 186880.D0,277602.80D0,648050.D0/
      DATA POTNb/ 54513.80D0,115500.D0, 202000.D0, 303350.D0, 407897.D0/
      DATA POTMo/ 57204.30D0,130300.D0, 218800.D0, 325300.D0, 439450.D0/
      DATA POTTc/ 57421.68D0,123100.D0, 238300.D0, 331000.D0, 460000.D0/
      DATA POTRu/ 59366.40D0,135200.D0, 229600.D0, 363000.D0, 476000.D0/
      DATA POTRh/ 60160.10D0,145800.D0, 250500.D0, 339000.D0, 508000.D0/
      DATA POTPd/ 67241.30D0,156700.D0, 265600.D0, 371000.D0, 492000.D0/
      DATA POTAg/ 61106.45D0,173283.D0, 280900.D0, 395000.D0, 524000.D0/
      DATA POTCd/ 72540.07D0,136374.74D0,302200.D0,411000.D0, 548000.D0/
      DATA POTIn/46670.104D0,152200.10D0,226191.3D0,447200.D0,559000.D0/
      DATA POTSn/ 59232.69D0,118017.0D0,246020.0D0,328600.D0, 621300.D0/
      DATA POTSb/ 69431.34D0, 134100.D0,204248.D0, 353300.D0, 443600.D0/
      DATA POTTe/ 72667.80D0, 150000.D0,224500.D0, 301776.D0, 478000.D0/
      DATA POTI / 84295.10D0,154304.0D0,238500.D0, 325500.D0, 415500.D0/
      DATA POTXe/ 97833.787D0,169180.D0,250400.D0, 340400.D0, 437000.D0/
      DATA POTCs/ 31406.468D0,186777.40D0,267740.D0,347000.D0,452000.D0/
      DATA POTBa/ 42034.91D0,80686.30D0,289100.D0, 379000.D0, 468000.D0/
      DATA POTLa/ 44981.D0,  90212.50D0, 154675.D0,402900.D0, 497000.D0/
      DATA POTCe/ 44672.D0,  87500.D0,  162903.D0, 297670.D0, 528700.D0/
      DATA POTPr/ 44140.D0,  85100.D0,  174407.D0, 314400.D0, 464000.D0/
      DATA POTNd/ 44562.D0,  86500.D0,  178600.D0, 326000.D0, 483900.D0/
      DATA POTPm/ 45020.D0,  87900.D0,  180000.D0, 331000.D0, 498000.D0/
      DATA POTSm/ 45519.6D0,  89300.D0, 189000.D0, 334000.D0, 505000.D0/
      DATA POTEu/ 45734.740D0,90660.D0, 201000.D0, 344000.D0, 510000.D0/
      DATA POTGd/ 49601.45D0, 97500.D0, 166400.D0, 355000.D0, 522000.D0/
      DATA POTTb/ 47295.D0,   92900.D0, 176700.D0, 317500.D0, 536000.D0/
      DATA POTDy/ 47901.70D0, 94100.D0, 185000.D0, 334000.D0, 501000.D0/
      DATA POTHo/ 48567.D0,   95200.D0, 184200.D0, 343000.D0, 516000.D0/
      DATA POTEr/ 49262.D0,   96200.D0, 183400.D0, 344000.D0, 525000.D0/
      DATA POTTm/ 49879.80D0, 97200.D0, 191000.D0, 344000.D0, 528000.D0/
      DATA POTYb/ 50443.20D0,98231.75D0,202070.D0, 351300.D0, 529000.D0/
      DATA POTLu/ 43762.60D0,112000.D0, 169010.D0, 364960.D0, 539000.D0/
      DATA POTHf/ 55047.90D0,120000.D0, 188000.D0, 269150.D0, 551500.D0/
      DATA POTTa/ 60891.40D0,131000.D0, 186000.D0, 282000.D0, 389340.D0/
      DATA POTW / 63427.70D0,132000.D0, 210000.D0, 308000.D0, 416000.D0/
      DATA POTRe/ 63181.60D0,134000.D0, 218000.D0, 315000.D0, 419000.D0/
      DATA POTOs/ 68058.9D0, 137000.D0, 202000.D0, 331000.D0, 444000.D0/
      DATA POTIr/ 72323.9D0, 137100.D0, 226000.D0, 323000.D0, 460000.D0/
      DATA POTPt/ 72257.80D0,149700.D0, 234000.D0, 347000.D0, 452000.D0/
      DATA POTAu/ 74409.11D0,162950.D0, 242000.D0, 363000.D0, 484000.D0/
      DATA POTHg/ 84184.150D0,151284.40D0,277900.D0,391600.D0,493600.D0/
      DATA POTTl/ 49266.660D0,164765.D0, 240773.D0, 412500.D0,505000.D0/
      DATA POTPb/59819.558D0,121245.28D0,257592.D0,341435.1D0,555000.D0/
      DATA POTBi/ 58761.650D0,134720.D0, 206180.D0, 365900.D0,442400.D0/
      DATA POTPo/ 67860.D0,  156000.D0, 220000.D0, 290000.D0, 460000.D0/
      DATA POTAt/ 75150.80D0,144210.D0, 214400.D0, 319800.D0, 406400.D0/
      DATA POTRn/ 86692.5D0, 173000.D0, 237000.D0, 298000.D0, 427000.D0/
      DATA POTFr/ 32848.872D0,181000.D0,270000.D0, 315000.D0, 403000.D0/
      DATA POTRa/ 42573.36D0,81842.31D0,250000.D0, 331000.D0, 427000.D0/
      DATA POTAc/ 43394.45D0, 94800.D0, 140590.D0, 361000.D0, 444000.D0/
      DATA POTTh/ 50867.0D0,  96000.D0, 147800.D0, 231060.D0, 468000.D0/
      DATA POTPa/ 47500.D0,   96000.D0, 150000.D0, 249000.D0, 357000.D0/
      DATA POTU / 49958.40D0, 94000.D0, 159700.D0, 296000.D0, 371000.D0/
      DATA POTNp/ 50535.0D0,  93000.D0, 159000.D0, 273000.D0, 387000.D0/
      DATA POTPu/ 48601.0D0,  93000.D0, 170000.D0, 282000.D0, 395000.D0/
      DATA POTAm/ 48182.0D0,  94000.D0, 175000.D0, 297000.D0, 403000.D0/
      DATA POTCm/ 48324.0D0, 100000.D0, 162000.D0, 304000.D0, 411000.D0/
      DATA POTBk/ 49989.0D0,  96000.D0, 174000.D0, 290000.D0, 452000.D0/
      DATA POTCf/ 50665.0D0,  97000.D0, 181000.D0, 304000.D0, 419000.D0/
      DATA POTEs/ 51358.0D0,  98000.D0, 183000.D0, 313000.D0, 436000.D0/
      RETURN
      END