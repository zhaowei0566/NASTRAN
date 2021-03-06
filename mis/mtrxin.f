      SUBROUTINE MTRXIN        
C        
C     TWO CAPABILITIES -        
C        
C     (1) TO PROVIDE DIRECT INPUT MATRICES CAPABILITY, IN DYNAMIC RIGID 
C         FORMATS, AND        
C     (2) TO CONVERT DMIG TYPE MATRICES TO NASTRAN MATRIX FORMAT.       
C        
C     REVISED  1/90 BY G.CHAN/UNISYS        
C     NO INTEGER ROW AND COLUMN PACKING FOR 32-BIT WORD MACHINE, AND    
C     REAL AND COMPLEX DMIG MATRIX GENERATION FROM DMIG INPUT CARDS     
C     WITH DOUBLE PRECISION DATA        
C        
      IMPLICIT INTEGER (A-Z)        
      EXTERNAL         ORF,LSHIFT,RSHIFT,ANDF        
      LOGICAL          PACK        
      REAL             X,ALPHA(4),BETA(4),BUFR(13)        
      DOUBLE PRECISION XD(2),BUFD(2)        
      DIMENSION        BUF(20),MCB(50),DMIG(2),NAM(2),BLOCK(81),DB(13), 
     1                 FILEI(3),BUFI(3),FILEA(7),FILEB(7),FILEC(7)      
      CHARACTER        UFM*23        
      COMMON /XMSSG /  UFM        
      COMMON /MACHIN/  MACH,IHALF,JHALF        
      COMMON /BLANK /  LUSET,NOMAT(3)        
CZZ  1       /ZZMTRX/  Z(1)        
     1       /ZZZZZZ/  Z(1)        
     2       /SYSTEM/  SYSBUF,NOUT,XX(5),LOADNN        
     3       /TYPE  /  PRC(2),NWDS(4)        
     4       /ZBLPKX/  X(4),ROW        
     5       /NAMES /  RD,RDREW,WRT,WRTREW,CLSREW        
     6       /SETUP /  IFILE(6)        
     7       /SADDX /  NOMATS,NZ,MCBS(67)        
      EQUIVALENCE      (BUF(1)  ,BUFR(1) ), (X(1)    ,XD(1)   ),        
     1                 (FILEI(1),FILE1   ), (FILEI(2),FILE2   ),        
     2                 (BUFI(1) ,BUF3    ), (BUFI(2) ,BUF4    ),        
     3                 (NOMAT(1),NOMAT1  ), (NOMAT(2),NOMAT2  ),        
     4                 (FILEI(3),FILE3   ), (BUFI(3) ,BUF5    ),        
     5                 (NOMAT(3),NOMAT3  ), (BUFD(1) ,DB(13)  ),        
     6                 (BUF(1)  ,DB(2)   )        
      EQUIVALENCE      (MCBS( 1),FILEA(1)), (MCBS( 8),TYPALP  ),        
     1                 (MCBS( 9),ALPHA(1)), (MCBS(13),FILEB(1)),        
     2                 (MCBS(20),TYPBET  ), (MCBS(21),BETA(1) ),        
     3                 (MCBS(61),FILEC(1))        
      DATA    MCB   /  201   ,9*0   ,202   ,9*0   ,203   ,29*0  /,      
     1        CASECC,  MPOOL ,EQEX  ,TFPOOL                     /       
     2        101   ,  102   ,103   ,105                        /,      
     3        SCR1  ,  SCR2  ,SCR3  ,SCR4  ,SCR5  ,SCR6  ,SCR7  /       
     4        301   ,  302   ,303   ,304   ,305   ,306   ,307   /,      
     5        BLOCK /  81*0         /,        
     6        NAM   /  4HMTRX,4HIN  /,        
     7        DMIG  /  114   ,1     /,        
     8        NFILES/  21           /,        
     9        IMAT1 ,  IMAT2 ,IMAT3 ,ITF /  139,   141,  143, 15/       
C        
C     PERFORM GENERAL INITIALIZATION        
C        
      BUF1  = KORSZ(Z) - SYSBUF - 2        
      BUF2  = BUF1 - SYSBUF        
      BUF3  = BUF2 - SYSBUF        
      BUF4  = BUF3 - SYSBUF        
      BUF5  = BUF4 - SYSBUF        
      NOMAT1= -1        
      NOMAT2= -1        
      NOMAT3= -1        
      MASK16= JHALF        
