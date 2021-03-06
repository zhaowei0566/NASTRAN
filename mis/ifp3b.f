      SUBROUTINE IFP3B        
C        
C        CARDS           TYPE         REC.ID-BIT  CARDS-FILE, CARDS-FILE
C    === =======         ===========  ==========  ==========  ==========
C     1  AXIC     -----  AX.SY.SHELL     515- 5        
C     2  CCONEAX  -----  AX.SY.SHELL    8515-85  CCONE-GEOM2,        
C     3  FORCEAX  -----  AX.SY.SHELL    2115-21  FORCE-GEOM3,        
C     4  FORCE    -----  STANDARD       4201-42  FORCE-GEOM3,        
C     5  GRAV     -----  STANDARD       4401-44   GRAV-GEOM3,        
C     6  LOAD     -----  STANDARD       4551-61   LOAD-GEOM3,        
C     7  MOMAX    -----  AX.SY.SHELL    3815-38  MOMNT-GEOM3,        
C     8  MOMENT   -----  STANDARD       4801-48  MOMNT-GEOM3,        
C     9  MPCADD   -----  STANDARD       4891-60 MPCADD-GEOM4,        
C    10  MPCAX    -----  AX.SY.SHELL    4015-40    MPC-GEOM4,        
C    11  OMITAX   -----  AX.SY.SHELL    4315-43   OMIT-GEOM4,        
C    12  POINTAX  -----  AX.SY.SHELL    4915-49    MPC-GEOM4, GRID-GEOM1
C    13  PRESAX   -----  AX.SY.SHELL    5215-52  PLOAD-GEOM3,        
C    13+ RFORCE   -----  STANDARD       5509-55 RFORCE-GEOM3,        
C    14  RINGAX   -----  AX.SY.SHELL    5615-56    SPC-GEOM4, GRID-GEOM1
C    15  SECTAX   -----  AX.SY.SHELL    6315-63    MPC-GEOM4, GRID-GEOM1
C    16  SEQGP    -----  STANDARD       5301-53  SEQGP-GEOM1,        
C    17  SPCADD   -----  STANDARD       5491-59 SPCADD-GEOM4,        
C    18  SPCAX    -----  AX.SY.SHELL    6215-62    SPC-GEOM4,        
C    19  SUPAX    -----  AX.SY.SHELL    6415-64 SUPORT-GEOM4,        
C    20  TEMPAX   -----  AX.SY.SHELL    6815-68   TEMP-GEOM3,        
C    21  TEMPD    -----  STANDARD       5641-65  TEMPD-GEOM3,        
C        
      IMPLICIT INTEGER (A-Z)        
      EXTERNAL        LSHIFT    ,ANDF      ,ORF        
      LOGICAL         NOGO      ,RECOFF    ,IFPDCO        
      REAL            NPHI      ,NPHI1     ,NISQ      ,NI        ,      
     1                RADDEG    ,RZ        ,T1        ,T2        ,      
     2                T3        ,COEF      ,A1        ,A2        ,      
     3                A3        ,A4        ,ANGLE     ,GC        ,      
     4                SUM       ,CONSTS        
      DIMENSION       GEOM(4)   ,Z(13)        
      CHARACTER       UFM*23    ,UWM*25    ,UIM*29    ,SFM*25        
      COMMON /XMSSG / UFM       ,UWM       ,UIM       ,SFM        
      COMMON /BLANK / BOTTOM        
      COMMON /SYSTEM/ IBUFSZ    ,NOUT      ,NOFLAG    ,DUMDUM(8) ,      
     1                NLINES    ,DDD(14)   ,MN        ,DUM50(50) ,      
     2                IPIEZ        
      COMMON /MACHIN/ MACH      ,IHALF        
      COMMON /TWO   / TWO(32)        
      COMMON /CONDAS/ CONSTS(5)        
      COMMON /IFP3LV/            RECID(3)  ,RECID1(3) ,RECIDX(3) ,      
     1                IEND      ,REC(3)    ,REC1(3)   ,TRAIL(7)  ,      
     2                IT        ,AXTRL(7)  ,OPENFL(6) ,N         ,      
     3                A1        ,CSID      ,NI        ,NISQ      ,      
     4                A2        ,IBUFF1    ,IBUFF2    ,IBUFF3    ,      
     5                A3        ,BUFF      ,NOGO      ,OP        ,      
     6                A4        ,IHEADR    ,IBITR     ,IFILE     ,      
     7                NOREG     ,LAST      ,IERRTN    ,ICONT     ,      
     8                NOAXIC    ,RINGID    ,OUTBUF    ,VEOR      ,      
     9                ISTART    ,IRETRN    ,FLAG      ,IAMT      ,      
     T                SUM       ,IBIT      ,SETID     ,SORC      ,      
     1                IBEGIN    ,MPCON     ,NWORDS    ,NNN       ,      
     2                ANGLE     ,K3OR6     ,NPHI1     ,ZPT       ,      
     3                NMOVE     ,CSSET     ,NOPONT    ,NON       ,      
     4                IPHI      ,RECOFF    ,NPHI      ,N3OR5     ,      
     5                ION       ,NPLUS1    ,NOSECT    ,COEF      ,      
     6                IPT       ,COMPON    ,ICORE     ,ISCRAT    ,      
     7                ICORE1    ,NCARDS    ,I1        ,IAT       ,      
     8                I2        ,T1        ,T2        ,NFILE     ,      
     9                NADD      ,NCARD        
      COMMON /IFP3CM/ FILE(6)   ,INAME(12) ,CDTYPE(50),AXIC1(3)  ,      
     1                CCONEX(3) ,FORCEX(3) ,FORCE(3)  ,GRAV(3)   ,      
     2                LOAD(3)   ,MOMAX(3)  ,MOMENT(3) ,MPCADD(3) ,      
     3                MPCAX(3)  ,OMITAX(3) ,POINTX(3) ,PRESAX(3) ,      
     4                RINGAX(3) ,SECTAX(3) ,SEQGP(3)  ,SPCAX(3)  ,      
     5                SUPAX(3)  ,TEMPAX(3) ,TEMPD(3)  ,PLOAD(3)  ,      
     6                MPC(3)    ,SPC(3)    ,GRID(3)   ,SUPORT(3) ,      
     7                NEG111(3) ,T65535(3) ,TEMP(3)   ,OMIT(3)   ,      
     8                SPCADD(3) ,ONE       ,ZERO      ,IHEADB(96),      
     9                CTRIAA(3) ,CTRAPA(3) ,ICONSO        
      COMMON /OUTPUT/ DUMMY(96) ,IHEAD(96)        
      COMMON /IFPDTA/ DUM(521)  ,GC(7)     ,LL(6)        
