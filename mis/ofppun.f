      SUBROUTINE OFPPUN (IBUF,BUF,NWDS,IOPT,IDD,PNCHED)        
C        
C     MAIN OFP PUNCH ROUTINE FOR PUNCHING OF DATA LINES ONLY        
C        
C  $MIXED_FORMATS        
C        
      LOGICAL         TEMPER,PNCHED        
      INTEGER         IBUF(NWDS),VECTOR,ID(50),OF(56)        
      REAL            BUF(NWDS),RID(50)        
      COMMON /SYSTEM/ SYSBUF,L,DUM53(53),ITHERM,DUM34(34),LPCH        
      COMMON /OUTPUT/ HD(96)        
C     COMMON /ZZOFPX/ L1,L2,L3,L4,L5,ID(50)        
CZZ   COMMON /ZZOFPX/ CORE(1)        
      COMMON /ZZZZZZ/ CORE(1)        
      COMMON /BLANK / ICARD        
      COMMON /OFPCOM/ TEMPER, M        
      COMMON /GPTA1 / NELM,LAST,INCR,IE(25,1)        
      EQUIVALENCE     (RID(1),ID(1),OF(6)), (L1,OF(1),CORE(1)),        
     1                (L2,OF(2)), (L3,OF(3)), (L4,OF(4)), (L5,OF(5))    
      DATA    VECTOR, IDTEMP / 1, 0 /        
C        
C        
      IF (.NOT. PNCHED) GO TO 700        
   20 IF (NWDS .LT.  0) GO TO 1710        
C        
C     FIRST CARD OUT        
C        
      ICARD = ICARD + 1        
      IF (IOPT .EQ. VECTOR) GO TO 200        
C        
C     GENERAL 1-ST CARD (FIRST WORD OF BUF ASSUMED INTEGER)        
C        
      N = MIN0(4,NWDS)        
      IF (IDD) 30,90,40        
   30 IF (IDD .EQ. -1) GO TO 90        
   40 GO TO (50,60,70,80), N        
   50 WRITE (LPCH,440,ERR=180) BUF(1),ICARD        
      GO TO 180        
   60 WRITE (LPCH,450,ERR=180) BUF(1),BUF(2),ICARD        
      GO TO 180        
   70 WRITE (LPCH,460,ERR=180) BUF(1),BUF(2),BUF(3),ICARD        
      GO TO 180        
   80 WRITE (LPCH,470,ERR=180) BUF(1),BUF(2),BUF(3),BUF(4),ICARD        
      GO TO 180        
   90 GO TO (100,110,120,130), N        
  100 WRITE (LPCH,400) IBUF(1),ICARD        
      GO TO 180        
  110 WRITE (LPCH,410,ERR=180) IBUF(1),BUF(2),ICARD        
      GO TO 180        
  120 WRITE (LPCH,420,ERR=180) IBUF(1),BUF(2),BUF(3),ICARD        
      GO TO 180        
C        
C     CHECK FOR THERMAL FORCES FOR ISOPARAMETRICS        
C        
  130 IF (ITHERM.EQ.0 .OR. M.NE.4) GO TO 150        
C 130 IF (ITHERM .EQ. 0) GO TO 150        
      IF (ID(3).LT.65 .OR. ID(3).GT.67) GO TO 150        
      WRITE  (LPCH,140) IBUF(1),BUF(2),IBUF(3),BUF(4),ICARD        
  140 FORMAT (I10,8X,A4,14X,I10,8X,1P,E18.6,I8)        
      GO TO 180        
C        
C     CHECK FOR INTEGER IN SECOND ARGUMENT ALSO.        
C        
  150 IF (M .EQ. 19) GO TO 170        
      IF (NUMTYP(BUF(2)) .LE. 1) GO TO 160        
      WRITE (LPCH,430,ERR=180) IBUF(1),BUF(2),BUF(3),BUF(4),ICARD       
      GO TO 180        
  160 WRITE (LPCH,500,ERR=180) IBUF(1),IBUF(2),BUF(3),BUF(4),ICARD      
      GO TO 180        
  170 WRITE (LPCH,510) IBUF(1),IBUF(2),BUF(3),BUF(4),ICARD        
      GO TO 180        
  180 NWORD = 4        
      GO TO 230        
C        
C     VECTOR 1-ST CARD (FIRST WORD INTEGER, SECOND WORD BCD)        
C        
  200 IF (TEMPER) GO TO 280        
