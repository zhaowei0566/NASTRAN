      SUBROUTINE MRED2A        
C        
C     THIS SUBROUTINE PARTITIONS THE STIFFNESS MATRIX INTO BOUNDARY AND 
C     INTERIOR POINTS AND THEN SAVES THE PARTITIONING VECTOR ON THE SOF 
C     AS THE UPRT ITEM FOR THE MRED2 MODULE.        
C        
C     INPUT DATA        
C     GINO - USETMR   - USET TABLE FOR REDUCED SUBSTRUCTURE        
C            KAA      - SUBSTRUCTURE STIFFNESS MATRIX        
C        
C     OUTPUT DATA        
C     GINO - KBB      - KBB PARTITION MATRIX        
C            KIB      - KIB PARTITION MATRIX        
C            KII      - KII PARTITION MATRIX        
C     SOF  - UPRT     - PARTITION VECTOR FOR ORIGINAL SUBSTRUCTURE      
C        
C     PARAMETERS        
C     INPUT  - GBUF   - GINO BUFFER        
C              INFILE - INPUT FILE NUMBERS        
C              ISCR   - SCRATCH FILE NUMBERS        
C              KORLEN - LENGTH OF OPEN CORE        
C              KORBGN - BEGINNING ADDRESS OF OPEN CORE        
C              OLDNAM - NAME OF SUBSTRUCTURE BEING REDUCED        
C     OTHERS - USETMR - USETMR INPUT FILE NUMBER        
C              KAA    - KAA INPUT FILE NUMBER        
C              KBB    - KBB OUTPUT FILE NUMBER        
C              KIB    - KIB OUTPUT FILE NUMBER        
C              KII    - KII OUTPUT FILE NUMBER        
C              UPRT   - KAA PARTITION VECTOR FILE NUMBER        
C        
      LOGICAL         BOUNDS        
      INTEGER         DRY,GBUF1,OLDNAM,USRMOD,Z,UN,UB,UI,FUSET,        
     1                USETMR,UPRT,EQST,MODNAM(2),ITRLR(7)        
      COMMON /BLANK / IDUM1,DRY,IDUM6,GBUF1,IDUM2(5),INFILE(12),        
     1                IDUM3(6),ISCR(10),KORLEN,KORBGN,OLDNAM(2),        
     2                IDUM7(6),USRMOD,IDUM9,BOUNDS        
CZZ   COMMON /ZZMRD2/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      COMMON /BITPOS/ IDUM4(9),UN,IDUM5(10),UB,UI        
      COMMON /PATX  / LCORE,NSUB(3),FUSET        
      COMMON /SYSTEM/ IDUM8,IPRNTR        
      EQUIVALENCE     (EQST,INFILE(4)),(USETMR,INFILE(5)),        
     1                (KAA,INFILE(6)),(KBB,ISCR(1)),(KIB,ISCR(2)),      
     2                (KII,ISCR(3)),(UPRT,ISCR(5))        
      DATA    MODNAM/ 4HMRED,4H2A  /        
      DATA    ITEM  / 4HUPRT/        
C        
C     LOCATE PARTITIONING VECTOR        
C        
      IF (DRY .EQ. -2) GO TO 100        
      IF (BOUNDS) GO TO 10        
      LCORE = KORLEN        
      FUSET = USETMR        
      CALL CALCV (UPRT,UN,UI,UB,Z(KORBGN))        
      GO TO 20        
   10 CALL MTRXI (UPRT,OLDNAM,ITEM,0,ITEST)        
      IF (ITEST .NE. 1) GO TO 30        
      ITRLR(1) = EQST        
      CALL RDTRL (ITRLR)        
      NSUB(1) = ITRLR(6)        
      NSUB(2) = ITRLR(7)        
C        
C     PARTITION STIFFNESS MATRIX        
C        
C                  **         **        
C                  *     .     *        
C        **   **   * KBB . KBI *        
C        *     *   *     .     *        
C        * KAA * = *...........*        
C        *     *   *     .     *        
C        **   **   * KIB . KII *        
C                  *     .     *        
C                  **         **        
C        
   20 CONTINUE        
      CALL GMPRTN (KAA,KII,0,KIB,KBB,UPRT,UPRT,NSUB(1),NSUB(2),        
     1             Z(KORBGN),KORLEN)        
C        
C     SAVE PARTITIONING VECTOR        
C        
      IF (BOUNDS) GO TO 25        
      CALL MTRXO (UPRT,OLDNAM,ITEM,0,ITEST)        
      IF (ITEST .NE. 3) GO TO 30        
   25 CONTINUE        
      GO TO 100        
C        
C     PROCESS MODULE FATAL ERRORS        
C        
   30 GO TO (40,45,50,55,60,80), ITEST        
   40 IMSG = -9        
      GO TO 90        
   45 IMSG = -11        
      GO TO 90        
   50 IMSG = -1        
      GO TO 70        
   55 IMSG = -2        
      GO TO 70        
   60 IMSG = -3        
   70 CALL SMSG (IMSG,ITEM,OLDNAM)        
      GO TO 100        
   80 IMSG = -10        
   90 DRY = -2        
      CALL SMSG1 (IMSG,ITEM,OLDNAM,MODNAM)        
  100 RETURN        
C        
      END        