CZZ   COMMON /ZZIFP3/ RZ(1)        
      COMMON /ZZZZZZ/ RZ(1)        
      EQUIVALENCE     (CONSTS(4),RADDEG )  , (Z(1)    ,RZ(1)  )  ,      
     1                (GEOM(1)  ,FILE(1))  , (SCRTCH  ,FILE(5))  ,      
     2                (AXIC     ,FILE(6))                        ,      
     3                (NOEOR    ,INPRWD    ,  ZERO            )  ,      
     4                (EOR      ,CLORWD    ,  OUTRWD  ,ONE    )        
      DATA    IFIST / 4HFIST/   ,I3,I4,I5  /  3,4,5   /        
C        
C        
C     GEOM4 PROCESSING        
C     ================        
C        
C     OPEN GEOM4        
C        
      IFILE= GEOM(4)        
      I    = 4        
      OP   = OUTRWD        
      BUFF = IBUFF2        
      ASSIGN 20 TO IRETRN        
      GO TO 1340        
C        
C     SPCADD OR MPCADD CARDS        
C     ======================        
C        
   20 ASSIGN 30 TO ICONT        
      REC(1)  = MPCADD(1)        
      REC(2)  = MPCADD(2)        
      REC(3)  = MPCADD(3)        
      REC1(1) = MPCAX(1)        
      REC1(2) = MPCAX(2)        
      REC1(3) = MPCAX(3)        
   21 ASSIGN 28 TO IHEADR        
      GO TO 1470        
C        
C     MANDATORY SPCADD AND MPCADD CARDS.        
C        
   28 Z( 1) = 100000101        
      Z( 2) = 101        
      Z( 3) = -1        
      Z( 4) = 200000102        
      Z( 5) = 102        
      Z( 6) = -1        
      Z( 7) = 100000000        
      Z( 8) = 101        
      Z( 9) = -1        
      Z(10) = 200000000        
      Z(11) = 102        
      Z(12) = -1        
      IF (NOGO) GO TO 22        
      CALL WRITE (GEOM(4),Z(1),12,NOEOR)        
   22 CALL LOCATE (*23,Z(IBUFF1),REC(1),FLAG)        
C        
C     READ AN OPEN ENDED SPCADD OR MPCADD CARD INTO CORE.        
C        
      I = 1        
   27 CALL READ (*1540,*23,AXIC,Z(I),1,NOEOR,IAMT)        
      IF (Z(I)) 25,24,24        
   24 I = I + 1        
      IF ((I+1) .GT. ICORE) GO TO 1580        
      GO TO 27        
C        
C     COMPLETE CARD IS AT HAND        
C        
   25 Z(I) = 101        
      I    = I + 1        
      Z(I) = -1        
      Z(1) = Z(1) + 100000000        
      IF (NOGO) GO TO ICONT, (30,610)        
   26 CALL WRITE (GEOM(4),Z(1),I,NOEOR)        
      IF (Z(I-1) .EQ. 102) GO TO 23        
      Z(I-1) = 102        
      Z(1  ) = Z(1) + 100000000        
      GO TO 26        
C        
C     ALL SPCADD OR MPCADD CARDS COMPLETE.        
C     NOW CREATE SPCADD OR MPCADD FROM SPCAX OR MPCAX        
C     CARDS RESPECTIVELY.        
C        
   23 IREC   = REC(1)        
      REC(1) = REC1(1)        
      REC(2) = REC1(2)        
      REC(3) = REC1(3)        
      CALL LOCATE (*35,Z(IBUFF1),REC(1),FLAG)        
C        
C     OK SPCAX OR MPCAX RECORD EXISTS.        
C        
      ILAST = -1        
   38 Z(4)  = -1        
      CALL READ (*1540,*35,AXIC,Z(2),1,NOEOR,IAMT)        
C        
C     MPCAX CARDS ARE OPEN ENDED        
C     SPCAX CARDS ARE 5 WORDS LONG.        
C        
      IF (Z(2) .EQ. ILAST) GO TO 47        
      ILAST = Z(2)        
C        
C     CREATE TWO SPCADD OR MPCADD CARDS.        
C        
      Z(3) = 101        
      Z(1) = Z(2) + 100000000        
      IF (NOGO) GO TO ICONT, (30,610)        
   33 CALL WRITE (GEOM(4),Z(1),4,NOEOR)        
      IF (Z(3) .EQ. 102) GO TO 47        
      Z(3) = 102        
      Z(1) = Z(1) + 100000000        
      GO TO 33        
C        
C     READ UP TO NEXT CARD        
C        
   47 CALL READ (*1540,*35,AXIC,Z(1),4,NOEOR,IAMT)        
      IF (REC(1).EQ.SPCAX(1) .OR. Z(1).EQ.(-1)) GO TO 38        
      GO TO 47        
C        
C     ALL CARDS COMPLETE.        
C     WRITE EOR AND PUT BITS IN TRAILER.        
C        
   35 IAMT = 0        
      ASSIGN 37 TO IRETRN        
      IF (IREC .EQ. SPCADD(1)) GO TO 39        
      REC(1) = MPCADD(1)        
      REC(2) = MPCADD(2)        
      REC(3) = MPCADD(3)        
      GO TO 1300        
   39 REC(1) = SPCADD(1)        
      REC(2) = SPCADD(2)        
      REC(3) = SPCADD(3)        
      GO TO 1300        
   37 GO TO ICONT, (30,610)        
C        
C     MPCAX CARD        
C     ==========        
C        
   30 MPCON  = 0        
      REC(1) = MPC(1)        
      REC(2) = MPC(2)        
      REC(3) = MPC(3)        
      RECOFF = .FALSE.        
      LAST   = -1        
      NCARD  = 10        
      NWORDS = 0        
      CALL LOCATE (*130,Z(IBUFF1),MPCAX(1),FLAG)        