C        
C     IF MACHINE IS MORE THEN 32 BITS PER WORD, WE USE PACKING LOGIC    
C     OTHERWISE, WE DO NOT PACK ROW AND COLUMN INDICES INTO ONE WORD    
C        
      PACK  = .FALSE.        
      IF (IHALF .GT. 16) PACK = .TRUE.        
      DO 12 I = 1,NFILES,10        
      J1 = I + 1        
      JN = I + 9        
      DO 11 J = J1,JN        
      MCB(J)  = 0        
   11 CONTINUE        
   12 CONTINUE        
      TFSET   = 0        
      TYPALP  = 1        
      ALPHA(1)= 1.0        
      TYPBET  = 1        
      BETA(1) = 1.0        
      NOGO    = 0        
C        
C     OPEN MPOOL. IF PURGED, SET FLAG.        
C        
      FILE   = MPOOL        
      NOMPOO = 0        
      NODMIG = 0        
      CALL PRELOC (*30,Z(BUF1),MPOOL)        
      NOMPOO = 1        
      CALL LOCATE (*30,Z(BUF1),DMIG,FLAG)        
      NODMIG = 1        
C        
C     READ CASE CONTROL RECORD.        
C     SET NAMES OF REQUESTED MATRICES.        
C     IF CASE CONTROL IS PURGED, SET NAMES OF REQUESTED MATRICES EQUAL  
C     NAMES OF OUTPUT DATA BLOCKS.        
C        
   30 FILE = CASECC        
      CALL OPEN (*90,CASECC,Z(BUF2),RDREW)        
      CALL FWDREC (*680,CASECC)        
      CALL READ (*650,*50,CASECC,Z,BUF2,1,FLAG)        
      CALL MESAGE (-8,0,NAM)        
   50 CONTINUE        
      CALL CLOSE (CASECC,CLSREW)        
      TFSET = Z(ITF)        
      IF (Z(IMAT1) .EQ. 0) GO TO 70        
      NOMAT1 = 1        
      MCB(8) = Z(IMAT1  )        
      MCB(9) = Z(IMAT1+1)        
   70 IF (Z(IMAT2) .EQ. 0) GO TO 80        
      NOMAT2  = 1        
      MCB(18) = Z(IMAT2  )        
      MCB(19) = Z(IMAT2+1)        
   80 IF (Z(IMAT3) .EQ. 0) GO TO 110        
      NOMAT3  = 1        
      MCB(28) = Z(IMAT3  )        
      MCB(29) = Z(IMAT3+1)        
      GO TO 110        
   90 DO 100 I = 1,21,10        
      MCB(31)  = MCB(I)        
      CALL RDTRL (MCB(31))        
      IF (MCB(31) .EQ. MCB(I)) CALL FNAME (MCB(31),MCB(I+7))        
  100 CONTINUE        
      GO TO 290        
C        
C     IF TRANSFER FUNCTION MATRICES EXIST, BUILD THEM IN MATRIX FORMAT. 
C     WRITE THEM ON 201,202,203 IF NO DMIG MATRICES TO ADD, OTHERWISE,  
C     WRITE THEM ON SCR5,SCR6,SCR7.        
C     IF NO TRANSFER FUNCTION MATRICES AND NO DMIG MATRICES, EXIT.      
C        
  110 IF (NOMAT1+NOMAT2+NOMAT3 .EQ. -3) GO TO 114        
      IF (NODMIG) 116,630,116        
  114 NODMIG = 0        
  116 IF (NODMIG.EQ.0 .AND. TFSET.EQ.0) GO TO 650        
      IF (TFSET .EQ. 0) GO TO 290        
      FILE1 = SCR5        
C        
C     TEST FOR PURGED OUTPUT DATA BLOCKS.        
C        
      DO 102 I = 1,21,10        
  102 CALL RDTRL (MCB(I))        
      IF (NOMAT1 .EQ. -1) FILE1 = MCB( 1)        
      FILE2 = SCR7        
      IF (NOMAT3 .EQ. -1) FILE2 = MCB(21)        
      FILE3 = SCR6        
      IF (NOMAT2 .EQ. -1) FILE3 = MCB(11)        
      NOMAT1 = 1        
      NOMAT2 = 1        
      NOMAT3 = 1        
