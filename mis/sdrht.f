      SUBROUTINE SDRHT        
C        
C     SPECIAL FLUX-DATA-RECOVERY MODULE FOR HBDY ELEMENTS IN HEAT       
C     TRANSFER.        
C        
C     DMAP CALLING SEQUENCE.        
C        
C     SDRHT SIL,USET,UGV,OEF1,SLT,EST,DIT,QGE,DLT,/OEF1X/V,N,TABS $     
C        
      LOGICAL         HAVIDS,CARDIN,LHBDY,TRANST,FOUND,MCH521        
      INTEGER         TABLST(13),Z,BUF(50),SYSBUF,RD,RDREW,WRT,WRTREW,  
     1                CLSREW,CLS,SUBR(2),NAME(2),EOR,IDPOS(3),OUTPT,    
     2                SLTYPS,LDWORD(16),UG,OEF1,SLT,EST,DIT,QGE,DLT,    
     3                OEF1X,BUF1,BUF2,BUF3,CORE,PASS,HBDYTP,MCBUGV(7),  
     4                FILE,ELTYPE,ESTWDS,ECPT(100),SLTAT,SLTREC,MCB(7), 
     5                EOL,GSIZE        
      REAL            RZ(1),RBUF(50),GRIDS(6)        
      CHARACTER       UFM*23,UWM*25,UIM*29,SFM*25,SWM*27        
      COMMON /XMSSG / UFM,UWM,UIM,SFM,SWM        
      COMMON /CONDAS/ CONSTS(5)        
      COMMON /SYSTEM/ KSYSTM(65)        
      COMMON /NAMES / RD,RDREW,WRT,WRTREW,CLSREW,CLS        
      COMMON /ZNTPKX/ AI(4),IROW,EOL        
CZZ   COMMON /ZZSDRH/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      COMMON /MACHIN/ MACH        
      COMMON /BLANK / TABS        
      EQUIVALENCE     (KSYSTM(1),SYSBUF),(KSYSTM(2),OUTPT),        
     1                (CONSTS(2),TWOPI ),(CONSTS(3),RADDEG),        
     2                (Z(1),RZ(1)), (BUF(1),RBUF(1))        
      DATA    TABLST / 4, 1105,11,1, 1205,12,2, 1305,13,3, 1405,14,4  / 
      DATA    LENTRY / 14   /, EOR,NOEOR  / 1, 0 /, SUBR/ 4HSDRH,2HT  / 
      DATA    IDPOS  / 2,1,5/, HBDYTP/ 52 /,     SLTYPS / 16 /        
      DATA    LDWORD / 6,6,4,4,6,6,2,5,5,6,6,7,2,2,5,5  /        
      DATA    UG,OEF1, SLT,EST,DIT,QGE,DLT,OEF1X /        
     1        103,104, 105,106,107,108,109, 201  /        
      DATA    GRIDS  / 1.0, 2.0, 2.0, 3.0, 4.0, 2.0     /        
C        
C     SET UP CORE AND BUFFERS        
C        
      BUF1   = KORSZ(Z) - SYSBUF - 2        
      BUF2   = BUF1 - SYSBUF - 2        
      BUF3   = BUF2 - SYSBUF - 2        
      CORE   = BUF3 - 1        
      IDREC  = 1        
      IELTAB = 1        
      PASS   = 0        
      HAVIDS = .FALSE.        
      CARDIN = .FALSE.        
      MCH521 = MACH.EQ.5 .OR. MACH.EQ.21        
C        
C     OPEN INPUT FORCES -OEF1- AND OUTPUT FORCES -OEF1X-.        
C        
      CALL OPEN  (*1190,OEF1,Z(BUF1),RDREW)        
      CALL OPEN  (*1200,OEF1X,Z(BUF2),WRTREW)        
      CALL FNAME (OEF1X,NAME)        
      CALL WRITE (OEF1X,NAME,2,EOR)        
      CALL FWDREC (*1220,OEF1)        
C        
C     COPY RECORD PAIRS OF DATA FROM OEF1 TO OEF1X UNTIL HBDY DATA IS   
C     DETECTED.        
C        
   10 LCORE = CORE - IDREC        
      IF (LCORE .LT. 300) CALL MESAGE (-8,0,SUBR)        
      FILE = OEF1        
      CALL READ (*1180,*30,OEF1,Z(IDREC),LCORE,NOEOR,IFLAG)        
      WRITE  (OUTPT,20) SWM        
   20 FORMAT (A27,' 3063, INPUT FORCES DATA BLOCK HAS INCORRECT DATA.') 
      GO TO 1220        
C        
C     MODIFY ID-RECORD IF THIS IS FOR HBDY ELEMENTS.        
C        
   30 IF (Z(IDREC+2) .NE. HBDYTP) GO TO 40        
      LHBDY = .TRUE.        
      GO TO 50        
   40 LHBDY = .FALSE.        
      GO TO 90        
C        
C     SET CONSTANTS FROM OEF1 ID RECORD.        
C        
   50 IF (Z(IDREC)/10 .EQ. 6) GO TO 70        
      LOADID = Z(IDREC+7)        
      TRANST = .FALSE.        
      GO TO 80        
   70 LOADID = Z(IDREC+7)        
      TIME   = RZ(IDREC+4)        
      TRANST = .TRUE.        
   80 LWORDS = Z(IDREC+9)        
      Z(IDREC+9) = 5        