C        
C     WRITE RECORD HEADER        
C        
      RECOFF = .TRUE.        
      ASSIGN 40 TO IHEADR        
      GO TO 1470        
C        
   40 MPCON = 1        
      LAST  = 0        
C        
C     READ SET ID        
C        
   50 CALL READ (*1540,*120,AXIC,SETID,1,NOEOR,IAMT)        
      IF (SETID .GT. 100) GO TO 130        
      NWORDS = NWORDS + 1        
      IF (NOGO) GO TO 60        
      CALL WRITE (GEOM(4),SETID,1,NOEOR)        
C        
C     READ 4-WORDS SETS UNTIL -1,-1,-1,-1 ENCOUNTERED...        
C        
   60 CALL READ (*1540,*100,AXIC,Z(1),4,NOEOR,IAMT)        
      NWORDS = NWORDS + 4        
      IF (Z(4) .EQ. -1) GO TO 90        
C        
C     CHECK HARMONIC NUMBER        
C        
      NNN = Z(2)        
      ASSIGN 70 TO IERRTN        
      GO TO 1420        
C        
C     CHECK RING ID        
C        
   70 NNN = Z(1)        
      ASSIGN 80 TO IERRTN        
      GO TO 1440        
C        
   80 Z(2) = Z(1) + (Z(2)+1)*1000000        
      IF (NOGO) GO TO 60        
      CALL WRITE (GEOM(4),Z(2),3,NOEOR)        
      GO TO 60        
C        
C     END OF EQUATION        
C        
   90 IF (NOGO) GO TO 50        
      CALL WRITE (GEOM(4),NEG111(1),3,NOEOR)        
      GO TO 50        
  100 CALL PAGE2 (3)        
      IMSG = 1063        
      WRITE  (NOUT,105) SFM,IMSG        
  105 FORMAT (A25,I5)        
      WRITE  (NOUT,110) SFM,IMSG        
  110 FORMAT (5X,50HEOR ON AXIC FILE WHILE READING MPCAX CARD RECORDS.) 
      NOGO = .TRUE.        
      GO TO 1530        
  120 LAST = 1        
C        
C     FIRST NWORDS HAVE BEEN PROCESSED OF MPCAX CARDS UNLESS        
C     LAST = 1, IN WHICH CASE ALL MPCAX CARDS ARE COMPLETE.        
C     GO NOW TO THE S-SET MPC CARD-GENERATION FOR POINTAX CARDS        
C     IF LAST = -1, THERE ARE NO MPCAX CARDS.        
C        
C        
C     S-SET MPC-S FROM POINTAX CARDS        
C     ==============================        
C        
  130 REC(1) = POINTX(1)        
      REC(2) = POINTX(2)        
      REC(3) = POINTX(3)        
      NCARD  = 12        
      N3OR5  = 3        
      K3OR6  = 6        
      SORC   = 101        
      ASSIGN 380 TO ICONT        
C     TURN NOPONT OR NOSECT ON IF POINTAX OR SECTAX CARDS EXIST RESPECT.
C        
      IBIT = POINTX(2)        
      ASSIGN 140 TO IBITR        
      GO TO 1460        
  140 NOPONT = NON        
      IBIT = SECTAX(2)        
      ASSIGN 150 TO IBITR        
      GO TO 1460        
  150 NOSECT = NON        
C        
      IF (NOPONT) 160,370,160        
C        
  160 CALL LOCATE (*370,Z(IBUFF1),REC(1),FLAG)        
      MPCON = 1        
      IF (RECOFF) GO TO 170        
C        
C     WRITE RECORD HEADER        
C        
      RECOFF = .TRUE.        
      REC(1) = MPC(1)        
      REC(2) = MPC(2)        
      REC(3) = MPC(3)        
      ASSIGN 170 TO IHEADR        
      GO TO 1470        
C        
  170 CALL READ (*1540,*370,AXIC,Z(1),N3OR5,NOEOR,IAMT)        
C        
C     CHECK RING ID FOR S-SET PASS ONLY FOR POINTAX AND SECTAX CARDS.   
C     NO CHECK WILL BE MADE IN THE GRID CARD GENERATION AREA.        
C        
C     IF (SORC .EQ. 102) GO TO 785        
      NNN = Z(2)        
      ASSIGN 180 TO IERRTN        
      GO TO 1440        
C        
  180 IAT = N3OR5 + 1        
      DO 360 I = 1,K3OR6        
      Z(IAT) = SORC        
      Z(IAT+1) = Z(1)        
      Z(IAT+2) = I        
      RZ(IAT+3)= -1.0        
      IF (NOGO) GO TO 190        
      CALL WRITE (GEOM(4),Z(IAT),4,NOEOR)        
  190 DO 350 J = 1,NPLUS1        
C        
C     COMPUTE COEFFICIENT.        
C        
      NI = J - 1        
      IF (N3OR5 .EQ. 5) GO TO 240        
C        
C     POINTAX CARD COEFFICIENTS        
C        
      T1 = NI*RZ(I3)*RADDEG        
      IF (ANDF(I,1)) 210,210,200        
C        
C     ODD I        
C        
  200 IF (SORC - 101) 220,220,230        
C        
C     EVEN I        
C        
  210 IF (SORC - 101) 230,230,220        
C        
  220 COEF = SIN(T1)        
      GO TO 340        
C        
  230 COEF = COS(T1)        
      IF (SORC .EQ. 101) COEF = -COEF        
      IF (NI.EQ.0.0 .AND. SORC.EQ.101) COEF = 1.0        
      GO TO 340        
C        
C     SECTAX CARD COEFFICIENTS        
C        
  240 T1 = NI*RZ(I4)*RADDEG        
      T2 = NI*RZ(I5)*RADDEG        
      IF (I .GE.  4) GO TO 245        
      IF (ANDF(I,1)) 250,250,280        
  245 IF (ANDF(I,1)) 280,280,250        
C        
C     EVEN I        
C        
  250 IF (SORC .EQ. 101) GO TO 290        
  260 IF (NI) 270,320,270        
  270 T3 = T2        
      T2 = COS(T1)        
      T1 = COS(T3)        
      GO TO 310        
