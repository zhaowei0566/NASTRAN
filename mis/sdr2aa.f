      SUBROUTINE SDR2AA        
C        
C     SDR2AA PROCESSES THE CASE CONTROL AND XYCDB DATA BLOCKS. IF XYCDB 
C     IS PURGED, NO ACTION IS TAKEN. OTHERWISE, OUTPUT REQUESTS IN      
C     CASE CONTROL ARE COMPARED WITH XY REQUESTS IN XYCDB. FOR EACH     
C     SUBCASE AND EACH REQUEST TYPE, CASE CONTROL IS MODIFIED TO        
C     REFLECT THE UNION OF THE REQUESTS. THE NEW CASE CONTROL IS        
C     WRITTEN ON A SCRATCH FILE AND THE POINTER TO CASE CONTROL SWITCHED
C        
      INTEGER         TAB   ,SDR2X1,BUF   ,CASECC,XYCDB ,SCR3  ,Z     , 
     1                APP   ,RD    ,RDREW ,WRT   ,WRTREW,CLSREW,SYSBUF, 
     2                XSETNO,BUF1  ,BUF2  ,BUF3  ,SUBCSE,ANYNEW,FILE  , 
     3                DBNAME,SETNO ,ARG   ,ESTA  ,XYCDBF,TRN   ,FRQ   , 
     4                CEI   ,FORMT ,SORT2        
      DIMENSION       SDR2X1(1)    ,TAB(14)      ,BUF(10)       ,NAM(2) 
      COMMON /SDR2X1/ SDR2X1,IELDEF,ITLOAD,ISYMFL,ILOADS,IDISPL,ISTR  , 
     1                IELF  ,IACC  ,IVEL  ,ISPCF ,ITTL  ,ILSYM ,IFROUT, 
     2                ISLOAD,IDLOAD        
      COMMON /SDR2X2/ CASECC,CSTM  ,MPT   ,DIT   ,EQEXIN,SIL   ,GPTT  , 
     1                EDT   ,BGPDT ,PG    ,QG    ,UGV   ,EST   ,PHIG  , 
     2                EIGR  ,OPG1  ,OQG1  ,OUGV1 ,OES1  ,OEF1  ,PUGV1 , 
     3                OEIGR ,OPHIG ,PPHIG ,ESTA  ,GPTTA ,HARMS ,XYCDB , 
     4                SCR3        
      COMMON /SDR2X4/ X4(72),FRQ(2),TRN(2),BKL(4),CEI(2)        
      COMMON /BLANK / APP(2),SORT2        
CZZ   COMMON /ZZSDA2/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      COMMON /SYSTEM/ SYSBUF        
      COMMON /NAMES / RD    ,RDREW ,WRT   ,WRTREW,CLSREW        
      DATA    TAB   / 1,    6,        
     1                2,    10,        
     2                3,    9,        
     3                4,    11,        
     4                5,    5,        
     5                6,    7,        
     6                7,    8      /,        
     7        XSETNO/ 100000000    /,        
     8        NAM   / 4HSDR2,4HAA  /        
C        
C     SET BUFFER POINTERS AND PERFORM GENERAL INITIALIZATION.        
C        
      BUF1  = KORSZ(Z) - SYSBUF        
      BUF2  = BUF1 - SYSBUF        
      BUF3  = BUF2 - SYSBUF        
      IMSTR = 1        
      MASTER= 1        
      LASTXY= 0        
      ANYNEW= 0        
      SORT2 =-1        
C        
C     OPEN XYCDB. IF PURGED, RETURN.        
C        
      CALL OPEN (*1034,XYCDB,Z(BUF1),RDREW)        
      FILE = XYCDB        
      CALL FWDREC (*1035,XYCDB)        
      CALL FWDREC (*1035,XYCDB)        