C/////        
C     CALL BUG (4HTRAN ,90,TRANST,1)        
C/////        
   90 CALL WRITE (OEF1X,Z(IDREC),IFLAG,EOR)        
      IF (LHBDY) GO TO 120        
C        
C     NOT AN HBDY ELEMENT TYPE THUS COPY DATA ACROSS.        
C        
  100 CALL READ  (*1260,*110,OEF1,Z(IDREC),LCORE,NOEOR,IFLAG)        
      CALL WRITE (OEF1X,Z(IDREC),LCORE,NOEOR)        
      GO TO 100        
  110 CALL WRITE (OEF1X,Z(IDREC),IFLAG,EOR)        
      GO TO 10        
C        
C     HBDY ELEMENT DATA ENCOUNTERED.        
C        
  120 PASS = PASS + 1        
C        
C     ON FIRST PASS ELEMENT-DATA-TABLE IS FORMED.        
C        
C     EACH ENTRY WILL CONTAIN,        
C        
C      1) ELEMENT-ID (HBDY).        
C      2) FLUX-RADIATION TERM FOR THIS ELEMENT.        
C      3) FLUX-X FROM OEF1 DATA.        
C      4) APPLIED LOAD (USING SLT DATA).        
C      5) HBDY ELEMENT TYPE (1 TO 6).        
C      6) HBDY AREA FACTOR.        
C      7) ALPHA VALUE.        
C      8) V1(1) *        
C      9) V1(2)  *  VECTOR-V1        
C     10) V1(3) *        
C     11) V2(1) *        
C     12) V2(2)  *  VECTOR-V2        
C     13) V2(3) *        
C     14) OUTPUT ID*10 + DEVICE CODE (FROM OEF1).        
C        
C     ON PASSES OTHER THAN THE FIRST ONLY THE FLUX-X VALUE IS EXTRACTED 
C     FROM OEF1-HBDY-ENTRIES.        
C        
      JELTAB = IELTAB - 1        
C        
C     INPUT = ID*10+CODE, NAME1,NAME2,GRD-X,GRD-Y,GRD-Z,FLUX-X,FLUX-Y,  
C             FLUX-Z   (TOTAL OF 9 WORDS)        
C        
  130 CALL READ (*1260,*150,OEF1,BUF,LWORDS,NOEOR,IFLAG)        
      IF (PASS .GT. 1) GO TO 140        
      Z(JELTAB+1) = BUF(1)/10        
C        
C     STORE (FLUX-X) AND (OUTPUT ID*10 + DEVICE CODE).        
C        
  140 Z(JELTAB+ 3) = BUF(7)        
      RZ(JELTAB+2) = 0.0        
      Z(JELTAB+14) = BUF(1)        
      JELTAB = JELTAB + LENTRY        
      IF (JELTAB .GT. CORE) CALL MESAGE (-8,0,SUBR)        
      GO TO 130        
C        
C     END OF DATA.        
C        
  150 IF (PASS .GT. 1) GO TO 160        
      NELTAB = JELTAB        
      NUMBER = (NELTAB - IELTAB + 1)/LENTRY        
C        
C     OPEN UG FILE FOR INPUT OF UG VECTORS.        
C        
      CALL OPEN (*1220,UG,Z(BUF3),RDREW)        
      CALL FWDREC (*1220,UG)        
      MCBUGV(1) = UG        
      CALL RDTRL (MCBUGV)        
      GSIZE = MCBUGV(3)        
      GO TO 180        
  160 IF (JELTAB .EQ. NELTAB) GO TO 180        
      WRITE  (OUTPT,170) SWM,JELTAB,NELTAB        
  170 FORMAT (A27,' 3064, INCONSISTANT HBDY DATA RECORDS.  ',2I20)      
      GO TO 1220        
C        
C     ALL DATA FROM OEF1 IS AT HAND NOW.        
C     FILES ARE CLOSED WITHOUT REWIND.        
C        
  180 CALL CLOSE (OEF1,CLS)        
      CALL CLOSE (OEF1X,CLS)        
C        
C     ALLOCATE UG VECTOR SPACE ON FIRST PASS.        
C        
      IF (PASS .NE. 1) GO TO 190        
      IUG  = NELTAB + 1        
      NUG  = NELTAB + GSIZE        
      IUGZ = IUG - 1        
      IF (NUG + 5 .GT. CORE) CALL MESAGE (-8,0,SUBR)        
C        
C     BRING NEXT DISPLACEMENT VECTOR INTO CORE.        
C        
  190 DO 200 I = IUG,NUG        
      RZ(I) = TABS        
  200 CONTINUE        
C        
      CALL INTPK (*220,UG,0,1,0)        
  210 CALL ZNTPKI        
      KK = IUGZ + IROW        
      RZ(KK) = RZ(KK) + AI(1)        
      IF (EOL) 210,210,220        
C        
C     RAISE VECTOR RESULT TO 4TH POWER        
C        
  220 DO 230 I = IUG,NUG        
      RZ(I) = RZ(I)**4        
  230 CONTINUE        
C        
C     IF TRANSIENT PROBLEM SKIP ACCELERATION AND VELOCITY VECTORS       
C        
      IF (.NOT. TRANST) GO TO 250        
      DO 240 I = 1,2        
      CALL FWDREC (*250,UG)        
  240 CONTINUE        
  250 CONTINUE        
