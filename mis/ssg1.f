      SUBROUTINE SSG1        
C        
      INTEGER         PG,SLT,BGPDT,CSTM,SIL,ECPT,MPT,GPTT,EDT,CASECC,   
     1                CORE(166),SYSBUF,IWORD(4),MCB(7),SUBNAM(2)        
      DIMENSION       PG(7),ILIST(360),ARY(1),DEFML(2),IDEFML(2),       
     1                IARY(1),GVECT(1080)        
      CHARACTER       UFM*23        
      COMMON /XMSSG / UFM        
      COMMON /LOADX / LC,SLT,BGPDT,OLD,CSTM,SIL,ISIL,ECPT,MPT,GPTT,EDT, 
     1                N(3),LODC,MASS,NOBLD,IDIT,DUM6(6)        
      COMMON /BLANK / NROWSP,LOADNN        
      COMMON /SYSTEM/ SYSBUF,IOTPE,DUM53(53),ITHERM        
      COMMON /LOADS / NLOAD,IPTR        
CZZ   COMMON /ZZSSA1/ ICORE(1)        
      COMMON /ZZZZZZ/ ICORE(1)        
      EQUIVALENCE     (CORE(1),ICORE(1),IARY(1),ARY(1)),        
     1                (DEFML(1),IDEFML(1))        
      DATA    IWORD / 4,6,7,162/        
      DATA    SUBNAM/ 4HSSG1,4H    /        
C        
C     MODIFY OPEN CORE POINTER IPTR FOR MAGNETICS PROBLEM        
C        
      IPTR  = MAX0(NROWSP,166)        
      MCB(1)= 105        
      CALL RDTRL (MCB(1))        
      IF (MCB(1) .GT. 0) IPTR = MAX0(3*NROWSP,3*MCB(2),166)        
C        
C     INITIALIZE.        
C        
      LC    = KORSZ(ICORE(1))        
      NLLST = LC - 2*SYSBUF        
      SLT   = 101        
      BGPDT = 102        
      CSTM  = 103        
      SIL   = 104        
      ECPT  = 105        
      MPT   = 106        
      GPTT  = 107        
      EDT   = 108        
      MASS  = 109        
      CASECC= 110        
      IDIT  = 111        
      LODC  = 201        
C             205 = NEWSLT (THERMAL)        
      PG(1) = 301        
      ICR2  = 302        
      ICR3  = 303        
      DO 10 I = 2,7        
   10 PG(I) = 0        
      PG(3) = NROWSP        
      PG(4) = 2        
      PG(5) = 1        
C        
C     AVOID CALCULATING UNUSED LOADS        
C        
C     NEDT  = NUMBER OF ELEMENT  DEFORMATIONS        
C     NTEMP = NUMBER OF THERMAL LOADS        
C     NCENT = NUMBER OF CENTRIFUGAL LOADS        
C        
      CALL SSG1A (N1,ILIST(1),NEDT,NTEMP,NCENT,CASECC,IHARM)        
      N1A = N1 + 1        
      LC  = LC - SYSBUF        
      CALL OPEN (*310,PG(1),ICORE(LC+1),1)        
      CALL WRITE (PG(1),PG(1),2,1)        
      NGRAV = 0        
      NEX   = N1 + NTEMP + NEDT + NCENT        
      IF (N1 .EQ. 0) GO TO 21        
C        
C     MODIFY SLT -QVOL-, -QBDY1-, -QBDY2-, AND -QVECT- CARDS.        
C        
      NEWSLT = ICR3        
      IF (ITHERM .NE. 0) NEWSLT = 205        
      ISLT = SLT        
      CALL SSGSLT (SLT,NEWSLT,ECPT)        
      SLT = NEWSLT        
      CALL EXTERN (NEX,NGRAV,GVECT(1),ILIST(1),PG(1),N1,IHARM)        
C        
C     RESET -SLT- TO ORIGINAL SLT DATA BLOCK        
C        
      SLT = ISLT        
      N1  = N1 - NGRAV        
   21 IF (NTEMP) 30,40,30        
   30 CALL TEMPL (NTEMP,ILIST(N1+1),PG(1))        
      N1 = N1 + NTEMP        
   40 IF (NEDT) 50,60,50        
   50 CALL EDTL (NEDT,ILIST(N1+1),PG(1))        
      N1 = N1 + NEDT        
   60 CALL CLOSE (PG,1)        
      CALL WRTTRL (PG(1))        
      IF (NGRAV) 90,100,90        
   90 CONTINUE        
C        
C     CHECK TO SEE IF THE MASS MATRIX IS PURGED        
C        
      MCB(1) = MASS        
      CALL RDTRL (MCB(1))        
      IF (MCB(1) .LE. 0) CALL MESAGE (-56,0,IWORD)        
      CALL GRAVL1 (NGRAV,GVECT(1),ICR2,IHARM)        