C        
C     READ FIRST LINE OF XYCDB. IF SUBCASE = 0 (MEANING DATA APPLIES    
C     TO ALL SUBCASES), READ IN DATA FOR ZERO SUBCASE.        
C        
      LAST   = 0        
      XYCDBF = XYCDB        
      CALL READ (*1035,*1035,XYCDB,BUF,6,0,FLAG)        
      SORT2  = 0        
      SUBCSE = BUF(1)        
      IF (SUBCSE .NE. 0) GO TO 1013        
      I      = IMSTR        
 1011 Z(I  ) = BUF(2)        
      Z(I+1) = BUF(3)        
      I      = I + 2        
      CALL READ (*2002,*1012,XYCDB,BUF,6,0,FLAG)        
      IF (BUF(1) .EQ. 0) GO TO 1011        
      NMSTR  = I - 2        
      IXYSC  = I        
      GO TO 1019        
C        
C     HERE IF MASTER SUBCASE IS THE ONLY SUBCASE IN XYCDB.        
C        
 1012 NMSTR  = I - 2        
      NXYSC  = NMSTR        
      MASTER = 0        
      LASTXY = 1        
C        
C     REDUCE LIST TO UNIQUE PAIRS        
C        
      IF (IMSTR .EQ. NMSTR) GO TO 1019        
      NMSTR  = NMSTR - 2        
      J      = IMSTR        
      DO 1014 I = IMSTR,NMSTR,2        
      IF (Z(I+2).EQ.Z(J) .AND. Z(I+3).EQ.Z(J+1)) GO TO 1014        
      Z(J+2) = Z(I+2)        
      Z(J+3) = Z(I+3)        
      J      = J + 2        
 1014 CONTINUE        
      NMSTR  = J        
      NXYSC  = NMSTR        
      GO TO 1019        
C        
C     HERE IF NO MASTER SUBCASE -- CREATE A DUMMY MASTER.        
C        
 1013 NMSTR  = IMSTR        
      IXYSC  = IMSTR + 2        
      Z(IMSTR  ) = 9999        
      Z(IMSTR+1) = 0        
      MASTER = -1        
      GO TO 1019        
C        
C     OPEN CASE CONTROL AND SCRATCH FILE FOR MODIFIED CASE CONTROL      
C        
 1019 CALL GOPEN (CASECC,Z(BUF2),RDREW)        
      FILE = SCR3        
      CALL OPEN (*2001,SCR3,Z(BUF3),WRTREW)        
      CALL FNAME (CASECC,BUF(9))        
      CALL WRITE (SCR3,BUF(9),2,1)        
C        
C     READ DATA FOR ONE SUBCASE. STORE DATA BLOCK AND ID IN OPEN CORE.  
C        
 1020 IF (MASTER.EQ.0 .OR. LASTXY.NE.0) GO TO 1030        
      SUBCSE = BUF(1)        
      I      = IXYSC        
 1021 Z(I  ) = BUF(2)        
      Z(I+1) = BUF(3)        
      I      = I + 2        
      CALL READ (*1035,*1023,XYCDBF,BUF,6,0,FLAG)        
      IF (BUF(1) .EQ. SUBCSE) GO TO 1021        
      GO TO 1025        
 1023 LASTXY = 1        
C        
C     COPY DATA FROM MASTER SUBCASE AFTER CURRENT SUBCASE.        
C     THEN SORT DATA TOGETHER TO FORM SORTED UNION.        
C        
 1025 DO 1026 J = IMSTR,NMSTR,2        
      Z(I  ) = Z(J  )        
      Z(I+1) = Z(J+1)        
      I      = I + 2        
 1026 CONTINUE        
      N = I - IXYSC        
      CALL SORT (0,0,2,-2,Z(IXYSC),N)        
      CALL SORT (0,0,2,-1,Z(IXYSC),N)        
C     CALL SORT2K (0,0,2,1,Z(IXYSC),N)        
C        
C     REDUCE LIST TO UNIQUE PAIRS.        
C        
      NXYSC = I - 4        
      J = IXYSC        
      DO 1027 I = IXYSC,NXYSC,2        
      IF (Z(I+2).EQ.Z(J) .AND. Z(I+3).EQ.Z(J+1)) GO TO 1027        
      Z(J+2) = Z(I+2)        
      Z(J+3) = Z(I+3)        
      J = J + 2        
 1027 CONTINUE        
      NXYSC = J        