C        
C     OPEN TFPOOL AND POSITION TO REQUESTED SET.        
C     IF SET NOT IN TFPOOL, QUEUE MESSAGE AND TURN ON NOGO FLAG.        
C        
      FILE = TFPOOL        
      CALL OPEN (*140,TFPOOL,Z(BUF2),RDREW)        
  130 CALL FWDREC (*140,TFPOOL)        
      CALL READ (*140,*140,TFPOOL,BUF,1,0,FLAG)        
      IF (BUF(1) .EQ. TFSET) GO TO 150        
      GO TO 130        
  140 NOGO = 1        
      BUF(1) = TFSET        
      BUF(2) = 0        
      CALL MESAGE (30,74,BUF)        
      IF (DMIG(1) .EQ. TFSET) GO TO 150        
      CALL CLOSE (TFPOOL,CLSREW)        
      GO TO 290        
C        
C     OPEN OUTPUT FILES. WRITE HEADER RECORDS.        
C        
  150 DO 160 I = 1,3        
C        
C     CHECK FOR PURGED OUTPUT DATA BLOCKS.        
C        
      IF (FILEI(I) .GT. 0) GO TO 152        
      NOMAT(I) = -1        
      GO TO 160        
  152 FILE = FILEI(I)        
      BUFX = BUFI(I)        
      CALL GOPEN (FILE,Z(BUFX),WRTREW)        
  160 CONTINUE        
C        
C     PACK MATRICES ONTO OUTPUT FILES.        
C        
      NCOL = LUSET        
      ICOL = 1        
      JSW  = 0        
      ISW  = 0        
      I45  = 5        
      IF (PACK) I45 = 4        
      I12  = I45 - 3        
  180 DO 190 I = 1,3        
      IF (FILEI(I) .LE. 0) GO TO 190        
      CALL BLDPK (1,1,FILEI(I),BLOCK(20*I-19),1)        
  190 CONTINUE        
      IF (ISW .NE. 0) GO TO 210        
  200 IF (JSW .NE. 0) GO TO 240        
      CALL READ (*680,*260,TFPOOL,BUF,I45,0,FLAG)        
      ISW = 1        
      COL = BUF(1)        
      ROW = BUF(2)        
      IF (.NOT.PACK) GO TO 210        
      COL = RSHIFT(BUF(1),IHALF)        
      ROW = ANDF(BUF(1),MASK16)        
  210 IF (COL .GT. ICOL) GO TO 240        
      DO 230 I = 1,3        
      IF (FILEI(I) .LE. 0) GO TO 230        
      CALL BLDPKI (BUF(I+I12),ROW,FILEI(I),BLOCK(20*I-19))        
  230 CONTINUE        
      ISW = 0        
      GO TO 200        
  240 DO 250 I = 1,3        
      IF (FILEI(I) .LE. 0) GO TO 250        
      CALL BLDPKN (FILEI(I),BLOCK(20*I-19),BLOCK(7*I+54))        
  250 CONTINUE        
      ICOL = ICOL + 1        
      IF (ICOL .LE. NCOL) GO TO 180        
      GO TO 270        
  260 JSW = 1        
      GO TO 240        
C        
C     CLOSE FILES AND WRITE TRAILERS. IF NO DMIG MATRICES, RETURN       
C        
  270 CALL CLOSE (TFPOOL,CLSREW)        
      DO 280 I = 1,3        
      IF (FILEI(I) .LE. 0) GO TO 280        
      I7 = 7*I        
      BLOCK(I7+54) = FILEI(I)        
      BLOCK(I7+56) = NCOL        
      BLOCK(I7+57) = 1        
      BLOCK(I7+58) = 1        
      CALL CLOSE  (FILEI(I),1)        
      CALL WRTTRL (BLOCK(I7+54))        
  280 CONTINUE        
C     NOGOX = 0        
      IF (NODMIG .EQ. 0) GO TO 650        