C        
C     USE LOAD FILE AS SCRATCH NOTHING ON IT NOW        
C        
      CALL SSG2B (MASS,ICR2,0,ICR3,0,1,1,LODC)        
      CALL GRAVL2 (NGRAV,ICR3,PG(1))        
      N1 = N1 + NGRAV        
  100 IPONT1 = IPTR + 2        
      IPONT  = IPTR + 1        
      NLOAD  = 0        
      DO 110 I = 1,NLLST        
  110 IARY(I) = 0        
      CALL OPEN (*320,CASECC,ICORE(LC+1),0)        
      LC1  = LC - SYSBUF        
      ISLT = 0        
      CALL OPEN (*130,SLT,ICORE(LC1+1),0)        
      ISLT = 1        
      DO 120 I = 1,N1A        
      CALL FWDREC (*270,SLT)        
  120 CONTINUE        
  130 DO 140 I = 1,LOADNN        
      CALL FWDREC (*320,CASECC)        
  140 CONTINUE        
      IFRST = 0        
  150 CALL READ (*250,*250,CASECC,CORE(1),166,1,FLAG)        
      IF (IFRST .NE. 0) GO TO 151        
      IFRST = 1        
      ISPCN = CORE(3)        
      MPCN  = CORE(2)        
  151 CONTINUE        
C        
C     TEST FOR SYMMETRY, BUCKLING OR DIFFERENTIAL STIFFNESS.        
C        
      IF (CORE(16).NE.0 .OR. CORE(5).NE.0 .OR. CORE(138).NE.0) GO TO 150
      IF (CORE(3).NE.ISPCN .OR. CORE(2).NE.MPCN) GO TO 250        
      INULL = 0        
      DO 230 K = 1,4        
      I = IWORD(K)        
      IF (ITHERM.NE.0 .AND. I.EQ.7) GO TO 230        
      IF (CORE(I) .EQ. 0) GO TO 230        
      DO 160 J = 1,N1        
      IF (CORE(I) .EQ. ILIST(J)) GO TO 220        
  160 CONTINUE        
C        
C     COMBINATION CARD        
C        
      INULL = 1        
  170 CALL READ (*270,*330,SLT,IDEFML(1),2,0,IFLAG)        
      IF (CORE(I) .EQ. IDEFML(1)) GO TO 190        
  180 CALL READ (*270,*330,SLT,IDEFML(1),2,0,IFLAG)        
      IF (IDEFML(2) .EQ. -1) GO TO 170        
      GO TO 180        
  190 A = DEFML(2)        
  200 CALL READ (*270,*330,SLT,IDEFML(1),2,0,IFLAG)        
      IF (IDEFML(2) .EQ.  -1) GO TO 210        
      IF (IPONT+1 .GT. NLLST) GO TO 340        
      IARY(IPONT  ) = IARY(IPONT) + 1        
      IARY(IPONT1 ) = IDEFML(2)        
      ARY(IPONT1+1) = A*DEFML(1)        
      IPONT1 = IPONT1 + 2        
      GO TO 200        
  210 CALL BCKREC (SLT)        
      GO TO 230        
  220 IARY(IPONT) = IARY(IPONT) + 1        
      IF (IPONT+1 .GT. NLLST) GO TO 340        
      IARY(IPONT1 ) = CORE(I)        
      ARY(IPONT1+1) = 1.0        
      IPONT1 = IPONT1 + 2        
      INULL  = 1        
  230 CONTINUE        
      IF (INULL .EQ. 0) GO TO 260        
  240 IPONT = IPONT + IARY(IPONT)*2 + 1        
      NLOAD = NLOAD + 1        
      IPONT1= IPONT1+ 1        
      GO TO 150        
  250 CALL CLOSE (CASECC,1)        
      IF (ISLT .EQ. 1) CALL CLOSE (SLT,1)        
      CALL COMBIN (PG(1),ILIST(1),N1)        
      RETURN        
C        
  260 IARY(IPONT) = 1        
      IF (IPONT+1 .GT. NLLST) GO TO 340        
      IARY(IPONT1 ) =-1        
      ARY(IPONT1+1) = 1.0        
      IPONT1 = IPONT1 + 2        
      GO TO 240        
C        
  270 IP1 = SLT        
  280 IP2 =-1        
  290 CALL MESAGE (IP2,IP1,SUBNAM)        
      IP1 = CASECC        
      GO TO 280        
  310 IP1 = PG(1)        
      GO TO 280        
  320 IP1 = CASECC        
      GO TO 280        
  330 IP2 =-2        
      IP1 = SLT        
      GO TO 290        
C        
  340 I = ICORE(I)        
      NWDS = 0        
  350 CALL READ (*330,*360,SLT,CORE(1),LC,0,IFLAG)        
      NWDS = NWDS + LC        
      GO TO 350        
  360 NWDS = NWDS + IFLAG        
      WRITE  (IOTPE,370) UFM,I,NLLST,NWDS        
  370 FORMAT (A23,' 3176, INSUFFICIENT OPEN CORE AVAILABLE TO PROCESS ',
     1       'ALL LOAD CARD COMBINATIONS IN MODULE SSG1.',        
     2       /32X,'CURRENT LOAD ID BEING PROCESSED IS',I9,1H.,        
     3       /32X,'OPEN CORE AVAILABLE IS',I9,' WORDS.',        
     4       /32X,'ADDITIONAL OPEN CORE REQUIRED IS',I9,' WORDS.')      
      IP1 = 0        
      IP2 =-61        
      GO TO 290        
      END        