C        
C     ODD I        
C        
  280 IF (SORC .EQ. 101) GO TO 260        
  290 IF (NI) 300,330,300        
  300 T1 = SIN(T1)        
      T2 = SIN(T2)        
  310 COEF = RZ(I3)*(T2-T1)/NI        
      IF (SORC.EQ.101 .AND. (I.EQ.2 .OR. I.EQ.5)) COEF = -COEF        
      GO TO 340        
  320 COEF = 0.0        
      GO TO 340        
  330 COEF = RZ(I3)*(RZ(I5)-RZ(I4))*RADDEG        
C        
  340 Z(IAT  ) = Z(2) + J*1000000        
      Z(IAT+1) = I        
      RZ(IAT+2)= COEF        
      IF (NOGO) GO TO 350        
      CALL WRITE (GEOM(4),Z(IAT),3,NOEOR)        
  350 CONTINUE        
      IF (NOGO) GO TO 360        
      CALL WRITE (GEOM(4),NEG111(1),3,NOEOR)        
  360 CONTINUE        
      GO TO 170        
C        
  370 GO TO ICONT, (380,390,400,410)        
C        
C     S-SET MPC-S FROM SECTAX CARDS        
C     =============================        
C        
C     DO SECTAX CARDS FOR S-SET.        
C        
  380 REC(1) = SECTAX(1)        
      REC(2) = SECTAX(2)        
      REC(3) = SECTAX(3)        
      N3OR5  = 5        
      K3OR6  = 6        
      SORC   = 101        
      NCARD  = 15        
      ASSIGN 390 TO ICONT        
      IF (NOSECT) 160,390,160        
C        
C     C-SET MPC-S FROM POINTAX CARDS        
C     ==============================        
C        
C        
  390 REC(1) = POINTX(1)        
      REC(2) = POINTX(2)        
      REC(3) = POINTX(3)        
      N3OR5  = 3        
      K3OR6  = 6        
      SORC   = 102        
      ASSIGN 400 TO ICONT        
      IF (NOPONT) 160,400,160        
C        
C     C-SET MPC-S FROM SECTAX CARDS        
C     =============================        
C        
  400 REC(1) = SECTAX(1)        
      REC(2) = SECTAX(2)        
      REC(3) = SECTAX(3)        
      N3OR5  = 5        
      K3OR6  = 6        
      SORC   = 102        
      ASSIGN 410 TO ICONT        
      IF (NOSECT) 160,410,160        
C        
C     BALANCE OF MPCAX CARDS        
C        
  410 IF (LAST) 510,420,510        
  420 CALL LOCATE (*510,Z(IBUFF1),MPCAX(1),FLAG)        
      NCARD = 10        
      IF (NWORDS .EQ. 0) GO TO 440        
      DO 430 I = 1,NWORDS        
      CALL READ (*1540,*470,AXIC,Z(1),1,NOEOR,IAMT)        
  430 CONTINUE        
C        
C     NOW POSITIONED AT POINT LEFT OFF AT ABOVE.        
C        
  440 CALL READ (*1540,*510,AXIC,SETID,1,NOEOR,IAMT)        
      IF (SETID .LT. 101) GO TO 470        
      IF (SETID .GT. 102) GO TO 448        
      NOGO = .TRUE.        
      CALL PAGE2(3)        
      IMSG = 366        
      WRITE  (NOUT,445) UFM,IMSG        
  445 FORMAT (A23,I5)        
      WRITE  (NOUT,442)        
  442 FORMAT (5X,'SPCAX OR MPCAX CARD HAS A SETID = 101 OR 102.  101 ', 
     1      'AND 102 ARE SYSTEM ID-S RESERVED FOR SINE AND COSINE SETS')
  448 IF (NOGO) GO TO 450        
      CALL WRITE (GEOM(4),SETID,1,NOEOR)        
  450 CALL READ (*1540,*100,AXIC,Z(1),4,NOEOR,IAMT)        
      IF (Z(4) .EQ. (-1)) GO TO 500        
C        
C     CHECK HARMONIC NUMBER        
C        
      NNN = Z(2)        
      ASSIGN 460 TO IERRTN        
      GO TO 1420        
C        
C     CHECK RING ID        
C        
  460 NNN = Z(1)        
      ASSIGN 490 TO IERRTN        
      GO TO 1440        
  470 CALL PAGE2 (3)        
      IMSG = 1063        
      WRITE  (NOUT,105) SFM,IMSG        
      WRITE  (NOUT,480) CDTYPE(19),CDTYPE(20)        
  480 FORMAT (5X,'EOR ON AXIC FILE WHILE READING ',2A4,'CARD RECORDS.') 
      NOGO = .TRUE.        
      GO TO 1530        
C        
  490 Z(2) = Z(1) + (Z(2)+1)*1000000        
      IF (NOGO) GO TO 450        
      CALL WRITE (GEOM(4),Z(2),3,NOEOR)        
      GO TO 450        
C        
C     END OF EQUATION        
C        
  500 IF (NOGO) GO TO 440        
      CALL WRITE (GEOM(4),NEG111(1),3,NOEOR)        
      GO TO 440        
C        
C     AT 713(?) WRITE EOR AND PUT BITS IN TRAILER.        
C        
  510 IF (MPCON) 520,530,520        
  520 IAMT   = 0        
      REC(1) = MPC(1)        
      REC(2) = MPC(2)        
      REC(3) = MPC(3)        
      ASSIGN 530 TO IRETRN        
      GO TO 1300        
C        
C     OMITAX CARDS        
C        
  530 REC(1) = OMITAX(1)        
      REC(2) = OMITAX(2)        
      REC(3) = OMITAX(3)        
      NCARD  = 11        
      REC1(1)= OMIT(1)        
      REC1(2)= OMIT(2)        
      REC1(3)= OMIT(3)        
      ASSIGN 600 TO ICONT        
  540 CALL LOCATE (*590,Z(IBUFF1),REC(1),FLAG)        
      IF (NOGO) GO TO 550        
      CALL WRITE (GEOM(4),REC1(1),3,NOEOR)        
  550 CALL READ (*1540,*580,AXIC,Z(1),3,NOEOR,IAMT)        