C        
C     READ EQUIVALENCE TABLE INTO CORE        
C        
  290 FILE = EQEX        
      CALL GOPEN (EQEX,Z(BUF2),0)        
      CALL SKPREC (EQEX,1)        
      CALL READ (*680,*300,EQEX,Z,BUF2,1,NEQEX)        
      CALL MESAGE (-8,0,NAM)        
  300 CALL CLOSE (EQEX,CLSREW)        
      KN = NEQEX/2        
      NN = NEQEX - 1        
      DO 310 I = 1,NN,2        
      Z(I+1) = Z(I+1)/10        
  310 CONTINUE        
C        
C     READ MATRIX HEADER INFORMATION.        
C     LOOK UP MATRIX NAME IN NAME LIST. IF ABSENT, SKIP MATRIX.        
C        
  320 CALL READ (*680,*630,MPOOL,BUF,9,0,FLAG)        
C        
C     BUF(5)= INPUT MATRIX TYPE, BUF(6)= OUTOUT MATRIX TYPE        
C     BUF(1) AND BUF(2) ARE MATRIX NAME FROM DMIG CARDS.        
C        
      K    = BUF(6)        
      PREC = PRC(K)        
      K    = BUF(5)        
      IPRC = MOD(K,2)        
      NWD  = NWDS(K)        
      NWD1 = NWD + 1        
      I11  = 11        
      IF (PACK) GO TO 325        
      I11  = 10        
      NWD1 = NWD + 2        
  325 I10  = I11 - 1        
      DO 330 I = 1,NFILES,10        
      IF (MCB(I+7).EQ.BUF(1) .AND. MCB(I+8).EQ.BUF(2)) GO TO 360        
  330 CONTINUE        
  340 CALL FREAD (MPOOL,BUF,2,0)        
      IF (BUF(1) .EQ. -1) GO TO 320        
  350 CALL FREAD (MPOOL,BUF,2,0)        
      IF (BUF(1) .EQ. -1) GO TO 340        
      CALL FREAD (MPOOL,BUF,-NWD,0)        
      GO TO 350        
C        
C     OPEN SCRATCH FILE. SET POINTERS.        
C        
  360 IPTR = I        
      FILE = MCB(IPTR)        
      MCB(IPTR+2) = LUSET        
      MCB(IPTR+3) = BUF(4)        
      MCB(IPTR+4) = BUF(6)        
      MCB(IPTR+9) = 1        
      IQQ = (IPTR-1)/10        
      NOMAT(IQQ+1) = +1        
      ISW = 0        
      IMTRX = NEQEX + 1        
      I = IMTRX        
C        
C     IF (NOGOX .EQ. 0) GO TO 365        
C     CALL PAGE2 (1)        
C     WRITE  (NOUT,363)        
C 363 FORMAT (1X)        
C     GO TO 367        
C 365 CONTINUE        
C        
      CALL OPEN (*670,SCR1,Z(BUF2),WRTREW)        
C        
C     READ COLUMN GRID AND COMPONENT, AND CHECK DUPLICATE.        
C     CONVERT GRID AND COMPONENT TO SIL NO.        
C        
C     REMOVE DUPLICATE CHECK ADDED HERE IN 91 VERSION. CHECKING SHOULD  
C     BE DONE EARLY IN IFP MODULE, AND NOT HERE. REMOVED ALSO NOGOX AND 
C     ITS ASSOCIATED LINES.   3/93        
C        
C 367 GJ = 0        
C     CJ = 0        
  370 CALL FREAD (MPOOL,BUF(10),2,0)        
      IF (BUF(10) .EQ. -1) GO TO 450        
C        
C     IF (BUF(10).NE.GJ .OR. BUF(11).NE.CJ) GO TO 379        
C     IF (NOGOX .EQ. 1) GO TO 373        
C     NOGOX = 1        
C     CALL PAGE2 (2)        
C     WRITE  (NOUT,371) UFM        
C 371 FORMAT (A23,', THE FOLLOWING ARE DUPLICATE INPUT CARD(S)',/)      
C     CALL CLOSE (SCR1,CLSREW)        
C 373 CALL PAGE2 (1)        
C     WRITE  (NOUT,375) BUF(1),BUF(2),BUF(10),BUF(11)        
C 375 FORMAT (5X,'DMIG    ',2A4,2I8,'...')        
C 377 CALL FREAD (MPOOL,BUF(10),2,0)        
C     IF (BUF(10) .EQ. -1) GO TO 370        
C     CALL FREAD (MPOOL,BUF(12),-NWD,0)        
C     IF (BUF(10).NE.GJ .OR. BUF(11).NE.CJ) GO TO 379        
C     CALL PAGE2 (1)        
C     WRITE (NOUT,375) BUF(1),BUF(2),BUF(10),BUF(11)        
C 379 GJ = BUF(10)        
C     CJ = BUF(11)        
C     IF (NOGOX .EQ. 1) GO TO 377        
C        
      ASSIGN 380 TO RET        
      GO TO 710        
  380 COL = Z(2*K)        
      IF (BUF(11) .NE. 0) COL = COL + BUF(11) - 1        
      IF (PACK) COL = LSHIFT(COL,IHALF)        
