      SUBROUTINE MRED2D        
C        
C     THIS SUBROUTINE CALCULATES THE MODAL MASS AND STIFFNESS MATRICES  
C     IF USERMODE = TYPE2 FOR THE MRED2 MODULE.        
C        
C     INPUT DATA        
C     GINO - USETMR  - USET TABLE FOR REDUCED SUBSTRUCTURE        
C            LAMAMR  - EIGENVALUE TABLE FOR SUBSTRUCTURE BEING REDUCED  
C            PHISS   - EIGENVECTORS FOR SUBSTRUCTURE BEING REDUCED      
C            QSM     - MODEL REACTION MATRIX        
C            PAA     - SUBSTRUCTURE LOAD MATRIX        
C        
C     OUTPUT DATA        
C     GINO - KHH     - REDUCED STIFFNESS MATRIX        
C            MHH     - REDUCED MASS MATRIX        
C            PHH     - REDUCED LOAD MATRIX        
C     SOF  - HORG    - H TRANSFORMATION MATRIX        
C            KMTX    - STIFFNESS MATRIX FOR REDUCED SUBSTRUCTURE        
C            MMTX    - MASS MATRIX FOR REDUCED SUBSTRUCTURE        
C            PVEC    - LOAD MATRIX FOR REDUCED SUBSTRUCTURE        
C            PAPP    - APPENDED LOAD MATRIX FOR REDUCED SUBSTRUCTURE    
C            POVE    - INTERNAL POINT LOADS FOR ORIGINAL SUBSTRUCTURE   
C            POAP    - INTERNAL POINTS APPENDED LOADS FOR ORIGINAL      
C                       SUBSTRUCTURE        
C        
C     PARAMETERS        
C     INPUT - DRY    - MODULE OPERATION FALG        
C             GBUF   - GINO BUFFERS        
C             INFILE - INPUT FILE NUMBERS        
C             OTFILE - OUTPUT FILE NUMBERS        
C             ISCR   - SCRATCH FILE NUMBERS        
C             KORLEN - LENGTH OF OPEN CORE        
C             KORBGN - BEGINNING ADDRESS OF OPEN CORE        
C             OLDNAM - NAME OF SUBSTRUCTURE BEING REDUCED        
C             NEWNAM - NAME OF REDUCED SUBSTRUCTURE        
C             USRMOD - USERMODE FLAG        
C        
      INTEGER         DRY,POPT,GBUF1,SBUF1,SBUF2,SBUF3,OTFILE,OLDNAM,   
     1                USRMOD,Z,UL,UA,UF,US,UN,UB,TYPIN,TYPOUT,TYPEA,    
     2                TYPEB,PAA,PHH,RPRTN,CPRTN,BBZERO,ZERO,USETMR,SNB, 
     3                PAPP        
      DIMENSION       ITRLR(7),ITRLR1(7),ITRLR2(7),MODNAM(2),ITMLST(6), 
     1                BLOCK(11),ISUB(4),ITMNAM(2),RZ(1)        
      CHARACTER       UFM*23        
      COMMON /XMSSG / UFM        
      COMMON /BLANK / IDUM1,DRY,POPT,GBUF1,IDUM3(2),SBUF1,SBUF2,SBUF3,  
     1                INFILE(12),OTFILE(6),ISCR(10),KORLEN,KORBGN,      
     2                OLDNAM(2),NEWNAM(2),IDUM4(4),USRMOD,IDUM2(5),     
     3                NMODES        
