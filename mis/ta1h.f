      SUBROUTINE TA1H        
C        
C     FOR LEVEL 16 A MAJOR REVISION HAS BEEN MADE TO TA1B. THE ECPT AND 
C     GPCT ARE NO LONGER CONTSTRUCTED BUT, INSTEAD, THE GPECT IS BUILT. 
C     THE GPECT IS ESSENTIALLY A TRUNCATED VERSION OF THE OLD ECPT. IT  
C     CONTAINS ONE LOGICAL RECORD FOR EACH GRID OR SCALAR POINT IN THE  
C     MODEL. EACH LOGICAL RECORD CONTAINS THE CONNECTION DATA FOR EACH  
C     ELEMENT CONNECTED TO THE GRID POINT.        
C        
      EXTERNAL        ANDF        
      INTEGER         GENL  ,ECT   ,EPT   ,BGPDT ,SIL   ,GPTT  ,CSTM  , 
     1                EST   ,GEI   ,ECPT  ,GPCT  ,SCR1  ,SCR2  ,SCR3  , 
     2                SCR4  ,Z     ,SYSBUF,TEMPID,ELEM  ,TEMPSZ,ELEMID, 
     3                OUTPT ,RD    ,RDREW ,WRT   ,WRTREW,CLSREW,CLS   , 
     4                BUF   ,FLAG  ,BUF1  ,BUF2  ,BUF3  ,OP    ,TWO24 , 
     5                SCRI  ,SCRO  ,BLK   ,OUFILE,ANDF  ,OUT(3),GPECT , 
     6                EQEXIN        
      DIMENSION       BUF(50)      ,BUFR(50)     ,NAM(2),BLK(2),ZZ(1)   
      COMMON /BLANK / LUSET ,NOSIMP,NOSUP ,NOGENL,GENL  ,COMPS        
      COMMON /TA1COM/ NSIL  ,ECT   ,EPT   ,BGPDT ,SIL   ,GPTT  ,CSTM  , 
     1                MPT   ,EST   ,GEI   ,GPECT ,ECPT  ,GPCT  ,MPTX  , 
     2                PCOMPS,EPTX  ,SCR1  ,SCR2  ,SCR3  ,SCR4  ,EQEXIN  
      COMMON /SYSTEM/ KSYSTM(65)        
      COMMON /GPTA1 / NELEM ,JLAST ,INCR  ,ELEM(1)        
      COMMON /NAMES / RD    ,RDREW ,WRT   ,WRTREW,CLSREW,CLS        
      COMMON /TA1AB / TEMPSZ        
CZZ   COMMON /ZZTAA2/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      EQUIVALENCE     (KSYSTM( 1),SYSBUF) ,(KSYSTM(2),OUTPT),        
     1                (KSYSTM(10),TEMPID) ,(BUF(1),BUFR(1)) ,        
     2                (Z(1),ZZ(1))        ,(BLK(2),N)        
      DATA    NAM   / 4HTA1H, 4H    /     ,TWO24  / 4194304 /        
C        
C     PERFORM GENERAL INITIALIZATION        
C        
      N2   = 2*NELEM - 1        
      N21  = N2 + 1        
      BUF1 = KORSZ(Z) - SYSBUF - 2        
      BUF2 = BUF1 - SYSBUF        
      BUF3 = BUF2 - SYSBUF        
      NEQ1 = NSIL + 1        
      NEQ2 = 0        
C        
C     THE GRID POINT COUNTER(GPC)HAS ONE ENTRY PER GRID OR SCALAR POINT 
C     IN THE STRUCTURE. EACH ENTRY CONTAINS THE NUMBER OF STRUCTURAL    
C     ELEMENTS CONNECTED TO THE POINT.        
C        
      DO 2001 I = 1,NSIL        
 2001 Z(I+1) = 0        