C        
C     READ A COLUMN OF THE MATRIX.        
C     STORE IN CORE OR ON SCRATCH FILE IF TOO BIG FOR CORE.        
C        
  390 CALL FREAD (MPOOL,BUF(10),2,0)        
      IF (BUF(10) .EQ. -1) GO TO 370        
      ASSIGN 400 TO RET        
      GO TO 710        
  400 ROW = Z(2*K)        
      IF (BUF(11) .NE. 0) ROW = ROW + BUF(11) - 1        
      BUF(11) = ROW        
      BUF(10) = COL        
      IF (PACK) BUF(11) = ROW + COL        
      CALL FREAD (MPOOL,BUF(12),NWD,0)        
      IF (ISW .EQ. 0) GO TO 420        
  410 CALL WRITE (SCR1,BUF(I11),NWD1,0)        
      GO TO 390        
  420 IF (I+NWD1 .LT. BUF2) GO TO 430        
      ISW = 1        
      CALL WRITE (SCR1,Z(IMTRX),I-IMTRX,0)        
      GO TO 410        
  430 DO 440 J = 1,NWD1        
      Z(I) = BUF(J+I10)        
  440 I = I + 1        
      GO TO 390        
C        
C     SORT MATRIX.        
C        
C 450 IF (NOGOX .EQ. 1) GO TO 320        
  450 IF (ISW   .EQ. 0) GO TO 460        
      CALL WRITE (SCR1,0,0,1)        
      CALL CLOSE (SCR1,CLSREW)        
      CALL OPEN  (*670,SCR1,Z(BUF2),RDREW)        
      IFILE(1) = SCR2        
      IFILE(2) = SCR3        
      IFILE(3) = SCR4        
      IF (     PACK) CALL SORTI  (SCR1,0,NWD1,1,Z(IMTRX),BUF2-IMTRX)    
      IF (.NOT.PACK) CALL SORTI2 (SCR1,0,NWD1,1,Z(IMTRX),BUF2-IMTRX)    
      CALL CLOSE (SCR1,CLSREW)        
      GO TO 470        
  460 N = I - IMTRX        
      NMTRX = I - NWD1        
      CALL CLOSE (SCR1,CLSREW)        
      IF (     PACK) CALL SORTI  (0,0,NWD1,1,Z(IMTRX),N)        
      IF (.NOT.PACK) CALL SORTI2 (0,0,NWD1,1,Z(IMTRX),N)        
C        
C     OPEN OUTPUT FILE. WRITE HEADER RECORD        
C     IF SORTED MATRIX NOT IN CORE, OPEN FILE WITH MATRIX.        
C        
  470 IF (TFSET .NE. 0) FILE = SCR1        
      CALL OPEN  (*670,FILE,Z(BUF2),WRTREW)        
      CALL FNAME (FILE,BUF(19))        
      CALL WRITE (FILE,BUF(19),2,1)        
      IF (ISW .NE. 0) CALL OPEN (*670,IFILE(6),Z(BUF3),RDREW)        