CZZ   COMMON /ZZMRD2/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      COMMON /TWO   / ITWO(32)        
      COMMON /BITPOS/ IDUM5(5),UL,UA,UF,US,UN,IDUM6(10),UB        
      COMMON /PACKX / TYPIN,TYPOUT,IROW,NROW,INCR        
      COMMON /SYSTEM/ IDUM7,IPRNTR        
      EQUIVALENCE     (USETMR,INFILE(5)),(KBB,INFILE(6)),        
     1                (MBB,INFILE(7)),(PAA,INFILE(10)),        
     2                (KHH,OTFILE(1)),(MHH,OTFILE(2)),(PHH,OTFILE(5)),  
     3                (RPRTN,ISCR(8)),(CPRTN,ISCR(8)),(K,ISCR(3)),      
     4                (BBZERO,ISCR(9)),(M,ISCR(10)),(ZERO,ISCR(3)),     
     5                (RZ(1),Z(1)),(TYPEA,BLOCK(1)),(TYPEB,BLOCK(7))    
      DATA    MODNAM/ 4HMRED,4H2D  /        
      DATA    PAPP  / 4HPAPP/        
      DATA    MRED2 / 27    /        
      DATA    ITMLST/ 4HKMTX,4HMMTX,4HPVEC,4HPAPP,4HPOVE,4HPOAP/        
C        
C     CHECK USERMODE OPTION FLAG        
C        
      IF (DRY .EQ. -2) GO TO 400        
C        
C     COUNT NUMBER OF FREE, FIXED POINTS WITHIN BOUNDARY SET        
C        
      ITRLR(1) = USETMR        
      CALL RDTRL(ITRLR)        
      IFILE = USETMR        
      IF (ITRLR(1) .LT. 0) GO TO 270        
      LUSET = ITRLR(3)        
      IF ((KORBGN + LUSET) .GE. KORLEN) GO TO 280        
      CALL GOPEN (USETMR,Z(GBUF1),0)        
      CALL READ  (*260,*270,USETMR,Z(KORBGN),LUSET,0,NWDSRD)        
      CALL CLOSE (USETMR,1)        
      NUF   = 0        
      NUS   = 0        
      SNB   = ITWO(US) + ITWO(UN) + ITWO(UB)        
      LAFNB = ITWO(UL) + ITWO(UA) + ITWO(UF) + ITWO(UN) + ITWO(UB)      
      DO 10 I = 1,LUSET        
      IF (Z(KORBGN+I-1) .EQ. LAFNB) NUF = NUF + 1        
      IF (Z(KORBGN+I-1) .EQ.   SNB) NUS = NUS + 1        
   10 CONTINUE        
C        
C     IF FIXED SET, COMPUTE GS MATRIX        
C        
      IF (NUS .EQ. 0) GO TO 20        
      CALL MRED2I (1,0,0)        
C        
C     IF FREE SET, PARTITION PHISS        
C        
   20 IF (NUF .EQ. 0) GO TO 50        
      CALL MRED2J (NUF,N2)        
C        
C     FORM HK MATRIX        
C        
      CALL MRED2L (NUF,N2,NUS,UFBITS)        
   50 CALL MRED2M (NUF,N2,NUS)        
C        
C     COMPUTE K MATRIX        
C        
      CALL MRED2N        
C        
C     COMPUTE HM MATRIX        
C        
      CALL MRED2O (NUS)        
C        
C     OUTPUT HORG        
C        
      CALL MRED2P (NUS,NUF,N2)        
C        
C     PROCESS STIFFNESS, MASS MATRICES        
C     II = 1, PROCESS STIFFNESS MATRIX        
C     II = 2, PROCESS MASS MATRIX        
C        
      IF (DRY .EQ. -2) GO TO 240        
      CALL SETLVL (NEWNAM,1,OLDNAM,ITEST,MRED2)        
      IF (ITEST .EQ. 8) GO TO 380        
      DO 190 II = 1,2        
      ITRLR1(1) = KBB        
      KM   = K        
      KMHH = KHH        
      IF (II .EQ. 1) GO TO 60        
      ITRLR1(1) = MBB        
      KM   = M        
      KMHH = MHH        
   60 KMBB = ITRLR1(1)        
      CALL RDTRL (ITRLR1)        
      IF (ITRLR1(1) .LT. 0) GO TO 160        
      CALL SOFCLS        
