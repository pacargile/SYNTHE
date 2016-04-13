      PROGRAM SYNTOASCang
C ************************************************************************
C
C     Linux port by L. Sbordone, P. Bonifacio and F. Castelli
C
C     -------------------------------------------------------
C
C     - March 2004: Initial Linux port by L.S. and P.B.
C
C     -------------------------------------------------------
C
C     Please aknowledge the use of this code by citing:
C
C     * Kurucz, R. 1993, ATLAS9 Stellar Atmosphere Programs and 2 km/s
C       grid. Kurucz CD-ROM No. 13. Cambridge, Mass.: Smithsonian Astrophysical
C       Observatory, 1993., 13
C
C     * Sbordone, L., Bonifacio, P., Castelli, F., & Kurucz, R. L. 2004a, Memorie
C       della Societa Astronomica Italiana Supplement, 5, 93
C
C     --------------------------------------------------------
C
C     For updates, documentation, utilities and needed files please refer to:
C     www.******.it
C
C ************************************************************************ 
c     implicit     REAL*8 (A-H,O-Z)
C                 
C
C@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
C
C	DERIVED FROM SYNTOASC
C	PURPOSE: WRITE A SYNTHETIC SPECTRUM AND LINE DATA INTO TWO
C       SEPARATE FILES  
C
C		P. BONIFACIO
C
C
C
C	LIKE SYNTOASC BUT OUTPUT WAVELENGTHS ARE IN ANGSTROEMS
C
C
C	MARCH 1993
C
C@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
C
C     TAPE1=SPECTRUM INPUT
C     TAPE2=SPECTRUM OUTPUT IN ASCII 
C     TAPE3=LINE DATA
C     TAPE4=HEADER FILE FOR TEFF,GLOG ETC.
C     TAPE6=OUTPU
C********
C revision for IFC 8.0, 23012004 LS
c      use ifport
C *******
      COMMON /LINDAT/WL,E,EP,LABEL(2),LABELP(2),OTHER1(2),OTHER2(2),
     1        WLVAC,CENTER,CONCEN, NELION,GAMMAR,GAMMAS,GAMMAW,REF,
     2      NBLO,NBUP,ISO1,X1,ISO2,X2,GFLOG,XJ,XJP,CODE,ELO,GF,GS,GR,GW,
     3        DWL,DGFLOG,DGAMMAR,DGAMMAS,DGAMMAW,EXTRA1,EXTRA2,EXTRA3
      REAL*8 WL,E,EP,WLVAC,CENTER,CONCEN
      REAL*8 LABEL,LABELP,OTHER1,OTHER2,LINDAT
      INTEGER NEDGE
      DIMENSION LINDAT(24)
      EQUIVALENCE (LINDAT(1),WL)
      DIMENSION XMU(20),QMU(40),WLEDGE(200),TITLE(74)
      REAL*8 TEFF,GLOG,TITLE,WBEGIN,RESOLU,XMU,WLEDGE,RATIO
      REAL*8 QMU
      double precision WAVE,wend,wcen,vstep,resid
      DIMENSION APLOT(101)
      DATA APLOT/101*1H  /
C
      linout=100000
C
      REWIND 1
      READ(1)TEFF,GLOG,TITLE,WBEGIN,RESOLU,NWL,IFSURF,NMU,XMU,NEDGE,
     1WLEDGE
      WRITE(4,2233)TEFF,GLOG,TITLE,WBEGIN,RESOLU,NWL,IFSURF,NMU,XMU
     &,NEDGE,WLEDGE
2233	FORMAT(F10.1,F10.3/6HTITLE ,74A1/F10.3,F10.1,I10,I5,I5/
     1 10F8.4/10F8.4/I10/(5F16.5))
      WRITE(6,1010)TEFF,GLOG,TITLE
 1010 FORMAT(  5H TEFF,F7.0,7H   GRAV,F7.3/7H TITLE ,74A1)
      WRITE(6,1007)NMU,(XMU(IMU),IMU=1,NMU)
 1007 FORMAT(I4,20F6.3)
C     FOR FLUX SPECTRA NMU IS 1
      IF(IFSURF.EQ.3) NMU=1
      RATIO=1.+1./RESOLU
      WEND=WBEGIN*RATIO**(NWL-1)
      WCEN=(WBEGIN+WEND)*.5
      VSTEP=2.997925E5/RESOLU
      WRITE(6,1005)WBEGIN,WEND,RESOLU,VSTEP
 1005 FORMAT(2F12.5,F12.1,F12.5)
      NMU1=NMU+1
      NMU2=NMU+NMU
      DO 70 IWL=1,NWL
      READ(1)(QMU(IMU),IMU=1,NMU2)
      IWLNMU=(IWL+9999)*NMU
C      IF(IWL.GT.LINOUT)GO TO 63                                                 
      WAVE=WBEGIN*RATIO**(IWL-1)                                             
      RESID=QMU(1)/QMU(NMU1)                                                    
      IRESID=RESID*1000.+.5                                                     
      WRITE(6,2300)IWL,WAVE,IRESID,APLOT                                             
 2300 FORMAT(1H ,I7,F11.4,I7,101A1)
c
c	convert wavelengths to angstroms
	wave=wave*10
	write(2,2301)wave,QMU(1),QMU(NMU1)
2301	format(f11.4,2E15.6)
C
   63 CONTINUE                                                                  
   70 CONTINUE
C      READ(1)NLINES
C      WRITE(4,2244)NLINES
C2244	FORMAT(1X,'NLINES= ',I10)
C      DO 9 I=1,NLINES
C      READ(1)LINDAT
C      resid=center/concen
C      WRITE(3,8)WL,GFLOG,XJ,E,XJP,EP,CODE,REF,resid
C    8 FORMAT(F10.4,F7.3,F5.1,F12.3,F5.1,F12.3,F9.2,2x,A4,1x,f8.4)
C    9 CONTINUE
      CALL EXIT
      END
