      SUBROUTINE MBGAE(AJJL,IN17,A,F,DF,F1,DF1,F2,DF2,Q,Q1,Q2,MOOD)
C
C     MULTIPLY SUM OBTAINED PREVIOUSLY BY SCRIPT A FACTOR
C
      LOGICAL  CNTRL2 , CNTRL1 , CRANK1 , CRANK2 , ASYM , DEBUG
      INTEGER AJJL
      REAL MACH
      DIMENSION F(1),DF(1),F1(1),DF1(1),F2(1),DF2(1)
      COMPLEX A(1),Q(1),Q1(1),Q2(1)
      COMMON /MBOXC/ NJJ ,CRANK1,CRANK2,CNTRL1,CNTRL2,NBOX,
     *  NPTS0,NPTS1,NPTS2,ASYM,GC,CR,MACH,BETA,EK,EKBAR,EKM,
     *  BOXL,BOXW,BOXA ,NCB,NSB,NSBD,NTOTE,KC,KC1,KC2,KCT,KC1T,KC2T
      COMMON /SYSTEM/ SYSBUF,N6
      COMMON /AMGMN  / MCB(7)
      DATA    DEBUG /.FALSE./                                           
C                                                                       
      GCK  =  GC * BOXW
      DO 10 I=1,NJJ
   10 A(I) = (0.0,0.0)
      DO 1630 I=1,NPTS0
      CALL FREAD(IN17,F  ,KCT ,0)
      CALL FREAD(IN17,DF ,KCT ,0)
      DO 1620 J=1,KC
      A(I)      = A(I)      + CMPLX( DF(J),-EK*F(J))*Q(J)
 1620 CONTINUE
      IF( KC.EQ.KCT )  GO TO 1630
      KCC  =  KC + 1
      DO   1625   J = KCC,KCT
      A(I)       = A(I)      + F(J)*Q(J)
 1625 CONTINUE
 1630 CONTINUE
      IF( .NOT. CNTRL1 ) GO TO 1660
      JJ = NPTS0
      DO 1650 I=1,NPTS1
      CALL FREAD(IN17,F1 ,KC1T,0)
      CALL FREAD(IN17,DF1,KC1T,0)
      DO 1640 J=1,KC1
      A(I+JJ)   = A(I+JJ)   + CMPLX( DF1(J),-EK*F1(J))*Q1(J)
 1640 CONTINUE
      IF( KC1.EQ.KC1T )  GO TO 1650
      KCC1  =  KC1 + 1
      DO   1645   J = KCC1,KC1T
      A(I+JJ)    =  A(I+JJ)   + F1(J)*Q1(J)
 1645 CONTINUE
 1650 CONTINUE
 1660 IF( .NOT. CNTRL2 ) GO TO 1700
      JJ = JJ + NPTS1
      DO 1690 I=1,NPTS2
      CALL FREAD(IN17,F2 ,KC2T,0)
      CALL FREAD(IN17,DF2,KC2T,0)
      DO 1680 J=1,KC2
      A(I+JJ)   = A(I+JJ)   + CMPLX( DF2(J),-EK*F2(J))*Q2(J)
 1680 CONTINUE
      IF( KC2.EQ.KC2T )  GO TO 1690
      KCC2  = KC2 + 1
      DO   1685   J = KCC2,KC2T
      A(I+JJ)    = A(I+JJ)   + F2(J)*Q2(J)
 1685 CONTINUE
 1690 CONTINUE
 1700 CONTINUE
      CALL BCKREC(IN17)
      DO 1710 I=1,NJJ
      A(I) = A(I) * GCK
 1710 CONTINUE
      CALL PACK(A,AJJL,MCB)
C
C     PRINT OUT GENERALIZED AERODYNAMIC FORCE COEFFICIENTS
C
      IF(.NOT.DEBUG) RETURN
      IF(MOOD.GT.1) GO TO 2100
      WRITE  (N6 , 1900 )  MACH ,  BOXL , EK , BOXW
 1900 FORMAT  ( 1H1 , 31X , 30HGENERALIZED AERODYNAMIC FORCE            
     *      , 12HCOEFFICIENTS / 1H0 , 9X , 11HMACH NUMBER , F9.3 ,      
     *        40X , 10HBOX LENGTH , F12.6 / 1H0                         
     *      , 9X , 33HREDUCED FREQUENCY  ( ROOT CHORD ) , F10.5 , 17X   
     *      , 9HBOX WIDTH , F13.6 / 1H0 , 42X , 21H- -  A ( I , J )  - -
     *      / 6H-  ROW , 9X , 4HREAL , 10X , 4HIMAG , 14X , 4HREAL , 10X
     *      , 4HIMAG , 14X , 4HREAL , 10X , 4HIMAG )                    
 2100 WRITE(N6,2000) MOOD, (A(J),J=1,NJJ)
 2000 FORMAT  ( 1H0 , I4 , 3 ( E18.4 , E14.4 ) / ( 1H0 , 4X , 3 ( E18.4 
     *        , E14.4 ) ) )                                             
      RETURN
      END
