      SUBROUTINE PLTSET        
C        
C     COMMENTS FROM G.C. -        
C     THE DRIVER FOR DMAP MODULE PLTSET IS DPLTST        
C     THIS ROUTINE HAS NOTHING TO DO WITH DPLTST.  IT IS CALLED ONLY    
C     BY PARAM (IN MODULE PLOT), XYPLOT, AND SEEMAT        
C        
C        
      LOGICAL         TAPBIT        
      INTEGER         CHRWRD,PBFSIZ,PBUFSZ,PDATA,PLTDAT,PLTYPE,        
     1                PLOTER,PLT1,PLT2,PLTNUM,OFFSCL        
      REAL            XYMAX(2),CNTCHR(2),XYSIZE(2)        
      CHARACTER       UFM*23,UWM*25,UIM*29        
      COMMON /XMSSG / UFM,UWM,UIM        
      COMMON /BLANK / SKP4(4),PLTNUM        
      COMMON /XXPARM/ PBUFSZ,SKPARM(6),PAPSIZ(2),SKP235(226),OFFSCL     
      COMMON /PLTDAT/ MODEL,PLOTER,REG(2,2),AXYMAX(2),XYEDGE(11),CHRSCL,
     1                PDATA(20),PLTDAT(20,1)        
      COMMON /MACHIN/ MACH        
      COMMON /SYSTEM/ KSYSTM(65)        
      EQUIVALENCE     (PDATA(1),XYMAX(1)) ,  (PDATA(3),CNTSIN)  ,       
     1                (PDATA(4),CNTCHR(1)),  (PDATA(10),PLTYPE) ,       
     2                (PDATA(12),PBFSIZ)  ,  (NOUT  ,KSYSTM( 2)),       
     3                (CHRWRD,KSYSTM(41)) ,  (ITRACK,KSYSTM(59))        
      DATA    XYSIZE/ 11.0, 8.5 /,  PLT1,PLT2 / 4HPLT1, 4HPLT2  /       
C        
C     INITIALIZE -PDATA-        
C        
      DO 100 I = 1,20        
      PDATA(I) = PLTDAT(I,PLOTER)        
  100 CONTINUE        
C        
C     PLT2 FILE WAS HARD CODED INTO THE 11TH WORD OF PLTDAT(11,PLOTER)  
C     BY PLOTBD. IF USER REQUESTS PLT1 FILE, WE MUST MAKE A SWITCH HERE 
C        
      IF (.NOT.TAPBIT(PLT2) .AND. TAPBIT(PLT1)) PDATA(11) = PLT1        
      IF (PLTNUM.EQ.0 .AND. OFFSCL.EQ.0) WRITE (NOUT,110) UIM,PDATA(11) 
  110 FORMAT (A29,', PLOT FILE GOES TO ',A4)        
C        
      IF (OFFSCL .EQ. 0) OFFSCL = 1        
C        
C     SCALE THE CHARACTURE SIZE BEFORE SETTING BORDERS        
C        
      CNTCHR(1) = CHRSCL*CNTCHR(1)        
      CNTCHR(2) = CHRSCL*CNTCHR(2)        
      PBUFSZ    = PBFSIZ/CHRWRD        
C        
C     FOR UNIVAC 9 TRACK CALCOMP PLOT TAPES QUARTER WORD MODE WILL      
C     BE USED LIMITING THE NUMBER OF CHARACTERS PER WORD TO 4        
C     ITRACK = 2 FOR 9 TRACK TAPES - OTHERWISE 1 FOR 7 TRACK TAPES      
C     THE DEFAULT IS FOR 7 TRACK TAPES        
C        
C     IF (MACH.EQ.3 .AND. ITRACK.EQ.2) PBUFSZ = PBFSIZ/4        
C        
C     SINCE GENERAL PLOTTER IS THE ONLY ONE SUPPORTED BY NASTRAN, THE   
C     PLOT BUFFER FOR UNIVAC MUST BE 500 WORDS FOR BOTH FORTRAN V AND   
C     ASCII FORTRAN. (SEE PROG. MANUAL PAGE 6.10-15)        
C        
      IF (MACH .EQ. 3) PBUFSZ = PBFSIZ/6        
C        
      PLTYPE = MODEL        
C        
C     INITIALIZE PAPER SIZE AND BORDERS        
C        
      DO 130 I = 1,2        
      IF (IABS(PLTYPE)-2) 121,125,124        
  121 IF (PLTYPE) 122,122,123        
C        
C     CRT PLOTTERS        
C        
  122 AXYMAX(I) = XYMAX(I) - CNTCHR(I)        
      XYEDGE(I) = CNTCHR(I)*.5        
      GO TO 129        
  123 AXYMAX(I) = XYMAX(I)        
      XYEDGE(I) = 0.        
      GO TO 129        
C        
C     DRUM PLOTTERS        
C        
  124 IF (PAPSIZ(I) .LE. 0.0) PAPSIZ(I) = XYMAX(I)/CNTSIN        
      GO TO (127,126), I        
C        
C     TABLE PLOTTERS        
C        
  125 IF (PAPSIZ(I) .LE. 0.0) PAPSIZ(I) = XYSIZE(I)        
C        
  126 IF (CNTSIN*PAPSIZ(I) .GT. XYMAX(I)) PAPSIZ(I) = XYMAX(I)/CNTSIN   
  127 AXYMAX(I) = CNTSIN*PAPSIZ(I) - CNTSIN        
      XYEDGE(I) = CNTSIN*.5        
  129 REG(I,1)  = 0.        
      REG(I,2)  = AXYMAX(I)        
  130 CONTINUE        
C        
      RETURN        
      END        