C/////        
C     CALL BUG (4HUG4  ,200,Z(IUG),NUG-IUG+1)        
C/////        
C        
C     IF NONLINEAR PROBLEM, COMPUTE FLUX RADIATION TERMS.        
C        
C                                            T           4        
C     (FLUX-RADIATION         ) = (Q           )(U +TABS)        
C                    EL-SUBSET      G,EL-SUBSET   G        
C        
      FILE = QGE        
      CALL OPEN (*261,QGE,Z(BUF1),RDREW)        
      IF (PASS .EQ. 1) GO TO 260        
      CALL FWDREC (*1260,QGE)        
      GO TO 280        
  261 IQGID = NUG + 1        
      NQGID = NUG        
      IDREC = NQGID        
      GO TO 311        
  260 CALL READ (*1260,*1270,QGE,BUF,-2,NOEOR,IFLAG)        
C        
C     ON FIRST PASS PICK UP ELEMENT ID LIST.        
C        
      IQGID = NUG + 1        
      CALL READ (*1260,*270,QGE,Z(IQGID),CORE-IQGID,NOEOR,IFLAG)        
      CALL MESAGE (-7,0,SUBR)        
  270 NQGID = NUG + IFLAG        
      IDREC = NQGID + 1        
C/////        
C     CALL BUG (4HQGID,410,Z(IQGID),NQGID-IQGID+1)        
C/////        
C        
C     EACH FLUX-RADIATION TERM IN THE ELEMENT TABLE IS CREATED BY       
C     FORMING THE DOT-PRODUCT OF THE COLUMN OF -QGE- HAVING THE        
C     SAME ELEMENT-ID WITH THE -UG- VECTOR IN CORE.        
C        
  280 DO 310 I = IQGID,NQGID,1        
      CALL INTPK (*310,QGE,0,1,0)        
C        
C     FIND OUT IF ID OF THIS VECTOR IS IN ELEMENT TABLE.        
C        
      KID = Z(I)        
      CALL BISLOC (*300,KID,Z(IELTAB),LENTRY,NUMBER,JPOINT)        
      JWORD = IELTAB + JPOINT        
      Z(JWORD) = 0        
C        
C     FORM DOT PRODUCT        
C        
  290 CALL ZNTPKI        
      K = IUGZ + IROW        
      RZ(JWORD) = RZ(JWORD) - AI(1)*RZ(K)        
      IF (EOL) 290,290,310        
C        
C     ID OF THIS COLUMN NOT IN ELEMENT TABLE        
C        
  300 CALL ZNTPKI        
      IF (EOL) 300,300,310        
  310 CONTINUE        
C/////        
C     CALL BUG (4HELTB ,440,Z(IELTAB),NELTAB-IELTAB+1)        
C/////        
      CALL CLOSE (QGE,CLSREW)        
C        
C     ON FIRST PASS, EST IS PASSED AND HBDY ELEMENTS CALLED.        
C        
  311 CONTINUE        
      IF (PASS .GT. 1) GO TO 380        
      FILE = EST        
      CALL GOPEN (EST,Z(BUF1),RDREW)        
      NEXT = IELTAB        
C        
C     READ THE ELEMENT TYPE        
C        
  320 CALL READ (*350,*1270,EST,ELTYPE,1,NOEOR,IFLAG)        
      IF (ELTYPE .EQ. HBDYTP) GO TO 330        
      CALL FWDREC (*1260,EST)        
      GO TO 320        
C        
C     HBDY ELEMENT-SUMMARY-TABLE DATA FOUND.        
C        
  330 ESTWDS = 53        
  340 CALL READ (*1260,*1270,EST,ECPT,ESTWDS,NOEOR,IFLAG)        
C        
C     CHECK TO SEE IF THIS ELEMENT IS IN OUTPUT SET.        
C        
      IF (Z(NEXT) - ECPT(1)) 350,370,340        
  350 WRITE  (OUTPT,360) SWM,Z(NEXT)        
  360 FORMAT (A27,' 3065, THERE IS NO EST DATA FOR HBDY ELEMENT ID =',  
     1        I10)        
      GO TO 1220        
C        
C     THIS ELEMENT IS IN TABLE.        
C        
  370 CALL HBDY (ECPT,ECPT,2,RBUF,BUF)        
C        
C     PLANT HBDY OUTPUTS INTO TABLE.        
C        
      Z(NEXT+ 4) = ECPT(2)        
      Z(NEXT+ 5) = BUF(2)        
      Z(NEXT+ 6) = ECPT(17)        
      Z(NEXT+ 7) = BUF(11)        
      Z(NEXT+ 8) = BUF(12)        
      Z(NEXT+ 9) = BUF(13)        
      Z(NEXT+10) = BUF(14)        
      Z(NEXT+11) = BUF(15)        
      Z(NEXT+12) = BUF(16)        
      NEXT = NEXT + LENTRY        
      IF (NEXT .LT. NELTAB) GO TO 340        
      CALL CLOSE (EST,CLSREW)        
C        
C     LOAD SET PROCESSING IF LOAD-SET-ID IS NON-ZERO.        
C        
 380  IF (LOADID) 944,944,390        