C        
C     OPEN THE ECT. INITIALIZE TO LOOP THRU BY ELEMENT TYPE.        
C        
      FILE = ECT        
      CALL GOPEN (ECT,Z(BUF1),RDREW)        
      NOECT = 1        
C        
C     IGNORE PLOTEL AND REACT ELEMENTS. OTHERWISE, LOCATE AN ELEMENT    
C     TYPE. IF PRESENT, READ ALL ELEMENTS OF THAT TYPE AND INCREMENT    
C     THE GPC ENTRY FOR EACH POINT TO WHICH THE ELEMENT IS CONNECTED.   
C        
 2012 CALL ECTLOC (*2026,ECT,BUF,I)        
      NOECT = 0        
      LX = ELEM(I+12)        
      MM = LX+ELEM(I+9) - 1        
      M  = ELEM(I+5)        
 2021 CALL READ (*3201,*2012,ECT,BUF,M,0,FLAG)        
      DO 2022 L = LX,MM        
      K  = BUF(L)        
      IF (K .NE. 0) Z(K+1) = Z(K+1) + 1        
 2022 CONTINUE        
      GO TO 2021        
 2026 CONTINUE        
      IF (NOECT .NE. 0) GO TO 3209        
C        
C     REPLACE ENTRIES IN THE GPC BY A RUNNING SUM        
C     THUS CREATING POINTERS INTO ECPT0        
C     QUEUE WARNING MESSAGES FOR GRID PTS. WITH NO ELEMENTS CONNECTED.  
C        
      Z(1)  = 1        
      MAXEL = 0        
      DO 2037 I = 1,NSIL        
      MAXEL = MAX0(MAXEL,Z(I+1))        
      IF (Z(I+1) .NE. 0) GO TO 2037        
C        
      J = 0        
      IF (NEQ2) 2035,2031,2033        
 2031 NEQ2 = -1        
      Z(NEQ1) = EQEXIN        
      CALL RDTRL (Z(NEQ1))        
      IF (Z(NEQ1) .LE. 0) GO TO 2035        
      FILE = EQEXIN        
      CALL GOPEN (EQEXIN,Z(BUF2),RDREW)        
      CALL READ (*3200,*2032,EQEXIN,Z(NEQ1),BUF3,1,NEQ2)        
 2032 CALL CLOSE (EQEXIN,CLSREW)        
      CALL SORT (0,0,2,2,Z(NEQ1),NEQ2)        
 2033 J = Z((I-1)*2+NEQ1)        
C        
 2035 BUF(1) = I        
      BUF(2) = J        
      CALL MESAGE (30,15,BUF)        
 2037 Z(I+1) = Z(I) + Z(I+1)        
C        
C     DETERMINE BAND OF ENTRIES IN ECPT0 WHICH WILL FIT IN CORE        
C     NDX1 = POINTER IN GPC TO 1ST  ENTRY FOR CURRENT PASS.        
C     NDX2 = POINTER IN GPC TO LAST ENTRY FOR CURRENT PASS.        
C        
      NDX1 = 1        
      NDX2 = NSIL        
      LLX  = 1        
      IECPT0 = NSIL + 2        
      LENGTH = BUF1 - IECPT0        
      OP = WRTREW        
 2042 IF (Z(NDX2+1)-Z(NDX1)+2 .LE. LENGTH) GO TO 2050        
      NDX2 = NDX2 - 1        
      GO TO 2042        