C        
C     CHECK HARMONIC NUMBER        
C        
      NNN = Z(2)        
      ASSIGN 560 TO IERRTN        
      GO TO 1420        
C        
C     CHECK RING ID        
C        
  560 NNN = Z(1)        
      ASSIGN 570 TO IERRTN        
      GO TO 1440        
C        
  570 Z(2) = Z(1) + (Z(2)+1)*1000000        
      IF (IFPDCO(Z(3))) GO TO 571        
      DO 572 L2 = 1,6        
      IF (LL(L2) .EQ. 0) GO TO 572        
      Z(3) = LL(L2)        
      IF (NOGO) GO TO 550        
      CALL WRITE (GEOM(4),Z(2),2,NOEOR)        
  572 CONTINUE        
      GO TO 550        
  571 NOGO = .TRUE.        
      CALL PAGE2 (3)        
      IMSG = 367        
      WRITE  (NOUT,445) UFM,IMSG        
      WRITE  (NOUT,573) Z(3),CDTYPE(2*NCARD-1),CDTYPE(2*NCARD)        
  573 FORMAT (5X,'COMPONENT SPECIFICATION',I8,4H ON ,2A4,        
     1       ' CARD IS INCORRECT')        
      GO TO 550        
C        
C     WRITE EOR AND PUT BITS IN TRAILER        
C        
  580 IAMT   = 0        
      REC(1) = REC1(1)        
      REC(2) = REC1(2)        
      REC(3) = REC1(3)        
      ASSIGN 590 TO IRETRN        
      GO TO 1300        
  590 GO TO ICONT, (600,870)        
C        
C     SPCADD CARD        
C     ===========        
C        
  600 REC(1)  = SPCADD(1)        
      REC(2)  = SPCADD(2)        
      REC(3)  = SPCADD(3)        
      REC1(1) = SPCAX(1)        
      REC1(2) = SPCAX(2)        
      REC1(3) = SPCAX(3)        
      ASSIGN 610 TO ICONT        
      GO TO 21        
C        
C     SPCAX CARD        
C     ==========        
C        
  610 REC(1) = SPC(1)        
      REC(2) = SPC(2)        
      REC(3) = SPC(3)        
C        
C     RECORD HEADER FOR SPC-S        
C        
      ASSIGN 620 TO IHEADR        
      GO TO 1470        
C        
  620 LAST  = -1        
      NCARD = 18        
      CALL LOCATE (*670,Z(IBUFF1),SPCAX(1),FLAG)        
      LAST   = 0        
      NWORDS = 0        
  630 CALL READ (*1540,*660,AXIC,Z(1),5,NOEOR,IAMT)        
      IF (Z(1) .GT. 100) GO TO 670        
      NWORDS = NWORDS + 5        
C        
C     ALTER CARD JUST READ AND OUTPUT        
C        
C     CHECK HARMONIC NUMBER        
C        
      NNN = Z(3)        
      ASSIGN 640 TO IERRTN        
      GO TO 1420        
C        
C     CHECK RING ID        
C        
  640 NNN = Z(2)        
      ASSIGN 650 TO IERRTN        
      GO TO 1440        
C        
  650 Z(2) = Z(2) + (Z(3)+1)*1000000        
      Z(3) = Z(4)        
      Z(4) = Z(5)        
      IF (NOGO) GO TO 630        
C        
      CALL WRITE (GEOM(4),Z(1),4,NOEOR)        
      GO TO 630        
  660 LAST = 1        
C        
C     FIRST NWORDS HAVE BEEN PROCESSED OF SPCAX CARDS        
C     UNLESS LAST = 1, IN WHICH CASE ALL SPCAX CARDS ARE COMPLETE.      
C     IF LAST = -1, THERE ARE NO SPCAX CARDS        
C        
C     S-SET AND C-SET SPC-S FROM RINGAX CARDS        
C     =======================================        
C        
  670 SORC   = 101        
      NCARD  = 14        
      COMPON = 135        
      IF (ICONSO .EQ. 1) COMPON = 13        
      ASSIGN 750 TO ICONT        
  680 CALL LOCATE (*760,Z(IBUFF1),RINGAX(1),FLAG)        
  690 CALL READ (*1540,*740,AXIC,Z(1),4,NOEOR,IAMT)        
C        
       IF (SORC .EQ. 102) GO TO 730        
C        
C     GIVE RING CARD A CHECK FOR MINIMUM DATA.        
C        
C     CHECK RING ID        
C        
      NNN = Z(1)        
      ASSIGN 700 TO IERRTN        
      GO TO 1440        
C        
C     CHECK FOR NON-ZERO RADIUS        
C        
  700 IF (RZ(I3-1)) 730,710,730        
  710 CALL PAGE2 (3)        
      IMSG = 368        
      WRITE  (NOUT,445) UFM,IMSG        
      WRITE  (NOUT,720) Z(1)        
  720 FORMAT (5X,'RINGAX CARD WITH RING ID =',I10,' HAS A ZERO RADIUS', 
     1       ' SPECIFIED.')        
      NOGO = .TRUE.        
  730 Z(4) = 0        
      Z(3) = COMPON        
      Z(2) = Z(1) + 1000000        
      Z(1) = SORC        
      IF (NOGO) GO TO 690        
      CALL WRITE (GEOM(4),Z(1),4,NOEOR)        
      GO TO 690        
C        
  740 GO TO ICONT, (750,770)        
  750 SORC   = 102        
      COMPON = 246        
      IF (ICONSO .EQ. 1) COMPON = 2        
C        
C     KEEP DOF 4 FOR PIEZOELECTRIC PROBLEM        
C        
      IF (IPIEZ .EQ. 1) COMPON = 26        
      ASSIGN 770 TO ICONT        
      GO TO 680        
C        
C     MISSING REQUIRED CARD        
C        
  760 ASSIGN 770 TO IERRTN        
      GO TO 1510        
C        
C     BALANCE OF SPCAX CARDS        
C        
  770 IF (LAST) 830,780,830        
  780 CALL LOCATE (*830,Z(IBUFF1),SPCAX(1),FLAG)        
      NCARD = 18        
      IF (NWORDS .EQ. 0) GO TO 800        
      DO 790 I = 1,NWORDS,5        
      CALL READ (*1540,*840,AXIC,Z(1),5,NOEOR,IAMT)        
  790 CONTINUE        
