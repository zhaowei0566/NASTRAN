      SUBROUTINE MERGE (IRP,ICP,CORE)        
C        
C     MERGE WILL PUT UP TO 4 MATRICES, IA11,IA21,IA12,IA22, TOGETHER    
C     INTO NAMEA -- THIS ROUTINE IS THE INVERSE OF PARTN        
C        
C     THE ARGUMENTS ARE EXACTLY THE SAME IN MEANING AND OPTION AS FOR   
C     PARTITION        
C        
      IMPLICIT INTEGER (A-Z)        
      EXTERNAL        RSHIFT,ANDF        
      DIMENSION       IRP(1),ICP(1),A11(4),B11(4),        
     1                CORE(1),BLOCK(40),NAME(2)        
      COMMON /PARMEG/ NAMEA,NCOLA,NROWA,IFORMA,ITYPA,IA(2),        
     1                IA11(7,4),LCARE,RULE        
      COMMON /SYSTEM/ SYSBUF,NOUT
      COMMON /TWO   / TWO1(32)        
      COMMON /ZBLPKX/ IC11(4),II        
      DATA    NAME  / 4HMERG,4HE    /        
C        
C     CHECK FILES        
C        
      LCORE = IABS(LCARE)        
      K = NAMEA        
      DO 15 I = 1,4        
      IF (K .EQ. 0) GO TO 15        
      DO 10 J = I,4        
      IF (IA11(1,J) .EQ. K) GO TO 440        
   10 CONTINUE        
   15 K = IA11(1,I)        
C        
C     PICK UP PARAMETERS AND INITIALIZE        
C        
      IREW  = 0        
      IF (LCARE .LT. 0) IREW = 2        
      NCOLA1= NCOLA        
      NCOLA = 0        
      IA(1) = 0        
      IA(2) = 0        
      ISTOR = 0        
      IOTP  = ITYPA        
      NMAT  = 0        
      DO 30 I = 1,4        
      IF (IA11(1,I) .LE. 0) GO TO 30        
      IF (IA11(5,I) .NE. ITYPA) IOTP = 4        
      NMAT = NMAT + 1        
      DO 20 J = 2,5        
      IF (IA11(J,I) .EQ. 0) GO TO 460        
   20 CONTINUE        
   30 CONTINUE        
      NTYPA = IOTP        
      IF (NTYPA .EQ. 3) NTYPA = 2        
      IBUF   = LCORE - SYSBUF + 1        
      IBUFCP = IBUF - NROWA        
      IF (IBUFCP) 420,420,40        
   40 LCORE = IBUFCP - 1        
      CALL RULER (RULE,ICP,ZCPCT,OCPCT,CORE(IBUFCP),NROWA,CORE(IBUF),1) 
      IF (IRP(1).EQ.ICP(1) .AND. IRP(1).NE.0) GO TO 60        
      IBUFRP = IBUFCP - (NCOLA1+31)/32        
      IF (IBUFRP) 420,420,50        
   50 CALL RULER (RULE,IRP,ZRPCT,ORPCT,CORE(IBUFRP),NCOLA1,CORE(IBUF),0)
      LCORE = IBUFRP - 1        
      GO TO 70        
   60 ISTOR = 1        
C        
C     OPEN INPUT FILES        
C        
   70 IF (LCORE-NMAT*SYSBUF .LT. 0) GO TO 420        
      DO 100 I = 1,4        
      IF (IA11(1,I)) 90,100,80        
   80 LCORE = LCORE - SYSBUF        
      CALL OPEN (*90,IA11(1,I),CORE(LCORE+1),IREW)        
      CALL SKPREC (IA11(1,I),1)        
      GO TO 100        
   90 IA11(1,I) = 0        
  100 CONTINUE        
C        
C     OPEN OUTPUT FILE        
C        
      CALL GOPEN (NAMEA,CORE(IBUF),1)        
C        
C     FIX POINTERS -- SORT ON ABS VALUE        
C        
      K = IBUFCP - 1        
      L = IBUFCP        
      DO 120 I = 1,NROWA        
      K = K + 1        
      IF (CORE(K)) 110,120,120        
  110 CORE(L) = I        
      L = L + 1        
  120 CONTINUE        
      M = L - 1        
      K = IBUFCP        
      DO 160 I = 1,NROWA        
  130 IF (CORE(K)-I) 150,160,140        
  140 CORE(L) = I        
      L = L + 1        
      GO TO 160        
  150 IF (K .EQ. M) GO TO 140        
      K = K + 1        
      GO TO 130        
  160 CONTINUE        