C        
C     PASS THE ECT. FOR EACH GRID PT IN RANGE ON THIS PASS,        
C     STORE ELEMENT POINTER = 2**K * J + WORD POSITION IN ECT RECORD    
C     WHERE K=22 FOR LEVEL 16 AND J = ENTRY NBR OF ELEMENT IN /GPTA1/   
C     (WHICH IS SAME AS ELEMENT TYPE AS OF LEVEL 15)        
C        
 2050 FILE = ECT        
      CALL GOPEN (ECT,Z(BUF1),RDREW)        
      IZERO = Z(NDX1)        
 2051 CALL ECTLOC (*2059,ECT,BUF,I)        
      J  = (I-1)/INCR + 1        
      IDCNTR = TWO24*J        
      M  = ELEM(I+5)        
      LX = ELEM(I+12)        
      MM = LX + ELEM(I+9) - 1        
 2052 CALL READ (*3201,*2051,ECT,BUF,M,0,FLAG)        
      DO 2054 L = LX,MM        
      K  = BUF(L)        
      IF (K.LT.NDX1 .OR. K.GT.NDX2) GO TO 2054        
      IX = Z(K) - IZERO + IECPT0        
      Z(IX) = IDCNTR        
      Z(K)  = Z(K) + 1        
 2054 CONTINUE        
      IDCNTR = IDCNTR + M        
      GO TO 2052        
 2059 CONTINUE        
C        
C     WRITE ECPT0 AND TEST FOR ADDITIONAL PASSES        
C     ECPT0 CONTAINS ONE LOGICAL RECORD FOR EACH GRID OR SCALAR POINT.  
C     EACH LOGICAL RECORD CONTAINS N PAIRS OF(-1,ELEMENT POINTER)WHERE  
C     N= NUMBER OF ELEMENTS CONNECTED TO THE PIVOT.        
C     IF NO ELEMENTS CONNECTED TO POINT, RECORD IS ONE WORD = 0.        
C        
      FILE = SCR1        
      CALL OPEN (*3200,SCR1,Z(BUF1),OP)        
      ELEMID =  1        
      BUF(1) = -1        
      LJ = IECPT0 - 1        
      DO 2062 I = NDX1,NDX2        
      M  = Z(I) - LLX        
      IF (M .NE. 0) GO TO 2063        
      CALL WRITE (SCR1,0,1,1)        
      GO TO 2062        
 2063 DO 2061 J = 1,M        
      LJ = LJ + 1        
      BUF(2) = Z(LJ)        
 2061 CALL WRITE (SCR1,BUF,2,0)        
      CALL WRITE (SCR1,0,0,1)        
 2062 LLX = Z(I)        
      IF (NDX2 .GE. NSIL) GO TO 2070        
      CALL CLOSE (SCR1,CLS)        
      NDX1 = NDX2 + 1        
      NDX2 = NSIL        
      OP   = WRT        
      GO TO 2042        
C        
C     READ AS MUCH OF ECT AS CORE CAN HOLD        
C     FIRST N21 CELLS OF CORE CONTAIN A POINTER TABLE WHICH HAS TWO     
C     ENTRIES PER ELEMENT TYPE. 1ST ENTRY HAS POINTER TO 1ST WORD OF    
C     ECT DATA IN CORE FOR AN ELEMENT TYPE  2ND ENTRY HAS WORD POSITION 
C     IN ECT RECORD OF THAT TYPE FOR LAST ENTRY READ ON PREVIOUS PASS.  
C        
 2070 CALL CLOSE (SCR1,CLSREW)        
      SCRI = SCR1        
      SCRO = SCR2        
      FILE = ECT        
      CALL GOPEN (ECT,Z(BUF1),RDREW)        
      DO 2071 J = 1,N21        
 2071 Z(J) = 0        
      L = N21 + 1        
 2072 CALL ECTLOC (*2080,ECT,BUF,IELEM)        
      I = 2*((IELEM-1)/INCR + 1) - 1        
      Z(I) = L        
      LL   = 0        
      M    = ELEM(IELEM+5)        
      LAST = BUF3-M        
 2073 IF (L .GT. LAST) GO TO 2080        
      CALL READ (*3201,*2074,ECT,Z(L),M,0,FLAG)        
      Z(L)   = ELEMID        
      ELEMID = ELEMID +1        
      L  = L  + M        
      LL = LL + M        
      GO TO 2073        
 2074 CONTINUE        
      GO TO 2072        