C        
C     OPEN SLT FOR LOAD DATA.        
C        
C        
  390 FILE = SLT        
      CALL OPEN (*1250,SLT,Z(BUF1),RDREW)        
      IF (HAVIDS) CALL FWDREC (*1260,SLT)        
      IF (HAVIDS) GO TO 810        
      HAVIDS = .TRUE.        
      ILDID  = NQGID + 1        
      NLDID  = ILDID - 1        
C        
C     IDS OF LOAD SETS NOT IN CORE THUS BRING IN IDS FROM HEADER RECORD.
C        
      IMAST  = ILDID        
      NSETS  = 0        
      NLDSET = 3        
      CALL READ (*1260,*1270,SLT,BUF,-2,NOEOR,IFLAG)        
  400 IF (NLDID+5 .GT. CORE) CALL MESAGE (-8,0,SUBR)        
      CALL READ (*1260,*410,SLT,Z(NLDID+1),1,NOEOR,IFLAG)        
      NSETS = NSETS + 1        
      Z(NLDID +2) = 1        
      Z(NLDID +3) = Z(NLDID+1)        
      RZ(NLDID+4) = 1.0        
      Z(NLDID +5) = NSETS        
      NLDID = NLDID + 5        
      GO TO 400        
C        
C     IF TRANSIENT PROBLEM THEN DLT OPERATIONS BEGIN        
C        
  410 IF (.NOT.TRANST) GO TO 800        
      FILE = DLT        
      CALL OPEN (*1250,DLT,Z(BUF2),RDREW)        
      CALL READ (*1260,*1270,DLT,BUF,3,NOEOR,IFLAG)        
      M = BUF(3)        
      FOUND = .FALSE.        
      IF (M .LE. 0) GO TO 430        
      DO 420 I = 1,M        
      CALL READ (*1260,*1270,DLT,BUF,1,NOEOR,IFLAG)        
      IF (BUF(1) .EQ. LOADID) FOUND = .TRUE.        
  420 CONTINUE        
C        
C     NOW READ RLOAD1, RLOAD2, TLOAD1, AND TLOAD2 IDS.        
C        
  430 IRTIDS = NLDID + 1        
      CALL READ (*1260,*440,DLT,Z(IRTIDS),CORE-IRTIDS,NOEOR,IFLAG)      
      CALL MESAGE (-7,0,SUBR)        
      GO TO 1220        
  440 NRTIDS = NLDID + IFLAG        
C        
C     IF LOADID WAS FOUND AMONG THE DLOAD IDS, SEARCH IS NOW MADE IN    
C     RECORD 1 OF THE DLT FOR THAT ID, AND ITS SUB-IDS.        
C        
      JJ1   = ILDID        
      JJ2   = NLDID        
      ILDID = NRTIDS + 1        
      NLDID = NRTIDS + 2        
      Z(ILDID  ) = LOADID        
      Z(ILDID+1) = 0        
      IF (.NOT. FOUND) GO TO 520        
C        
C     READ A MASTER DLOAD SET-ID.        
C        
  450 CALL READ (*1260,*1270,DLT,BUF,2,NOEOR,IFLAG)        
      IF (BUF(1) .EQ. LOADID) GO TO 470        
C        
C     SKIP SUB-ID DATA OF THIS MASTER        
C        
  460 CALL READ (*1260,*1270,DLT,BUF,2,NOEOR,IFLAG)        
      IF (BUF(2)) 450,460,460        
C        
C     MASTER-ID FOUND.  BUILD LOAD-SET-ID TABLE.        
C        
  470 FACTOR = RBUF(2)        
  472 IF (NLDID+11 .LE. CORE) GO TO 480        
      CALL MESAGE (8,0,SUBR)        
      GO TO 1220        
  480 CALL READ (*1260,*1270,DLT,BUF,2,NOEOR,IFLAG)        
      IF (BUF(2)) 540,540,490        
  490 Z(ILDID +1) = Z(ILDID+1) + 1        
      Z(NLDID +1) = BUF(2)        
      RZ(NLDID+2) = 0.0        
      Z(NLDID +3) = 0        
      RZ(NLDID+4) = RBUF(1)*FACTOR        
      Z(NLDID +5) = 0        
      NLDID = NLDID + 11        
      GO TO 472        
C        
C     LOADID NOT AMONG DLOADS FOR THIS TRANSIENT PROBLEM        
C        
  520 Z(ILDID+1) = 1        
      IF (NLDID+13 .LE. CORE) GO TO 530        
      CALL MESAGE (8,0,SUBR)        
      GO TO 1220        
  530 Z(NLDID +1) = Z(ILDID)        
      RZ(NLDID+2) = 0.0        
      Z(NLDID +3) = 0        
      RZ(NLDID+4) = 1.0        
      Z(NLDID +5) = 0        
      NLDID = NLDID + 11        
C        
C     IF THERE ARE ANY DLOAD CARDS AT ALL THEN BALANCE OF (OR ALL OF)   
C     RECORD 1 IS NOW SKIPPED.        
C        
  540 IF (M .GT. 0) CALL FWDREC (*1260,DLT)        
C        
C     NOW PICKING UP DATA NEEDED OF DYNAMIC LOAD SET RECORDS.        
C        
      K1 = ILDID + 2        
      K2 = NLDID        
      DO 580 I = IRTIDS,NRTIDS        