C        
C     PACK MATRIX ONTO OUTPUT FILE.        
C        
      NCOL = LUSET        
      J    = IMTRX        
      ICOL = 1        
      JSW  = 0        
  490 CALL BLDPK (BUF(6),BUF(6),FILE,0,0)        
      IF (JSW .NE.   0) GO TO 540        
  500 IF (J .GT. NMTRX) GO TO 570        
      IF (ISW .EQ.   0) GO TO 510        
      CALL READ (*680,*580,IFILE(6),BUF(I11),NWD1,0,FLAG)        
      GO TO 530        
  510 DO 520 K = 1,NWD1        
      BUF(K+I10) = Z(J)        
  520 J   = J + 1        
  530 COL = BUF(10)        
      ROW = BUF(11)        
      IF (.NOT.PACK) GO TO 540        
      COL = RSHIFT(BUF(11),IHALF)        
      ROW = ANDF(BUF(11),MASK16)        
  540 IF (COL .GT. ICOL) GO TO 590        
      JSW = 0        
      IF (PREC .EQ. 2) GO TO 550        
      IF (IPRC .EQ. 0) GO TO 545        
      X(1) = BUFR(12)        
      X(2) = BUFR(13)        
      GO TO 560        
  545 X(1) = BUFD(1)        
      X(2) = BUFD(2)        
      GO TO 560        
  550 IF (IPRC .EQ. 0) GO TO 555        
      XD(1) = BUFR(12)        
      XD(2) = BUFR(13)        
      GO TO 560        
  555 XD(1) = BUFD(1)        
      XD(2) = BUFD(2)        
  560 CALL ZBLPKI        
      GO TO 500        
  570 CALL BLDPKN (FILE,0,MCB(IPTR))        
      ICOL = ICOL + 1        
      IF (ICOL .LE. NCOL) GO TO 490        
      GO TO 600        
  580 J = NMTRX + 1        
      GO TO 570        
  590 JSW = 1        
      GO TO 570        
  600 CALL CLOSE (FILE,CLSREW)        
      IF (ISW .NE. 0) CALL CLOSE (IFILE(6),CLSREW)        
      CALL WRTTRL (MCB(IPTR))        
C        
C     IF TRANSFER FUNCTION MATRICES ARE TO BE ADDED, CALL MATRIX ADD    
C     ROUTINE THEN RETURN TO READ NEXT MATRIX IN THE MATRIX POOL.       
C        
      IF (TFSET .EQ. 0) GO TO 320        
      J = 2        
      IF (IPTR .EQ.  1) J = 1        
      IF (IPTR .EQ. 11) J = 3        
      DO 620 I = 1,7        
      K = IPTR + I - 1        
      FILEA(I) = MCB(K)        
      K = 7*J + I        
      FILEB(I) = BLOCK(K+53)        
  620 FILEC(I) = 0        
      FILEA(1) = SCR1        
      FILEC(1) = MCB(IPTR)        
      FILEC(2) = NCOL        
      FILEC(3) = NCOL        
      FILEC(4) = FILEA(4)        
      FILEC(5) = FILEA(5)        
      NZ = BUF1 - IMTRX        
      NOMATS = 2        
      K = ORF(IMTRX,1)        
      CALL SADD (Z(K),Z(K))        
      CALL WRTTRL (FILEC)        
      GO TO 320        
C        
C     TEST FOR ALL REQUESTED MATRICES FOUND.        
C        
  630 DO 640 I = 1,NFILES,10        
      IF (MCB(I+7).EQ.0 .OR. MCB(I+9).NE.0) GO TO 640        
      CALL MESAGE (30,70,MCB(I+7))        
      NOGO = 1        
  640 CONTINUE        
  650 IF (NOMPOO .NE. 0) CALL CLOSE (MPOOL,CLSREW)        
      IF (NOGO   .NE. 0) CALL MESAGE (-61,0,NAM)        
C     IF (NOGOX  .EQ. 1) CALL MESAGE (-37,0,NAM)        
      RETURN        
C        
C     FATAL ERRORS        
C        
  670 N = -1        
      GO TO 700        
  680 N = -2        
  700 CALL MESAGE (N,FILE,NAM)        
C        
C     BINARY SEARCH ROUTINE        
C        
  710 KLO = 1        
      KHI = KN        
  720 K = (KLO+KHI+1)/2        
  730 IF (BUF(10)-Z(2*K-1)) 740,810,750        
  740 KHI = K        
      GO TO 760        
  750 KLO = K        
  760 IF (KHI-KLO-1) 800,770,720        
  770 IF (K.EQ.KLO) GO TO 780        
      K = KLO        
      GO TO 790        
  780 K = KHI        
  790 KLO = KHI        
      GO TO 730        
  800 NOGO = 1        
      BUF(11) = 0        
  810 GO TO RET, (380,400)        
      END        