C        
C     READ A RECORD IN CASE CONTROL. SET POINTERS FOR XYCDB DATA TO     
C     EITHER MASTER SUBCASE OR CURRENT SUBCASE IN CORE.        
C        
 1030 ICC = NXYSC + 1        
      CALL READ (*1035,*1031,CASECC,Z(ICC+1),BUF3-ICC,1,NCC)        
      CALL MESAGE (-8,0,NAM)        
 1031 IF (SUBCSE .EQ. Z(ICC+1)) GO TO 10311        
      IF (MASTER .NE.       -1) GO TO 1032        
      IF (SUBCSE .GT. Z(ICC+1)) GO TO 1030        
      IF (LASTXY .EQ.        0) GO TO 1020        
      IF (ANYNEW .EQ.        0) GO TO 1035        
      CALL WRITE (SCR3,Z(ICC+1),NCC,1)        
      GO TO 1030        
10311 IXY = IXYSC        
      NXY = NXYSC        
      GO TO 1040        
 1032 IXY = IMSTR        
      NXY = NMSTR        
      GO TO 1040        
C        
C     TERMINATE PROCESSING.        
C        
 1035 CALL CLOSE (CASECC,CLSREW)        
      CALL CLOSE (XYCDBF,CLSREW)        
      CALL CLOSE (SCR3  ,CLSREW)        
      IF (ANYNEW .NE. 0) CASECC = SCR3        
 1034 RETURN        
C        
C     PICK UP POINTER TO CURRENT OUTPUT REQUEST.        
C     DETERMINE IF XYCDB REQUEST EXISTS.        
C        
 1040 LOOP   = 1        
 1041 DBNAME = TAB(LOOP  )        
      IX     = TAB(LOOP+1)        
      IREQ   = ICC + SDR2X1(IX)        
      SETNO  = Z(IREQ)        
      DO 1042 J = IXY,NXY,2        
      IF (Z(J) .EQ. DBNAME) GO TO 1043        
 1042 CONTINUE        
      GO TO 1100        
 1043 IXYSET = J        
      DO 1044 J = IXYSET,NXY,2        
      IF (Z(J) .NE. DBNAME) GO TO 1045        
 1044 CONTINUE        
      NXYSET = NXY        
      GO TO 1050        
 1045 NXYSET = J - 2        
C        
C     BRANCH ON CASECC REQUEST - NOTE, NO ACTION IF REQUEST = ALL.      
C        
 1050 IF (SETNO) 1098,1060,1070        
C        
C     HERE IF NO CASECC REQUEST.        
C     BUILD XYCDB SET IN CASECC SET FORMAT. ADD SET TO        
C     CASECC RECORD AND TURN ON CASECC REQUEST FOR SET.        
C        
 1060 XSETNO = XSETNO + 1        
      Z(IREQ  ) = XSETNO        
      Z(IREQ+1) = 0        
      FORMT  = -2        
      IF (APP(1) .EQ. TRN(1)) FORMT = -1        
      Z(IREQ+2) = FORMT        
      SORT2  = 0        
      IX     = ICC + NCC + 1        
      Z(IX)  = XSETNO        
      JX     = IX + 2        
      Z(JX)  = Z(IXYSET+1)        
      IF (IXYSET .EQ. NXYSET) GO TO 1066        
      IXYSET = IXYSET + 2        
      N      = 1        
      DO 1065 J = IXYSET,NXYSET,2        
      IF (Z(J+1)-Z(JX) .EQ. N) GO TO 1064        
      IF (N .NE. 1) GO TO 1062        
      JX     = JX + 1        
      Z(JX)  = Z(J+1)        
      GO TO 1065        
 1062 Z(JX+1)=-Z(J-1)        
      JX     = JX + 2        
      Z(JX)  = Z(J+1)        
      N      = 1        
      GO TO 1065        
 1064 N      = N + 1        
 1065 CONTINUE        
      IF (N .EQ. 1) GO TO 1066        
      JX     = JX + 1        
      Z(JX  )= -Z(NXYSET+1)        
 1066 Z(IX+1)= JX - IX - 1        
      NCC    = NCC + Z(IX+1) + 2        
      ANYNEW = 1        
      GO TO 1100        