C        
C     READ THE LOAD TYPE        
C        
      CALL READ (*1260,*1270,DLT,BUF,2,NOEOR,IFLAG)        
      IF (BUF(1).NE.3 .AND. BUF(1).NE.4) GO TO 570        
C        
C     CHECK AND SEE IF THIS TLOAD ID IS AMONG THE SUB-IDS        
C        
      DO 550 J = K1,K2,11        
      IF (Z(J) .EQ. Z(I)) GO TO 560        
  550 CONTINUE        
      GO TO 570        
C        
C     YES THIS RECORD IS NEEDED.  THUS PUT ITS DATA IN TABLE.        
C        
  560 Z(J+4) = BUF(1)        
C        
C     SLT ID INTO TABLE        
C        
      Z(J) = -BUF(2)        
C        
C     SET SLT RECORD NUMBER        
C        
      K = 0        
      DO 565 L = JJ1,JJ2,5        
      K = K + 1        
      IF (Z(L) .EQ. BUF(2)) GO TO 566        
  565 CONTINUE        
      K = 0        
  566 Z(J+2) = K        
      CALL READ (*1260,*1270,DLT,Z(J+5),6,EOR,IFLAG)        
      IF (BUF(1) .EQ. 3) Z(J+6) = 0        
      GO TO 580        
  570 CALL FWDREC (*1260,DLT)        
  580 CONTINUE        
C        
C     CHECK IS NOW MADE TO INSURE ALL SUB-IDS RECEIVED DLT DATA.        
C        
C        
C     SET SLT IDS POSITIVE        
C        
      DO 581 I = K1,K2,11        
      Z(I) = IABS(Z(I))        
  581 CONTINUE        
      DO 610 I = K1,K2,11        
      IF (Z(I+4)) 590,590,610        
C        
C     ERROR        
C        
  590 WRITE  (OUTPT,600) UWM,Z(I)        
  600 FORMAT (A25,' 3066, THERE IS NO TLOAD1 OR TLOAD2 DATA FOR LOAD-', 
     1       'ID =',I9)        
  610 CONTINUE        
C        
      CALL CLOSE (DLT,CLSREW)        
      NLDSET = 11        
C        
C     SORT SUB-ID TABLE ON SLT RECORD NUMBERS.        
C        
      CALL SORT (0,0,11,3,Z(K1),K2-K1+1)        
C/////        
C     CALL BUG (4HTABL,640,Z(K1),K2-K1+1)        
C        
C     CONSTRUCTION OF TABLE-ID LIST.        
C        
      ITABID = NLDID + 1        
      NTABID = NLDID + 1        
C        
C     FIRST GET TABLE ID-S PRESENT IN THE SUB-ID TABLE.        
C        
      DO 680 I = K1,K2,11        
C        
C     CHECK FOR OTHER THAN TLOAD1 TYPE CARD        
C        
      IF (Z(I+4) .NE. 3) GO TO 680        
C        
C     CHECK FOR ID IN TABLE.        
C        
      IF (NTABID .LE. ITABID) GO TO 660        
      DO 650 J = ITABID,NTABID        
      IF (Z(I+5) .EQ. Z(J)) GO TO 680        
  650 CONTINUE        
  660 NTABID = NTABID + 1        
      IF (NTABID .GT. CORE) CALL MESAGE (-8,0,SUBR)        
      Z(NTABID) = Z(I+5)        
  680 CONTINUE        
C        
C     NOW PASS SLT AND GET ANY TABLE IDS PRESENT IN QVECT PORTION OF    
C     RECORDS WE WILL BE USING.  (SLT IS CURRENTLY POSITIONED AT FIRST  
C     RECORD.)        
C        
      SLTAT = 1        
      FILE  = SLT        
      DO 780 I = K1,K2,11        
      NGO = Z(I+2) - SLTAT        
      IF (NGO) 780,710,690        
  690 DO 700 J = 1,NGO        
      CALL FWDREC (*1260,SLT)        
  700 CONTINUE        
      SLTAT = SLTAT + NGO        
C        
C     LOOK FOR QVECT CARDS.        
C        
  710 CALL READ (*1260,*770,SLT,BUF,2,NOEOR,IFLAG)        
      ITYPE  = BUF(1)        
      NCARDS = BUF(2)        
      NWORDS = LDWORD(ITYPE)        
      IF (ITYPE .NE. 16) GO TO 760        
C        
C     QVECT CARDS FOUND        
C        
      IF (NCARDS .LE. 0) GO TO 710        
      DO 750 J = 1,NCARDS        
      CALL READ (*1260,*1270,SLT,BUF,NWORDS,NOEOR,IFLAG)        
      DO 740 K = 2,4        
C     IF (BUF(K).LE.0 .OR. BUF(K).GT.99999999) GO TO 740        
      L = NUMTYP(BUF(K))        
      IF (MCH521 .AND. BUF(K).GT.16000 .AND. BUF(K).LE.99999999) L= 1   
      IF (BUF(K).LE.0 .OR. L.NE.1) GO TO 740        