C     IF (IDD .NE. 0) GO TO 210        
      IF (IDD.NE.0 .AND. IDD.NE.-1) GO TO 210        
      WRITE (LPCH,520,ERR=220) IBUF(1),BUF(2),BUF(3),BUF(4),BUF(5),ICARD
      GO TO 220        
  210 WRITE (LPCH,530,ERR=220)  BUF(1),BUF(2),BUF(3),BUF(4),BUF(5),ICARD
  220 NWORD = 5        
C        
C     CONTINUATION CARDS IF ANY.        
C        
  230 IF (NWORD .GE. NWDS) GO TO 1710        
      ICARD = ICARD + 1        
      NWORD = NWORD + 3        
      IF (NWORD .LE. NWDS) GO TO 250        
      NWORD = NWORD - 1        
      IF (NWORD .EQ. NWDS) GO TO 240        
      NWORD = NWORD - 1        
C        
C     1 WORD OUT        
C        
      WRITE (LPCH,610,ERR=1710) BUF(NWORD),ICARD        
      GO TO 1710        
C        
C     2 WORDS OUT        
C        
  240 WRITE (LPCH,600,ERR=1710) BUF(NWORD-1),BUF(NWORD),ICARD        
      GO TO 1710        
C        
C     3 WORDS OUT        
C        
  250 IF (IBUF(NWORD-1) .EQ. VECTOR) GO TO 260        
      IF (IBUF(NWORD  ) .EQ. VECTOR) GO TO 270        
      WRITE (LPCH,590,ERR=230) BUF(NWORD-2),BUF(NWORD-1),BUF(NWORD),    
     1                         ICARD        
      GO TO 230        
  260 WRITE (LPCH,620) BUF(NWORD-2),BUF(NWORD),ICARD        
      GO TO 230        
  270 WRITE (LPCH,600) BUF(NWORD-2),BUF(NWORD-1),ICARD        
      GO TO 230        
C        
C     SPECIAL PUNCH ONLY WHEN TEMPER FLAG IS ON IN A -HEAT- FORMULATION.
C        
  280 IC1 = IBUF(1)        
      IF (IDD.EQ.0 .OR. IDD.EQ.-1) GO TO 290        
      IDTEMP = IDTEMP + 1        
      IC1 = IDD        
  290 CONTINUE        
      WRITE  (LPCH,300) IDTEMP,IC1,BUF(3),ICARD        
  300 FORMAT (8HTEMP*    ,I16,I16,1P,E16.6,16X,I8)        
      GO TO 1710        
C        
  400 FORMAT (I10,62X,I8)        
  410 FORMAT (I10,8X,1P,E18.6,36X,I8)        
  420 FORMAT (I10,8X,2(1P,E18.6),18X,I8)        
  430 FORMAT (I10,8X,3(1P,E18.6),I8)        
  440 FORMAT (1P,E18.6,54X,I8)        
  450 FORMAT (2(1P,E18.6),36X,I8)        
  460 FORMAT (3(1P,E18.6),18X,I8)        
  470 FORMAT (4(1P,E18.6),I8)        
C 480 FORMAT (I10,8X,3E18.6,I8)        
C 490 FORMAT (4E18.6,I8)        
  500 FORMAT (I10,8X,I10,8X,2(1P,E18.6),I8)        
  510 FORMAT (I10,8X,I10,8X,2A4,28X,I8)        
  520 FORMAT (I10,7X,A1,3(1P,E18.6),I8)        
  530 FORMAT (1P,E16.6,1X,A1,3(1P,E18.6),I8)        
C 540 FORMAT (I10,7X,A1,3E18.6,I8)        
C 550 FORMAT (E16.6,1X,A1,3E18.6,I8)        
C 560 FORMAT (6H-CONT-,12X,3E18.6,I8)        
C 570 FORMAT (6H-CONT-,12X,2E18.6,18X,I8)        
C 580 FORMAT (6H-CONT-,12X,E18.6,36X,I8)        
  590 FORMAT (6H-CONT-,12X,3(1P,E18.6),I8)        
  600 FORMAT (6H-CONT-,12X,2(1P,E18.6),18X,I8)        
  610 FORMAT (6H-CONT-,12X,1P,E18.6,36X,I8)        
  620 FORMAT (6H-CONT-,12X,1P,E18.6,18X,1P,E18.6,I8)        