C        
C     NOW POSITIONED AT POINT LEFT OFF AT ABOVE...        
C        
  800 CALL READ (*1540,*830,AXIC,Z(1),5,NOEOR,IAMT)        
      IF (Z(1) .LT. 101) GO TO 840        
      IF (Z(1) .GT. 102) GO TO 808        
      NOGO = .TRUE.        
      CALL PAGE2 (3)        
      IMSG = 366        
      WRITE (NOUT,445) UFM,IMSG        
      WRITE (NOUT,442)        
C        
C     CHECK HARMONIC NUMBER        
C        
  808 NNN = Z(3)        
      ASSIGN 810 TO IERRTN        
      GO TO 1420        
C        
C     RING ID CHECK        
C        
  810 NNN = Z(2)        
      ASSIGN 820 TO IERRTN        
      GO TO 1440        
C        
  820 Z(2) = Z(2) + (Z(3)+1)*1000000        
      Z(3) = Z(4)        
      Z(4) = Z(5)        
      IF (NOGO) GO TO 800        
      CALL WRITE (GEOM(4),Z(1),4,NOEOR)        
      GO TO 800        
C        
C     WRITE EOR AND PUT BITS IN THE TRAILER        
C        
  830 IAMT = 0        
      ASSIGN 860 TO IRETRN        
      GO TO 1300        
  840 CALL PAGE2 (3)        
      IMSG = 1063        
      WRITE (NOUT,105) SFM,IMSG        
      WRITE (NOUT,480) CDTYPE(35),CDTYPE(36)        
      NOGO = .TRUE.        
      GO TO 1530        
C        
C     SUPAX CARDS        
C     ===========        
C        
  860 REC(1)  = SUPAX(1)        
      REC(2)  = SUPAX(2)        
      REC(3)  = SUPAX(3)        
      NCARD   = 19        
      REC1(1) = SUPORT(1)        
      REC1(2) = SUPORT(2)        
      REC1(3) = SUPORT(3)        
      ASSIGN 870 TO ICONT        
      GO TO 540        
C        
C     CLOSE GEOM4        
C        
  870 I = 4        
      ASSIGN 880 TO IRETRN        
      GO TO 1380        
C        
C        
C     GEOM1 PROCESSING        
C     ================        
C        
C     OPEN GEOM1        
C        
  880 IFILE = GEOM(1)        
      I    = 1        
      OP   = OUTRWD        
      BUFF = IBUFF2        
      ASSIGN 890 TO IRETRN        
      GO TO 1340        
C        
C     GRID CARDS FROM POINTAX AND SECTAX CARDS        
C        
C     NOPONT = 0 OR 1, DEPENDING ON THE PRESSENCE OF POINTAX CARDS      
C     NOSECT = 0 OR 1, DEPENDING ON THE PRESSENCE OF SECTAX  CARDS      
C        
C     RECORD HEADER FOR GRID CARDS        
C        
  890 REC(1) = GRID(1)        
      REC(2) = GRID(2)        
      REC(3) = GRID(3)        
      ASSIGN 900 TO IHEADR        
      GO TO 1470        
C        
  900 IF (NOSECT) 920,910,920        
  910 IF (NOPONT) 980,1110,980        
  920 IF (NOPONT) 930,940,930        
C        
C     LOCATE SECTAX CARDS, READ SECTAX, CONVERT TO GRID, PUT ON NFILE   
C        
  930 NFILE = SCRTCH        
C        
C     OPEN SCRTCH FILE        
C        
      I   = 5        
      OP  = OUTRWD        
      BUFF= IBUFF3        
      ASSIGN 950 TO IRETRN        
      GO TO 1340        
C        
  940 NFILE = GEOM(1)        
C        
  950 ICARD = 15        
      CALL LOCATE (*1090,Z(IBUFF1),SECTAX(1),FLAG)        
  960 CALL READ (*1540,*970,AXIC,Z(1),5,NOEOR,IAMT)        
      Z(2) = 0        
      Z(6) = CSID        
      Z(7) = 0        
      Z(8) = 0        
      IF (NOGO) GO TO 960        
      CALL WRITE (NFILE,Z(1),8,NOEOR)        
      GO TO 960        
  970 IF (NOPONT) 980,1110,980        
  980 ICARD = 12        
      CALL LOCATE (*1090,Z(IBUFF1),POINTX(1),FLAG)        
C        
C     READ POINT CARD CONVERT TO GRID CARD AND PUT OUT ON GEOM(1)       
C     MERGING GRID CARDS FROM SCRTCH IF NOSECT IS NON-ZERO        
C        
      IF (NOSECT) 990,1000,990        
  990 IF (NOGO  ) GO TO 1110        
      CALL CLOSE (SCRTCH,CLORWD)        
      CALL OPEN (*1570,SCRTCH,Z(IBUFF3),INPRWD)        
      CALL READ (*1050,*1050,SCRTCH,Z(9),8,NOEOR,IAMT)        
 1000 CALL READ (*1540,*1070,AXIC,Z(1),3,NOEOR,IAMT)        
C        
C     CONVERT POINTAX CARD        
C        
      Z(2)   = 0        
      RZ(I4) = 0.0        
      RZ(I5) = 0.0        
      Z(6)   = CSID        
      Z(7)   = 0        
      Z(8)   = 0        
      IF (NOSECT) 1010,1020,1010        
 1010 IF (Z(1) .GE. Z(9)) GO TO 1030        
 1020 ZPT = 1        
      GO TO 1040        
 1030 ZPT = 9        
 1040 IF (NOGO) GO TO 1110        
      CALL WRITE (GEOM(1),Z(ZPT),8,NOEOR)        
      IF (ZPT .EQ. 1) GO TO 1000        
      CALL READ (*1050,*1050,SCRTCH,Z(9),8,NOEOR,IAMT)        
      IF (NOPONT) 1010,1040,1010        
 1050 NOSECT = 0        
C        
C     CLOSE SCRTCH        
C        
      I = 5        
      ASSIGN 1060 TO IRETRN        
      GO TO 1380        
 1060 IF (NOPONT) 1020,1110,1020        