C        
C     TABLE ID FOUND.  ADD TO LIST IF NOT YET IN.        
C        
      IF (NTABID .LE. ITABID) GO TO 730        
      DO 720 L = ITABID,NTABID        
      IF (BUF(K) .EQ. Z(L)) GO TO 740        
  720 CONTINUE        
  730 NTABID = NTABID + 1        
      IF (NTABID .GT. CORE) CALL MESAGE (-8,0,SUBR)        
      Z(NTABID) = BUF(K)        
  740 CONTINUE        
  750 CONTINUE        
      GO TO 710        
  760 IF (ITYPE .GT. 16) GO TO 1170        
      NWDCRD = -NWORDS*NCARDS        
      CALL READ (*1260,*1270,SLT,BUF,NWDCRD,NOEOR,IFLAG)        
      GO TO 710        
  770 SLTAT = SLTAT + 1        
  780 CONTINUE        
      NUMTAB   = NTABID - ITABID        
      Z(ITABID)= NUMTAB        
      NUMTAB   = Z(ITABID)        
C        
C     TABLE-ID LIST COMPLETE. NOW SORT IT AND PRIME TAB ROUTINE.        
C        
      CALL REWIND (SLT)        
      CALL FWDREC (*1260,SLT)        
C/////        
C     CALL BUG (4HTBID,555,Z(ITABID),NTABID-ITABID+1)        
C/////        
      IDIT = NTABID + 1        
      NDIT = IDIT        
      LZ   = CORE - IDIT        
      IF (LZ .GT. 10) GO TO 790        
      CALL MESAGE (8,0,SUBR)        
      GO TO 1220        
  790 CONTINUE        
      IF (NUMTAB .EQ. 0) GO TO 792        
      CALL SORT (0,0,1,1,Z(ITABID+1),NUMTAB)        
      CALL PRETAB(DIT,Z(IDIT),Z(IDIT),Z(BUF2),LZ,LUSED,Z(ITABID),TABLST)
      NDIT = IDIT + LUSED        
C/////        
C     CALL BUG (4HDITS,557,Z(IDIT),NDIT-IDIT+1)        
C/////        
  792 CONTINUE        
      IDREC = NDIT + 1        
      GO TO 810        
C 795 CALL FWDREC (SLT)        
C     GO TO 810        
C        
C     DETERMINE IF -LOADID- IS IN LIST OF LOAD SET IDS.        
C        
  800 IDREC = NLDID + 1        
C/////        
C     CALL BUG (4HLD1   ,360,Z(ILDID),NLDID-ILDID+1)        
C/////        
  810 CONTINUE        
      NMAST = NLDID        
      J = ILDID        
  820 IF (J .LE. NLDID) GO TO 910        
C        
C     LOAD SET ID LIST EXHAUSTED.        
C     BRING IN ANY LOAD CARDS IF NOT YET IN.        
C        
      IF (CARDIN) GO TO 920        
C        
C     THE LOAD-SET-ID TABLE HAS THE FOLLOWING FORMAT.        
C        
C     MASTER ID                                ******       Z(ILDID)    
C     NUMBER OF SUB-IDS FOR THIS MASTER              *        
C     SUB-ID             **  3-WORDS  ***             *        
C     SCALE FACTOR = F(T)  * ONLY IF     *             *        
C     SLT RECORD NUMBER  **  STATICS      * 11 WORDS   * REPEATS FOR    
C     CONSTANT SCALE FACTOR               * REPEATS    * EACH MASTER    
C     TYPE OF TLOAD =(3 OR 4)             * FOR EACH   * ID PRESENT     
C     TYPE3 TABLE ID (OR) TYPE4 T1        * SUB-ID     *        
C           0                   T2        * OF THIS    *        
C           0                   OMEGA     * MASTER     *        
C           0                   PHI       * ID         *        
C           0                   N        *             *        
C           0                   ALPHA ***              *        
C              .                                       *        
C              .                                      *        
C              .                                     *        
C                                              ******        
C             ...                    ...        
C             ...                    ...        
C             ...                    ...                    Z(NLDID)    
C        
C        
      CARDIN = .TRUE.        
C        
C     FORWARD SLT TO LOAD CARD RECORD.        
C        
      IF (NSETS) 850,850,830        
  830 DO 840 I = 1,NSETS        
      CALL FWDREC (*1250,SLT)        
  840 CONTINUE        
C        
C     READ AND ENTER MASTER ID INTO TABLE        
C        
  850 IF (NLDID+2 .GT. CORE) CALL MESAGE (-8,0,SUBR)        
      CALL READ (*1260,*900,SLT,Z(NLDID+1),2,NOEOR,IFLAG)        
      SCALE  = RZ(NLDID+2)        
      NLDID  = NLDID + 2        
      JCOUNT = NLDID        
      Z(JCOUNT) = 0        
C        
C     READ THE (SID, SCALE-FACTOR)  PAIRS FOR THIS ID.        
C        
  860 IF (NLDID+3 .GT. CORE) CALL MESAGE (-8,0,SUBR)        
      CALL READ (*1260,*1270,SLT,Z(NLDID+1),2,NOEOR,IFLAG)        
      IF (Z(NLDID+1) .EQ. -1) GO TO 890        
C        
C     MULTIPLY SUBID SCALE FACTOR BY MASTER SCALE FACTOR.        
C        
      RZ(NLDID+2) = RZ(NLDID+2)*SCALE        
C        
C     DETERMIND SLT RECORD NUMBER OF THIS SUB ID.        
C        
      KREC = 1        
      DO 870 I = IMAST,NMAST,NLDSET        
      IF (Z(NLDID+1) .EQ. Z(I)) GO TO 880        
      KREC = KREC + 1        
  870 CONTINUE        
      KREC = 0        
  880 Z(NLDID+3) = KREC        
      NLDID = NLDID + 3        
      Z(JCOUNT) = Z(JCOUNT) + 1        
      GO TO 860        