C        
C     FORM MERGE VECTOR        
C        
      JROW   = ITRLR1(3)        
      KOLUMN = ITRLR1(2)        
      ITRLR2(1) = KM        
      CALL RDTRL (ITRLR2)        
      NROW   = ITRLR2(3)        
      KOLMNS = ITRLR2(2)        
      DO 130 I = 1,NROW        
      RZ(KORBGN+I-1) = 0.0        
      IF (I .GT. JROW) RZ(KORBGN+I-1) = 1.0        
  130 CONTINUE        
      IFORM  = 7        
      TYPIN  = 1        
      TYPOUT = 1        
      IROW   = 1        
      INCR   = 1        
      CALL MAKMCB (ITRLR1,RPRTN,NROW,IFORM,TYPIN)        
      CALL GOPEN (RPRTN,Z(GBUF1),1)        
      CALL PACK (Z(KORBGN),RPRTN,ITRLR1)        
      CALL CLOSE (RPRTN,1)        
      CALL WRTTRL (ITRLR1)        
C        
C     MERGE (K,M)BB MATRIX WITH ZERO MATRICES        
C        
      ISUB(1) = KOLUMN        
      ISUB(2) = KOLMNS - KOLUMN        
      ISUB(3) = JROW        
      ISUB(4) = NROW - JROW        
      ITYPE   = 1        
      CALL GMMERG (BBZERO,KMBB,0,0,0,RPRTN,RPRTN,ISUB,ITYPE,Z(KORBGN),  
     1             KORLEN)        
C        
C     FORM STIFFNESS, MASS MATRICES        
C        
C                                  **           **        
C                                  *         .   *        
C        **       **   **     **   * (K,M)BB . 0 *        
C        *         *   *       *   *         .   *        
C        * (K,M)HH * = * (K,M) * + *.............*        
C        *         *   *       *   *         .   *        
C        **       **   **     **   *    0    . 0 *        
C                                  *         .   *        
C                                  **           **        
      DO 150 I = 1,11        
  150 BLOCK(I) = 0.0        
      BLOCK(2) = 1.0        
      BLOCK(8) = 1.0        
      TYPEA = ITRLR2(5)        
      TYPEB = ITRLR1(5)        
      IOP   = 1        
      CALL SSG2C (KM,BBZERO,KMHH,IOP,BLOCK)        
      CALL SOFOPN (Z(SBUF1),Z(SBUF2),Z(SBUF3))        
      GO TO 170        
C        
C     NO BB MATRIX PARTITION        
C        
  160 KMHH = KM        
C        
C     STORE MATRIX ON SOF        
C     II = 1, STORE KHH AS KMTX        
C     II = 2, STORE MHH AS MMTX        
C        
  170 ITEM      = ITMLST(II)        
      ITMNAM(1) = NEWNAM(1)        
      ITMNAM(2) = NEWNAM(2)        
      CALL MTRXO (KMHH,NEWNAM,ITEM,0,ITEST)        
      IF (ITEST .NE. 3) GO TO 300        
  190 CONTINUE        
C        
C     PROCESS LOAD DATA        
C        
      ITRLR1(1) = PAA        
      CALL RDTRL (ITRLR1)        
      IF (ITRLR1(1) .LT. 0) GO TO 240        
C        
C     EXPAND PAA FOR MODAL DOF        
C        
C                  **   **        
C                  *     *        
C        **   **   * PAA *        
C        *     *   *     *        
C        * PHH * = *.....*        
C        *     *   *     *        
C        **   **   *  0  *        
C                  *     *        
C                  **   **        
C        
      NROW = ITRLR1(3) + N2        
      IF (N2 .EQ. 0) NROW = NROW + (NMODES - NUF)        
      IFORM  = 7        
      TYPIN  = 1        
      TYPOUT = 1        
      IROW   = 1        
      INCR   = 1        
      CALL MAKMCB (ITRLR2,CPRTN,NROW,IFORM,TYPIN)        
      DO 230 I = 1,NROW        
      RZ(KORBGN+I-1) = 0.0        
      IF (I .GT. ITRLR1(3)) RZ(KORBGN+I-1) = 1.0        
  230 CONTINUE        
      CALL GOPEN (CPRTN,Z(GBUF1),1)        
      CALL PACK (Z(KORBGN),CPRTN,ITRLR2)        
      CALL CLOSE (CPRTN,1)        
      CALL WRTTRL (ITRLR2)        