C        
 1070 IF (NOSECT) 1080,1110,1080        
 1080 ZPT = 9        
      NOPONT = 0        
      GO TO 1040        
C        
 1090 CALL PAGE2 (3)        
      IMSG = 1064        
      WRITE  (NOUT,105) SFM,IMSG        
      WRITE  (NOUT,1100) CDTYPE(2*ICARD-1),CDTYPE(2*ICARD)        
 1100 FORMAT (5X,2A4,' CARD COULD NOT BE LOCATED ON AXIC FILE AS ',     
     1       'EXPECTED.')        
      NOGO = .TRUE.        
      GO TO 1110        
C        
C     GRID CARDS FROM RING CARDS        
C        
C     COPY RINGAX CARDS INTO CORE AND TO SCRTCH IF CORE IS EXCEEDED.    
C        
 1110 CALL LOCATE (*1240,Z(IBUFF1),RINGAX(1),FLAG)        
      NWORDS = (ICORE/4)*4 - 12        
      IBEGIN = 13        
      ISCRAT = 0        
      CALL READ (*1540,*1140,AXIC,Z(13),NWORDS,NOEOR,IAMT)        
C        
C     FALL HERE IMPLIES CORE IS FULL.. SPILL BALANCE TO SCRTCH FILE.    
C        
      ION    = 0        
      ISCRAT = 0        
      IF (NOGO) GO TO 1240        
      CALL OPEN (*1570,SCRTCH,Z(IBUFF3),OUTRWD)        
 1120 CALL READ (*1540,*1130,AXIC,Z(1),8,NOEOR,IAMT)        
      ION = 1        
      CALL WRITE (SCRTCH,Z(1),8,NOEOR)        
      GO TO 1120        
 1130  IF ((IAMT/4)*4 .NE. IAMT) GO TO 1230        
      IF (ION.EQ.0 .AND. IAMT.EQ.0) GO TO 1160        
      ISCRAT = 1        
      IF (NOGO) GO TO 1240        
      CALL WRITE (SCRTCH,Z(1),IAMT,EOR)        
      CALL CLOSE (SCRTCH,CLORWD)        
      GO TO 1160        
C        
 1140 IF ((IAMT/4)*4 .NE. IAMT) GO TO 1230        
      NWORDS = IAMT        
C        
C     NWORDS-WORDS ARE IN CORE AND IF ISCRAT = 1 THERE IS        
C     A RECORD OF RINGAX CARDS ON SCRTCH FILE ALSO        
C        
C     NOW MAKE N+1 PASSES THROUGH THE RING CARDS        
C        
 1160 IF (ISCRAT) 1170,1180,1170        
 1170 IF (NOGO  ) GO TO 1240        
      CALL OPEN (*1570,SCRTCH,Z(IBUFF3),INPRWD)        
 1180 Z(2) = 0        
      Z(5) = 0        
      Z(6) = CSID        
      Z(8) = 0        
      NCARDS = NWORDS/4        
C        
C     27TH WORD OF SYSTEM IS PACKED AND HOLDS NUMBER OF RINGS AND HARMS 
C        
      MN   = ORF(LSHIFT(NCARDS,IHALF),NPLUS1)        
      NADD = 0        
      DO 1220 I = 1,NPLUS1        
      NADD = NADD + 1000000        
      IPT  = IBEGIN - 4        
C        
C     PASS THROUGH THE INCORE CARDS        
C        
      DO 1190 J = 1,NCARDS        
      IPT  = IPT + 4        
      Z(1) = Z(IPT) + NADD        
      Z(3) = Z(IPT+1)        
      Z(4) = Z(IPT+2)        
      Z(7) = Z(IPT+3)        
      IF (NOGO) GO TO 1190        
      CALL WRITE (GEOM(1),Z(1),8,NOEOR)        
 1190 CONTINUE        
C        
C     PASS THROUGH SCRTCH CARDS IF ANY        
C        
      IF (NOGO  ) GO TO 1220        
      IF (ISCRAT) 1200,1220,1200        
 1200 CALL READ (*1540,*1210,SCRTCH,Z(9),4,NOEOR,IAMT)        
      Z(1) = Z(9) + NADD        
      Z(3) = Z(10)        
      Z(4) = Z(11)        
      Z(7) = Z(12)        
      CALL WRITE (GEOM(1),Z(1),8,NOEOR)        
      GO TO 1200        
C        
 1210 CALL REWIND (SCRTCH)        
 1220 CONTINUE        
C        
C     PUT BITS IN TRAILER AND WRITE EOR FOR GRID CARDS        
C        
      IAMT   = 0        
      REC(1) = GRID(1)        
      REC(2) = GRID(2)        
      REC(3) = GRID(3)        
      ASSIGN 1240 TO IRETRN        
      GO TO 1300        
 1230 NCARD  = 14        
      ASSIGN 1240 TO IERRTN        
      GO TO 1490        
C        
C     SEQGP CARD        
C     ==========        
C        
 1240 REC(1) = SEQGP(1)        
      REC(2) = SEQGP(2)        
      REC(3) = SEQGP(3)        
      ASSIGN 1250 TO IRETRN        
      GO TO 1260        
C        
C     CLOSE GEOM1        
C        
 1250 I = 1        
      ASSIGN 1530 TO IRETRN        
      GO TO 1380        
C        
C        
C     UTILITY SECTION FOR IFP3        
C     AXIS-SYMETRIC-CONICAL-SHELL DATA GENERATOR.        
C     ==========================================        
C        
C     COMMON CODE FOR TRANSFER OF RECORD FROM AXIC FILE TO SOME        
C     OTHER FILE        
C        
 1260 CALL LOCATE (*1330,Z(IBUFF1),REC(1),FLAG)        
      IF (NOGO) GO TO 1330        
      CALL WRITE (IFILE,REC(1),3,NOEOR)        
 1290 CALL READ (*1540,*1300,AXIC,Z(1),ICORE,NOEOR,IAMT)        
      IAMT = ICORE        
      CALL WRITE (IFILE,Z(1),IAMT,NOEOR)        
      GO TO 1290        
 1300 IF (NOGO) GO TO 1330        
      CALL WRITE (IFILE,Z(1),IAMT,EOR)        