C        
C     PASS ECPT0 ENTRIES LINE BY LINE        
C     ATTACH EACH REFERENCED ECT ENTRY WHICH IS NOW IN CORE        
C        
 2080 FILE = SCRI        
      CALL OPEN (*3200,SCRI,Z(BUF2),RDREW)        
      CALL OPEN (*3200,SCRO,Z(BUF3),WRTREW)        
 2082 CALL READ (*2090,*2086,SCRI,BUF,1,0,FLAG)        
      IF (BUF(1)) 2083,2087,2085        
 2083 CALL READ (*3201,*3202,SCRI,BUF(2),1,0,FLAG)        
      KHR = BUF(2)/TWO24        
      KTWO24 = KHR*TWO24        
      K  = 2*KHR - 1        
      IDPTR = BUF(2) - KTWO24        
      KK = Z(K) + IDPTR - Z(K+1)        
      IF (Z(K).EQ.0 .OR. KK.GT.LAST) GO TO 2084        
      J  = (KHR-1)*INCR + 1        
      MM = ELEM(J+5)        
      BUF(1) = MM        
      BUF(2) = ANDF(Z(KK),TWO24-1) + KTWO24        
      CALL WRITE (SCRO,BUF,2,0)        
      CALL WRITE (SCRO,Z(KK+1),MM-1,0)        
      GO TO 2082        
 2084 CALL WRITE (SCRO,BUF,2,0)        
      GO TO 2082        
 2085 CALL READ  (*3201,*3202,SCRI,BUF(2),BUF(1),0,FLAG)        
      CALL WRITE (SCRO,BUF,BUF(1)+1,0)        
      GO TO 2082        
 2086 CALL WRITE (SCRO,0,0,1)        
      GO TO 2082        
 2087 CALL WRITE (SCRO,0,1,1)        
      CALL FWDREC (*3201,SCRI)        
      GO TO 2082        
C        
C     TEST FOR COMPLETION OF STEP        
C     IF INCOMPLETE, SET FOR NEXT PASS        
C        
 2090 CALL CLOSE (SCRI,CLSREW)        
      CALL CLOSE (SCRO,CLSREW)        
      IF (IELEM .EQ. 0) GO TO 2100        
      K = SCRI        
      SCRI = SCRO        
      SCRO = K        
      L = N21 + 1        
      DO 2091 J = 1,N21        
 2091 Z(J) = 0        
      Z(I) = L        
      Z(I+1) = LL        
      GO TO 2073        
C        
C     READ THE SIL INTO CORE. OPEN ECPT0 AND GPECT.        
C     WRITE HEADER RECORD ON GPECT - 3RD WORD = NO OF ENTRIES IN /GPTA1/
C        
 2100 FILE = SIL        
      CALL GOPEN (SIL,Z(BUF1),RDREW)        
      CALL FREAD (SIL,Z,NSIL,1)        
      Z(NSIL+1) = LUSET + 1        
      CALL CLOSE (SIL,CLSREW)        
      INFILE = SCRO        
      OUFILE = GPECT        
      MAXDOF = 0        
      FILE   = INFILE        
      CALL OPEN (*3200,INFILE,Z(BUF1),RDREW)        
      CALL OPEN (*3200,OUFILE,Z(BUF2),WRTREW)        
      CALL FNAME (OUFILE,BUF)        
      BUF(3) = NELEM        
      CALL WRITE (OUFILE,BUF,3,1)        
C        
C     PASS ECPT0 LINE BY LINE. FOR EACH LINE -        
C     1. CONVERT GRID NBRS TO SIL VALUES        
C     2. SORT SIL NBRS AND DISCARD MISSING ONES        
C     3. WRITE LINE ON GPECT        
C        
      DO 2158 LL = 1,NSIL        
C        
C     WRITE SIL AND DOF FOR PIVOT        
C        
      BUF(1) = Z(LL)        
      BUF(2) = Z(LL+1) - Z(LL)        
      CALL WRITE (OUFILE,BUF,2,0)        