C        
C        
C     PUNCH HEADING CARDS        
C        
C        
C     TITLE,SUBTITLE,AND LABEL        
C        
  700 DO 740 I = 1,3        
      ICARD = ICARD + 1        
      GO TO (710,720,730), I        
  710 WRITE (LPCH,750) (HD(J),J= 1,15),ICARD        
      GO TO 740        
  720 WRITE (LPCH,760) (HD(J),J=33,47),ICARD        
      GO TO 740        
  730 WRITE (LPCH,770) (HD(J),J=65,79),ICARD        
  740 CONTINUE        
C        
  750 FORMAT (10H$TITLE   =,15A4,2X,I8)        
  760 FORMAT (10H$SUBTITLE=,15A4,2X,I8)        
  770 FORMAT (10H$LABEL   =,15A4,2X,I8)        
C        
      KTYPE = ID(2)/1000        
      M = ID(2) - (KTYPE)*1000        
      IF (M.LT.1 .OR. M.GT.19) GO TO 1200        
      ICARD = ICARD + 1        
      GO TO (780,790,800 ,810,900,1170,910,1170,1170,920,        
     1       930,940,1170,950,960,970 ,980,990 ,1000), M        
  780 WRITE (LPCH,1010) ICARD        
      GO TO 1200        
  790 WRITE (LPCH,1020) ICARD        
      GO TO 1200        
  800 WRITE (LPCH,1030) ICARD        
      GO TO 1200        
  810 WRITE (LPCH,1040) ICARD        
      GO TO 1200        
C        
C     PUNCH ELEMENT STRESS OR GRID POINT STRESS HEADING LINE        
C        
  900 IF (L2 .NE. 378) WRITE(LPCH,1050) ICARD        
      IF (L2 .EQ. 378) WRITE(LPCH,1060) ICARD        
      GO TO 1200        
  910 WRITE (LPCH,1070) ICARD        
      GO TO 1200        
  920 WRITE (LPCH,1080) ICARD        
      GO TO 1200        
  930 WRITE (LPCH,1090) ICARD        
      GO TO 1200        
  940 WRITE (LPCH,1100) ICARD        
      GO TO 1200        
  950 WRITE (LPCH,1110) ICARD        
      GO TO 1200        
  960 WRITE (LPCH,1120) ICARD        
      GO TO 1200        
  970 WRITE (LPCH,1130) ICARD        
      GO TO 1200        
  980 WRITE (LPCH,1140) ICARD        
      GO TO 1200        
  990 WRITE (LPCH,1150) ICARD        
      GO TO 1200        
 1000 WRITE (LPCH,1160) ICARD        
      GO TO 1200        
C        
 1010 FORMAT (14H$DISPLACEMENTS,58X,I8)        
 1020 FORMAT (7H$OLOADS,65X,I8)        
 1030 FORMAT (5H$SPCF,67X,I8)        
 1040 FORMAT (15H$ELEMENT FORCES,57X,I8)        
 1050 FORMAT (17H$ELEMENT STRESSES,55X,I8)        
 1060 FORMAT (24H$STRESSES AT GRID POINTS,48X,I8)        
 1070 FORMAT (12H$EIGENVECTOR,60X,I8)        
 1080 FORMAT (9H$VELOCITY,63X,I8)        
 1090 FORMAT (13H$ACCELERATION,59X,I8)        
 1100 FORMAT (18H$NON-LINEAR-FORCES,54X,I8)        
 1110 FORMAT (27H$EIGENVECTOR (SOLUTION SET),45X,I8)        
 1120 FORMAT (29H$DISPLACEMENTS (SOLUTION SET),43X,I8)        
 1130 FORMAT (24H$VELOCITY (SOLUTION SET),48X,I8)        
 1140 FORMAT (28H$ACCELERATION (SOLUTION SET),43X,I8)        
 1150 FORMAT (23HELEMENT STRAIN ENERGIES ,49X,I8)        
 1160 FORMAT (24HGRID POINT FORCE BALANCE ,48X,I8)        
 1170 ICARD = ICARD - 1        
C        
C     REAL, REAL/IMAGINARY, MAGNITUDE/PHASE        
C        
 1200 ICARD = ICARD + 1        
      IF (KTYPE.LT.1 .OR. KTYPE.EQ.2) GO TO 1210        
      IF (ID(9).EQ. 3) GO TO 1230        
      GO TO 1220        
 1210 WRITE (LPCH,1240) ICARD        
      GO TO 1300        
 1220 WRITE (LPCH,1250) ICARD        
      GO TO 1300        