C        
C     HERE IF CASECC SET AND XYCDB SET EXIST.        
C     FIRST, LOCATE CASECC SET.        
C        
 1070 ILIST  = ICC + NCC + 3        
      IX     = ICC + ILSYM        
      ISETNO = IX  + Z(IX) + 1        
 1071 ISET   = ISETNO + 2        
      NSET   = Z(ISETNO+1) + ISET - 1        
      IF (Z(ISETNO) .EQ. SETNO) GO TO 1080        
      ISETNO = NSET + 1        
      IF (ISETNO .LT. ILIST) GO TO 1071        
      GO TO 1100        
C        
C     COMPARE EACH POINT IN XYCDB REQUEST WITH CASECC SET.        
C     ADD ANY POINTS IN XYCDB NOT IN CASECC TO CASECC SET.        
C        
 1080 I = ISET        
      J = IXYSET        
      K = ILIST        
      L = ISET        
 1081 ARG = Z(J+1)        
 1082 IF (I-NSET) 1083,1085,1088        
 1083 IF (Z(I+1) .GT. 0) GO TO 1085        
      N = 2        
      IF (ARG-Z(I  )) 1088,1091,1084        
 1084 IF (ARG+Z(I+1)) 1091,1087,1086        
 1085 N = 1        
      IF (ARG-Z(I)) 1088,1087,1086        
 1086 I = I + N        
      GO TO 1082        
 1087 I = I + N        
      GO TO 1091        
 1088 IF (L .EQ. I) GO TO 1090        
      LN = I - 1        
      LL = L        
      DO 1089 L = LL,LN        
      Z(K) = Z(L)        
      K = K + 1        
 1089 CONTINUE        
      L = I        
 1090 Z(K) = ARG        
      K = K + 1        
 1091 J = J + 2        
      IF (J .LE. NXYSET) GO TO 1081        
      N = K - ILIST        
      IF (N .EQ.    0) GO TO 1100        
      IF (L .GT. NSET) GO TO 1094        
      DO 1092 LL = L,NSET        
      Z(K) = Z(LL)        
      K = K + 1        
 1092 CONTINUE        
      N = K - ILIST        
C        
C     IF NO NEW POINTS IN SET, CURRENT CASECC SET IS UNION.        
C     OTHERWISE, NEW SET IS UNION. TURN ON REQUEST FOR IT AND        
C     EXTEND END OF CASECC RECORD.        
C        
 1094 XSETNO    = XSETNO + 1        
      Z(IREQ)   = XSETNO        
      Z(IREQ+1) = 10*SETNO + Z(IREQ+1)        
      Z(IREQ+2) = -IABS(Z(IREQ+2))        
      SORT2     = 0        
      Z(ILIST-2)= XSETNO        
      Z(ILIST-1)= N        
      NCC       = NCC + N + 2        
      ANYNEW    = 1        
      GO TO 1100        
C        
C     HERE IF CASECC SET = ALL AND XY REQUEST EXISTS - TURN SORT2 ON.   
C        
 1098 Z(IREQ+2) = -IABS(Z(IREQ+2))        
      SORT2     = 0        
C        
C     TEST FOR COMPLETION OF ALL CASECC REQUESTS FOR CURRENT SUBCASE.   
C     WHEN COMPLETE, WRITE CURRENT SUBCASE ON SCRATCH FILE.        
C        
 1100 LOOP = LOOP + 2        
      IF (LOOP .LE. 13) GO TO 1041        
      CALL WRITE (SCR3,Z(ICC+1),NCC,1)        
C        
C     RETURN TO READ ANOTHER RECORD IN CASE CONTROL OR ANOTHER XYCDB    
C     SUBCASE        
C        
      IF (MASTER .EQ.        0) GO TO 1030        
      IF (SUBCSE .LE. Z(ICC+1)) GO TO 1020        
      GO TO 1030        
C        
C     FATAL FILE ERRORS        
C        
 2000 CALL MESAGE (N,FILE,NAM)        
 2001 N = -1        
      GO TO 2000        
 2002 N = -2        
      GO TO 2000        
      END        