C        
C     READ AN ECT LINE FROM ECPT0. SET POINTERS AS A FUNCTION OF ELEM   
C     TYPE.        
C        
 2140 CALL READ (*3201,*2154,INFILE,BUF,1,0,FLAG)        
      IF (BUF(1)) 3207, 2150, 2142        
 2142 CALL READ (*3201,*3202,INFILE,BUF(2),BUF(1),0,FLAG)        
      KHR   = BUF(2)/TWO24        
      IELEM = (KHR-1)*INCR + 1        
      NGRIDS= ELEM(IELEM+9)        
      IGR1  = ELEM(IELEM+12) + 1        
      IGR2  = IGR1 + NGRIDS - 1        
      MAXEL = 0        
C        
C     CONVERT GRID NUMBERS TO SIL VALUES. DISCARD ANY MISSING (ZERO)    
C     GRID POINTS THEN SORT LIST ON SIL VALUE        
C        
      DO 2146 II = IGR1,IGR2        
      K = BUF(II)        
      IF (K .NE. 0) GO TO 2145        
      BUF(II) = 2147483647        
      NGRIDS  = NGRIDS - 1        
      GO TO 2146        
 2145 BUF(II) = Z(K)        
      MAXEL   = MAX0(MAXEL,Z(K+1)-Z(K))        
 2146 CONTINUE        
      CALL SORT (0,0,1,1,BUF(IGR1),ELEM(IELEM+9))        
      MAXDOF = MAX0(MAXDOF,NGRIDS*MAXEL)        
C        
C     WRITE A LINE ON GPECT.        
C     - NUMBER OF WORDS IN ENTRY (NOT INCLUDING THIS WORD)        
C       ELEMENT ID        
C       ELEMENT TYPE        
C       THE SORTED SIL LIST FOR THE GRID POINTS        
C        
      OUT(1) = -(NGRIDS+2)        
      OUT(2) = BUF(2) - KHR*TWO24        
      OUT(3) = ELEM(IELEM+2)        
      CALL WRITE (OUFILE,OUT,3,0)        
      CALL WRITE (OUFILE,BUF(IGR1),NGRIDS,0)        
      GO TO 2140        
C        
C     HERE IF NO ELEMENTS CONNECTED TO PIVOT.        
C        
 2150 CALL WRITE (OUFILE,0,0,1)        
      CALL FWDREC (*3202,INFILE)        
      GO TO 2158        
C        
C     HERE WHEN ALL ELEMENTS COMPLETE FOR CURRENT PIVOT        
C        
 2154 CALL WRITE (OUFILE,0,0,1)        
 2158 CONTINUE        
C        
C     CLOSE FILES, WRITE TRAILER AND RETURN.        
C        
      CALL CLOSE (INFILE,CLSREW)        
      CALL CLOSE (OUFILE,CLSREW)        
      BUF(1) = OUFILE        
      BUF(2) = NELEM        
      BUF(3) = NSIL        
      BUF(4) = MAXEL        
      BUF(5) = MAXDOF        
      BUF(6) = 0        
      BUF(7) = 0        
      CALL WRTTRL (BUF)        
      RETURN        
C        
C     FATAL ERROR MESAGES        
C        
 3200 J = -1        
      GO TO 3220        
 3201 J = -2        
      GO TO 3220        
 3202 J = -3        
      GO TO 3220        
 3207 BUF(1) = 0        
      BUF(2) = 0        
      CALL MESAGE (-30,14,BUF)        
 3209 BUF(1) = 0        
      BUF(2) = 0        
      CALL MESAGE (-30,13,BUF)        
      BUF(1) = TEMPID        
      BUF(2) = 0        
      N = 44        
      GO TO 3219        
 3219 CALL MESAGE (-30,N,BUF)        
 3220 CALL MESAGE (J,FILE,NAM)        
      RETURN        
      END        