C        
C     SORT ALL SUB-ID 3 WORD GROUPS ON SLT RECORD NUMBER.        
C        
  890 CALL SORT (0,0,3,3,Z(JCOUNT+1),NLDID-JCOUNT)        
      GO TO 850        
C        
C     REPOSITION SLT TO BEGINNING OF FIRST SLT RECORD        
C        
  900 IDREC = NLDID + 1        
C/////        
C     CALL BUG (4HLDID,460,Z(ILDID),NLDID - ILDID+1)        
C/////        
      CALL REWIND (SLT)        
      CALL FWDREC (*1260,SLT)        
      GO TO 820        
C        
C     CONTINUE SEARCH FOR LOADID        
C        
  910 IF (LOADID .EQ. Z(J)) GO TO 940        
C        
C     POSITION -J- TO NEXT LOAD-SET-ID IN TABLE        
C        
      J = J + NLDSET*Z(J+1) + 2        
      GO TO 820        
C        
C     -LOADID- NOT FOUND ANYWHERE.        
C        
  920 WRITE  (OUTPT,930) UWM,LOADID        
  930 FORMAT (A25,' 3067, LOAD SET ID =',I9,' IS NOT PRESENT.')        
      GO TO 1220        
C        
C     MATCH ON MASTER ID HAS BEEN FOUND.        
C        
  940 NLOADS = Z(J+1)        
      ILOAD  = J + 2        
      NLOAD  = ILOAD + NLDSET*NLOADS - 1        
C        
C     PROCESS ALL THE LOAD RECORDS FOR THIS MASTER-ID        
C        
      SLTAT = 1        
C/////        
C     CALL BUG (4HLOAD ,500,Z(ILOAD),NLOAD-ILOAD+1)        
C/////        
C        
C     INITIALIZE APPLIED LOAD TO 0.0 FOR ALL ELEMENTS IN TABLE        
C        
 944  CONTINUE        
      DO 945 I = IELTAB,NELTAB,LENTRY        
      RZ(I+3) = 0.0        
  945 CONTINUE        
      IF (LOADID .LE. 0) GO TO 1140        
      DO 1130 I = ILOAD,NLOAD,NLDSET        
      FACTOR = RZ(I+1)        
      IF (.NOT.TRANST) GO TO 960        
C        
C     FACTOR HAS TO BE FOUND AS F(TIME)        
C        
      IF (Z(I+4) .EQ. 4) GO TO 950        
      CALL TAB (Z(I+5),TIME,YVALUE)        
      FACTOR = RZ(I+3)*YVALUE        
      GO TO 960        
  950 TT = TIME - RZ(I+5)        
      IF (TT .EQ. 0.0) GO TO 951        
      IF (TT.LE.0.0 .OR. TIME.GE.RZ(I+6)) GO TO 955        
      FACTOR = RZ(I+3)*EXP(RZ(I+10)*TT)*(TT**RZ(I+9))*COS(TWOPI*        
     1         RZ(I+7)*TT + RZ(I+8)/RADDEG)        
      GO TO 960        
  951 IF (RZ(I+9) .NE. 0.0) GO TO 955        
      FACTOR = COS(TWOPI*RZ(I+7))        
      GO TO 960        
  955 FACTOR = 0.0        
  960 SLTREC = Z(I+2)        
      IF (SLTREC.LE.0 .OR. FACTOR.EQ.0.0) GO TO 1130        
C        
C     POSITION SLT TO RECORD DESIRED.        
C        
  980 NGO = SLTREC - SLTAT        
      IF (NGO) 990,1020,1000        
C        
C     NEED TO BACK UP ON SLT.        
C        
  990 CALL BCKREC (SLT)        
      SLTAT = SLTAT - 1        
      GO TO 980        
C        
C     NEED TO GO FORWARD ON SLT        
C        
 1000 DO 1010 J = 1,NGO        
      CALL FWDREC (*1260,SLT)        
 1010 CONTINUE        
      SLTAT = SLTAT + NGO        
C        
C     SLT IS NOW POSITIONED TO LOAD RECORD DESIRED.        
C        
C        
C     GENERATE LOADS FOR THOSE ELEMENTS IN THE TABLE USING ONLY QBDY1,  
C     QBDY2, AND QVECT CARDS.        
C        
 1020 CALL READ (*1260,*1130,SLT,BUF,2,NOEOR,IFLAG)        
      ITYPE = BUF(1)        
      IF (ITYPE .LE. SLTYPS) GO TO 1040        
      WRITE  (OUTPT,1030) SWM,ITYPE        
 1030 FORMAT (A27,' 3068, UNRECOGNIZED CARD TYPE =',I9,        
     1       ' FOUND IN -SLT- DATA BLOCK.')        
      GO TO 1220        
 1040 NCARDS = BUF(2)        
      IF (NCARDS) 1020,1020,1050        
 1050 NWORDS = LDWORD(ITYPE)        
      IF (ITYPE.GE.14 .AND. ITYPE.LE.16) GO TO 1060        
      NWDCRD = -NWORDS*NCARDS        
      CALL READ (*1260,*1270,SLT,BUF,NWDCRD,NOEOR,IFLAG)        
      GO TO 1020        
 1060 ITYPE = ITYPE - 13        
      JID = IDPOS(ITYPE)        
      DO 1120 K = 1,NCARDS        