C        
C     PUT BITS IN TRAILER        
C        
      I1 = (REC(2)-1)/16 + 2        
      I2 =  REC(2)-(I1-2)*16 + 16        
      TRAIL(I1) = ORF(TRAIL(I1),TWO(I2))        
C        
 1330 GO TO IRETRN, (590,530,610,30,1240,1250,860,37)        
C        
C     OPEN A FILE AND GET THE TRAILER        
C        
 1340 IF (NOGO) GO TO 1350        
      CALL OPEN (*1360,FILE(I),Z(BUFF),OP)        
      OPENFL(I) = 1        
      IF (I .GT. 4) GO TO 1350        
C        
C     WRITE THE HEADER RECORD        
C        
      CALL WRITE (FILE(I),INAME(2*I-1),2,EOR)        
      TRAIL(1) = FILE(I)        
      CALL RDTRL (TRAIL(1))        
C        
 1350 GO TO IRETRN, (890,950,20)        
C        
 1360 CALL PAGE2 (3)        
      IMSG = 1061        
      WRITE  (NOUT,105 ) SFM,IMSG        
      WRITE  (NOUT,1370) FILE(I),INAME(2*I-1),INAME(2*I),IFIST        
 1370 FORMAT (5X,11HFILE NUMBER ,I4,3H ( ,2A4,12H) IS NOT IN ,A4)       
      NOGO = .TRUE.        
      GO TO 1530        
C        
C     CLOSE A FILE        
C        
 1380 IF (OPENFL(I)) 1390,1410,1390        
 1390 IF (I .GT. 4) GO TO 1400        
      CALL WRITE (FILE(I),T65535(1),3,EOR)        
 1400 CALL CLOSE (FILE(I),CLORWD)        
      OPENFL(I) = 0        
      IF (I .GT. 4) GO TO 1410        
      CALL WRTTRL (TRAIL(1))        
 1410 GO TO IRETRN, (880,1060,1530)        
C        
C     HARMONIC NUMBER,  ON CARD TYPE ..... IS OUT OF RANGE 0 TO 998     
C        
 1420 IF (NNN.LT.999 .AND. NNN.GE.0) GO TO IERRTN, (70,460,560,640,810) 
      CALL PAGE2 (3)        
      IMSG = 364        
      WRITE  (NOUT,445 ) UFM,IMSG        
      WRITE  (NOUT,1430) NNN,CDTYPE(2*NCARD-1),CDTYPE(2*NCARD)        
 1430 FORMAT (5X,'HARMONIC NUMBER',I6,4H ON ,2A4,' CARD OUT OF 0 TO ',  
     1       '998 ALLOWABLE RANGE')        
      NOGO = .TRUE.        
      GO TO IERRTN, (70,460,560,640,810)        
C        
C     RING ID OUT PERMISSABLE RANGE OF 1 TO 999999        
C        
 1440 IF (NNN.GT.0 .AND. NNN.LE.999999)        
     1    GO TO IERRTN, (80,180,490,570,650,700,820)        
      CALL PAGE2 (3)        
      IMSG = 365        
      WRITE  (NOUT,445 ) UFM,IMSG        
      WRITE  (NOUT,1450) NNN,CDTYPE(2*NCARD-1),CDTYPE(2*NCARD)        
 1450 FORMAT (5X,'RING ID',I10,4H ON ,2A4,' CARD OUT OF 0 TO 999999',   
     1       ' ALLOWABLE RANGE')        
      NOGO = .TRUE.        
      GO TO IERRTN, (80,180,490,570,650,700,820)        
C        
C     CHECK BIT-IBIT IN TRAILER AND RETURN NON = ZERO OR NON-ZERO       
C        
 1460 I1 = (IBIT-1)/16  +  2        
      I2 = IBIT - (I1-2)*16 + 16        
      NON = ANDF(AXTRL(I1),TWO(I2))        
      GO TO IBITR, (140,150)        
C        
C     WRITE 3 WORD RECORD HEADER        
C        
 1470 IF (NOGO) GO TO 1480        
      CALL WRITE (IFILE,REC(1),3,NOEOR)        
 1480 GO TO IHEADR, (40,170,620,900,28)        
C        
C     END-OF-RECORD ON AXIC FILE.        
C        
 1490 CALL PAGE2 (3)        
      IMSG = 1063        
      WRITE (NOUT,105) SFM,IMSG        
      WRITE (NOUT,480) CDTYPE(2*NCARD-1),CDTYPE(2*NCARD)        
      NOGO = .TRUE.        
      GO TO IERRTN, (1240)        
C        
C     MISSING REQUIRED CARD        
C        
 1510 CALL PAGE2 (3)        
      IMSG = 362        
      WRITE  (NOUT,445 ) UFM,IMSG                                       
      WRITE  (NOUT,1520) CDTYPE(2*NCARD-1),CDTYPE(2*NCARD)        
 1520 FORMAT (5X,'MINIMUM PROBLEM REQUIRES ',2A4,' CARD.  NONE FOUND.') 
      NOGO = .TRUE.        
      GO TO IERRTN, (770)        
C        
C     RETURN TO IFP3        
C        
 1530 RETURN        
C        
C     EOF ENCOUNTERED READING AXIC FILE        
C        
 1540 NFILE = AXIC        
      CALL PAGE2 (3)        
      IMSG = 3002        
      WRITE  (NOUT,105 ) SFM,IMSG        
      WRITE  (NOUT,1560) INAME(11),INAME(12),NFILE        
 1560 FORMAT (5X,'EOF ENCOUNTERED WHILE READING DATA SET ',2A4,' (FILE',
     1        I4,') IN SUBROUTINE IFP3B')        
      NOGO = .TRUE.        
      GO TO 1530        
C        
 1580 CALL PAGE2 (3)        
      IMSG = 363        
      WRITE  (NOUT,445 ) UFM,IMSG        
      WRITE  (NOUT,1590)        
 1590 FORMAT (5X,'INSUFFICIENT CORE TO PROCESS AXIC DATA IN SUBROUTINE',
     1       'IFP3B')        
      NOGO = .TRUE.        
      GO TO 1530        
C        
 1570 I = 5        
      GO TO 1360        
      END        