C        
 1230 WRITE  (LPCH,1260) ICARD        
 1240 FORMAT (12H$REAL OUTPUT,60X,I8)        
 1250 FORMAT (22H$REAL-IMAGINARY OUTPUT, 50X,I8)        
 1260 FORMAT (23H$MAGNITUDE-PHASE OUTPUT,49X,I8)        
C        
C     SUBCASE NUMBER FOR SORT1 OUTPUT, OR        
C     SUBCASE NUMBER FOR SORT2, FREQUENCY AND TRANSIENT RESPONSE ONLY   
C        
 1300 IF (KTYPE .LE. 1) GO TO 1310        
      IAPP = ID(1)/10        
      IF (IAPP.NE.5 .AND. IAPP.NE.6) GO TO 1400        
 1310 ICARD = ICARD + 1        
      WRITE  (LPCH,1320) ID(4),ICARD        
 1320 FORMAT (13H$SUBCASE ID =,I12,47X,I8)        
C        
C     IF ELEMENT STRESS OR FORCE PUNCH ELEMENT TYPE NUMBER        
C        
 1400 IF (M.NE.4 .AND. M.NE.5) GO TO 1500        
      ICARD = ICARD + 1        
      ID3   = ID(3)        
      IF (L2 .NE. 378) WRITE (LPCH,1410) ID3,IE(1,ID3),IE(2,ID3),ICARD  
      IF (L2 .EQ. 378) WRITE (LPCH,1420) ICARD        
 1410 FORMAT (15H$ELEMENT TYPE =,I12,3X,1H(,2A4,1H),32X,I8)        
 1420 FORMAT (38H$PUNCHED IN MATERIAL COORDINATE SYSTEM,34X,I8)        
C        
C     PUNCH EIGENVALUE, FREQUENCY, POINT OR ELEMENT ID, OR TIME        
C        
 1500 IAPP = ID(1)/10        
      IF (IAPP.LT.1 .OR. IAPP.GT.10) GO TO 1700        
      GO TO (1590,1510,1590,1590,1550,1570,1590,1510,1510,1590), IAPP   
C        
C     PUNCH EIGENVALUE        
C        
 1510 ICARD = ICARD + 1        
      IF (KTYPE .EQ. 1) GO TO 1530        
      WRITE  (LPCH,1520,ERR=1700) RID(6),ID(5),ICARD        
 1520 FORMAT (13H$EIGENVALUE =,E15.7,2X,6HMODE =,I6,30X,I8)        
      GO TO 1700        
 1530 WRITE  (LPCH,1540,ERR=1700) RID(6),RID(7),ID(5),ICARD        
 1540 FORMAT (15H$EIGENVALUE = (,E15.7,1H,,E15.7,8H) MODE =,I6,12X,I8)  
      GO TO 1700        
C        
C     FREQUENCY OR TIME, POINT OR ELEMENT ID        
C        
 1550 IF (KTYPE .GT. 1) GO TO 1590        
      ICARD = ICARD + 1        
      WRITE  (LPCH,1560,ERR=1700) RID(5),ICARD        
 1560 FORMAT (12H$FREQUENCY =,E16.7,44X,I8)        
      GO TO 1700        
 1570 IF (KTYPE .GT. 1) GO TO 1590        
      ICARD = ICARD + 1        
      WRITE  (LPCH,1580,ERR=1700) RID(5),ICARD        
 1580 FORMAT (7H$TIME =,E16.7,49X,I8)        
      GO TO 1700        
 1590 IF (KTYPE .LE. 1) GO TO 1700        
      ICARD = ICARD + 1        
      IF (M.EQ.4 .OR. M.EQ.5) GO TO 1610        
      WRITE  (LPCH,1600) ID(5),ICARD        
 1600 FORMAT (11H$POINT ID =,I12,49X,I8)        
      GO TO 1700        
 1610 WRITE  (LPCH,1620) ID(5),ICARD        
 1620 FORMAT (13H$ELEMENT ID =,I10,49X,I8)        
C        
C     CARD HEADING COMPLETE        
C        
 1700 PNCHED = .TRUE.        
      IF (.NOT.TEMPER) GO TO 20        
C     IF (IDD .EQ. 0) IDTEMP = IDTEMP+1        
C     IF (IDD .NE. 0) IDTEMP = 0        
      IDTEMP = IDTEMP + 1        
      IF (IDD .GT. 0) IDTEMP = 0        
      GO TO 20        
C        
 1710 RETURN        
      END        