C        
C     MERGE PAA WITH ZERO MATRIX        
C        
      ISUB(3) = ITRLR1(3)        
      ISUB(4) = N2        
      IF (N2 .EQ. 0) ISUB(4) = NMODES - NUF        
      ITYPE   = 1        
      CALL GMMERG (PHH,PAA,0,0,0,0,CPRTN,ISUB,ITYPE,Z(KORBGN),KORLEN)   
C        
C     SAVE PHH AS PVEC OR PAPP ON SOF        
C        
      ITEM = ITMLST(3)        
      IF (POPT .EQ. PAPP) ITEM = ITMLST(4)        
      ITMNAM(1) = NEWNAM(1)        
      ITMNAM(2) = NEWNAM(2)        
      CALL MTRXO (PHH,NEWNAM,ITEM,0,ITEST)        
      IF (ITEST .NE. 3) GO TO 300        
C        
C     STORE NULL MATRIX AS POVE OR POAP ON SOF        
C        
      IFORM  = 2        
      KOLMNS = ITRLR1(2)        
      NROW   = N2        
      IF (N2 .EQ. 0) NROW = NMODES - NUF        
      CALL MAKMCB (ITRLR2,ZERO,NROW,IFORM,TYPIN)        
      CALL GOPEN (ZERO,Z(GBUF1),1)        
      DO 234 I = 1,KOLMNS        
      DO 232 J = 1,NROW        
  232 RZ(KORBGN+J-1) = 0.0        
  234 CALL PACK (Z(KORBGN),ZERO,ITRLR2)        
      CALL CLOSE (ZERO,1)        
      CALL WRTTRL (ITRLR2)        
      ITEM = ITMLST(5)        
      IF (POPT .EQ. PAPP) ITEM = ITMLST(6)        
      ITMNAM(1) = OLDNAM(1)        
      ITMNAM(2) = OLDNAM(2)        
      CALL MTRXO (ZERO1,OLDNAM,ITEM,0,ITEST)        
      IF (ITEST .NE. 3) GO TO 300        
  240 CONTINUE        
      GO TO 400        
C        
C     PROCESS SYSTEM FATAL ERRORS        
C        
  260 IMSG = -2        
      GO TO 290        
  270 IMSG = -3        
      GO TO 290        
  280 IMSG = -8        
      IFILE = 0        
  290 CALL SOFCLS        
      CALL MESAGE (IMSG,IFILE,MODNAM)        
      GO TO 400        
C        
C     PROCESS MODULE FATAL ERRORS        
C        
  300 GO TO (310,320,330,340,350,370), ITEST        
  310 IMSG = -9        
      GO TO 390        
  320 IMSG = -11        
      GO TO 390        
  330 IMSG = -1        
      GO TO 360        
  340 IMSG = -2        
      GO TO 360        
  350 IMSG = -3        
  360 CALL SMSG (IMSG,ITEM,ITMNAM)        
      GO TO 400        
  370 IMSG = -10        
      GO TO 390        
  380 WRITE  (IPRNTR,385) UFM        
  385 FORMAT (A23,' 6518, ONE OF THE COMPONENT SUBSTRUCTURES HAS BEEN ',
     1       'USED IN A PREVIOUS COMBINE OR REDUCE.')        
      DRY = -2        
      GO TO 400        
  390 DRY = -2        
      CALL SMSG1 (IMSG,ITEM,ITMNAM,MODNAM)        
  400 RETURN        
      END        