C        
C     LOOP ON COLUMNS OF OUTPUT        
C        
      KM = 0        
      L2 = IBUFCP        
      L3 = IBUFCP + ZCPCT        
      DO 390 LOOP = 1,NCOLA1        
      CALL BLDPK (IOTP,ITYPA,NAMEA,0,0)        
      IF (ISTOR .EQ. 1) GO TO 190        
      J  = (LOOP-1)/32 + IBUFRP        
      KM = KM + 1        
      IF (KM .GT. 32) KM = 1        
      ITEMP = ANDF(CORE(J),TWO1(KM))        
      IF (KM .EQ. 1) ITEMP = RSHIFT(ANDF(CORE(J),TWO1(KM)),1)        
      IF (ITEMP .NE. 0) GO TO 180        
C        
C     IA11 AND IA21 BEING USED        
C        
  170 L1 = 0        
      IF (L2 .EQ. L3-1) GO TO 200        
      L2 = L2 + 1        
      GO TO 200        
C        
C     IA12 AND IA22 BEING USED        
C        
  180 L1 = 2        
      L3 = L3 + 1        
      GO TO 200        
C        
C     USE ROW STORE        
C        
  190 IF (CORE(L2) .EQ. LOOP) GO TO 170        
      IF (CORE(L3) .EQ. LOOP) GO TO 180        
      GO TO 460        
C        
C     BEGIN ON SUBMATRICES        
C        
  200 IO = 0        
      DO 220 J = 1,2        
      K = L1 + J        
      IF (IA11(1,K)) 210,220,210        
  210 M = 20*J - 19        
      CALL INTPK (*220,IA11(1,K),BLOCK(M),IOTP,1)        
      IO = IO + J        
  220 CONTINUE        
      IF (IO) 230,380,230        
C        
C     PICK UP NON ZERO        
C        
  230 IEOL = 0        
      JEOL = 0        
      IPOS = 9999999        
      JPOS = 9999999        
      IAZ  = 1        
      IBZ  = 1        
      NAM1 = IA11(1,L1+1)        
      NAM2 = IA11(1,L1+2)        
      IF (IO-2) 240,280,240        
  240 IAZ  = 0        
  250 IF (IEOL) 370,260,370        
  260 CALL INTPKI (A11(1),I,NAM1,BLOCK(1),IEOL)        
      K    = IBUFCP + I - 1        
      IPOS = CORE(K)        
      IF (IO .EQ. 1) GO TO 310        
      IO   = 1        
  280 IBZ  = 0        
  290 IF (JEOL) 340,300,340        
  300 CALL INTPKI (B11(1),J,NAM2,BLOCK(21),JEOL)        
      K = IBUFCP + ZCPCT + J - 1        
      JPOS = CORE(K)        
  310 IF (IPOS-JPOS) 350,320,320        
C        
C     PUT IN B11        
C        
  320 DO 330 M = 1,NTYPA        
  330 IC11(M) = B11(M)        
      II = JPOS        
      CALL ZBLPKI        
      GO TO 290        
  340 JPOS = 9999999        
      IBZ  = 1        
      IF (IAZ+IBZ .EQ. 2) GO TO 380        
  350 DO 360 M = 1,NTYPA        
  360 IC11(M) = A11(M)        
      II = IPOS        
      CALL ZBLPKI        
      GO TO 250        
  370 IAZ  = 1        
      IPOS = 9999999        
      IF (IAZ+IBZ .NE. 2) GO TO 320        
C        
C     OUTPUT COLUMN        
C        
  380 CALL BLDPKN (NAMEA,0,NAMEA)        
C        
  390 CONTINUE        
C        
C     DONE -- CLOSE OPEN MATRICES        
C        
      DO 400 I = 1,4        
      IF (IA11(1,I) .GT. 0) CALL CLOSE (IA11(1,I),1)        
  400 CONTINUE        
      CALL CLOSE (NAMEA,1)        
      GO TO 500        
C        
  420 MN = -8        
      GO TO 480        
  440 WRITE  (NOUT,450) K        
  450 FORMAT ('0*** SYSTEM OR USER ERROR, DUPLICATE GINO FILES AS ',    
     1        'DETECTED BY MERGE ROUTINE - ',I5)        
      NM = -37        
      GO  TO 480        
  460 MN = -7        
  480 CALL MESAGE (MN,0,NAME)        
C        
  500 RETURN        
      END        