C        
C     READ A QBDY1, QBDY2, OR QVECT ENTRY.        
C        
      CALL READ (*1260,*1270,SLT,BUF,NWORDS,NOEOR,IFLAG)        
C        
C     CHECK FOR ID IN THE TABLE (OTHERWISE SKIP).        
C        
      CALL BISLOC (*1120,BUF(JID),Z(IELTAB),LENTRY,NUMBER,JPOINT)       
      KK = IELTAB + JPOINT        
C        
C     THIS ELEMENT IS IN TABLE, THUS COMPUTE AND SUM IN THE LOAD.       
C        
      GO TO (1070,1080,1090), ITYPE        
 1070 RZ(KK+2) = RZ(KK+2) + RZ(KK+4)*RBUF(1)*FACTOR        
      GO TO 1120        
C        
 1080 KTYPE    = Z(KK+3)        
      RZ(KK+2) = RZ(KK+2) + FACTOR*RZ(KK+4)*(RBUF(2)+RBUF(3) + RBUF(4) +
     1           RBUF(5))/GRIDS(KTYPE)        
      GO TO 1120        
C        
C        
C     CALL TAB IF E1,E2,E3 OF QVECT DATA ARE TABLE ID-S IMPLYING        
C     TIME DEPENDENCE        
C        
 1090 IF (.NOT.TRANST) GO TO 1099        
      DO 1094 KKK = 2,4        
C     IF (BUF(KKK).LE.0 .OR. BUF(KKK).GT.99999999) GO TO 1094        
      L = NUMTYP(BUF(KKK))        
      IF (MCH521 .AND. BUF(KKK).GT.16000 .AND. BUF(KKK).LE.99999999)    
     1    L = 1        
      IF (BUF(KKK).LE.0 .OR. L.NE.1) GO TO 1094        
      CALL TAB (BUF(KKK),TIME,YVALUE)        
      RBUF(KKK) = YVALUE        
 1094 CONTINUE        
 1099 KTYPE = Z(KK+3)        
      C = RBUF(2)*RZ(KK+6) + RBUF(3)*RZ(KK+7) + RBUF(4)*RZ(KK+8)        
      IF (KTYPE .EQ. 6) GO TO 1110        
      IF (C) 1100,1100,1120        
 1100 RZ(KK+2) = RZ(KK+2) - C*RZ(KK+4)*RZ(KK+5)*RBUF(1)*FACTOR        
      GO TO 1120        
 1110 RZ(KK+2) = RZ(KK+2) + FACTOR*RZ(KK+4)*RBUF(1)*RZ(KK+5)*SQRT(C*C + 
     1  (RBUF(2)*RZ(KK+9) + RBUF(3)*RZ(KK+10) + RBUF(4)*RZ(KK+11))**2)  
C        
 1120 CONTINUE        
C        
 1130 CONTINUE        
      CALL CLOSE (SLT,CLSREW)        
C/////        
C     CALL BUG (4HTELT,670,Z(IELTAB),NELTAB-IELTAB+1)        
C/////        
C        
C     ELEMENT TABLE IS NOW COMPLETE FOR OUTPUT.        
C        
 1140 FILE = OEF1X        
      CALL OPEN (*1250,OEF1X,Z(BUF1),WRT)        
      DO 1160 I = IELTAB,NELTAB,LENTRY        
      BUF( 1) = Z(I+13)        
      RBUF(2) = RZ(I+3)        
      RBUF(3) = RZ(I+2)        
      RBUF(4) = RZ(I+1)        
      RBUF(5) = RBUF(2) + RBUF(3) + RBUF(4)        
      CALL WRITE (OEF1X,BUF(1),5,NOEOR)        
 1160 CONTINUE        
      CALL WRITE (OEF1X,0,0,EOR)        
      FILE = OEF1        
      CALL OPEN (*1250,OEF1,Z(BUF2),RD)        
      GO TO 10        
 1170 WRITE (OUTPT,1030)ITYPE        
      GO TO 1220        
C        
C     ALL PROCESSING COMPLETE.        
C        
 1180 MCB(1) = OEF1        
      CALL RDTRL (MCB)        
      MCB(1) = OEF1X        
      CALL WRTTRL (MCB)        
      GO TO 1220        
C        
C     ERROR CONDITIONS.        
C        
 1190 RETURN        
C        
 1200 WRITE  (OUTPT,1210) UWM        
 1210 FORMAT (A25,' 3069, OUTPUT DATA BLOCK FOR FORCES IS PURGED.')     
 1220 CALL CLOSE (OEF1,CLSREW)        
      CALL CLOSE (OEF1X,CLSREW)        
      CALL CLOSE (UG,CLSREW)        
      CALL CLOSE (EST,CLSREW)        
      CALL CLOSE (SLT,CLSREW)        
      CALL CLOSE (DLT,CLSREW)        
      GO TO 1190        
 1250 N = 1        
      GO TO 1280        
 1260 N = 2        
      GO TO 1280        
 1270 N = 3        
 1280 CALL MESAGE (N,FILE,SUBR)        
      GO TO 1220        
      END        
