      SUBROUTINE CMSOFO        
C        
C     THIS ROUTINE GENERATES THE NEW SOF DATA FOR A COMBINATION.        
C        
      EXTERNAL        RSHIFT,ANDF        
      LOGICAL         TDAT,TOCOPN,LONLY        
      INTEGER         PORA,PAPP,LODS,LOAP,        
     1                BUF1,BUF3,CE(9),CNAM,COMBO,SCSFIL,SCR1,BUF2,SCORE,
     2                SCCONN,SBGSS,SCTOC,Z,AAA(2),GETIP,ENT(5),        
     3                NAMOLD(14),EOG,SCBDAT,SCCSTM,OUTT,RSHIFT,ANDF     
      DIMENSION       SAV1(3),SAV2(9),RZ(1),        
     1                TMAT(9),ECPT(4),RENT(3),LIST(32)        
      CHARACTER       UFM*23        
      COMMON /XMSSG / UFM        
      COMMON /CMB001/ SCR1,SCR2,SCBDAT,SCSFIL,SCCONN,SCMCON,SCTOC,      
     1                GEOM4,CASECC,SCCSTM        
      COMMON /CMB002/ BUF1,BUF2,BUF3,BUF4,BUF5,SCORE,LCORE,INPT,OUTT    
      COMMON /CMB003/ COMBO(7,5),CONSET,IAUTO,TOLER,NPSUB,CONECT,TRAN,  
     1                MCON,RESTCT(7,7),ISORT,ORIGIN(7,3),IPRINT,TOCOPN  
      COMMON /CMB004/ TDAT(6),NIPNEW,CNAM(2),LONLY        
CZZ   COMMON /ZZCOMB/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      COMMON /BLANK / STEP,DRY,PORA        
      EQUIVALENCE     (RZ(1),Z(1)),(ITRAN,ECPT(1))        
      DATA    AAA   / 4HCMSO,4HFO   / , EOG / 4H$EOG /        
      DATA    PAPP  , LODS,LOAP             /        
     1                4HPAPP,4HLODS,4HLOAP  /        
      DATA    NHEQSS, NHBGSS,NHCSTM,NHPLTS  /        
     1        4HEQSS, 4HBGSS,4HCSTM,4HPLTS  /        
C        
C     GET NAMES OF BASIC COMPONENTS FROM THE TABLE OF CONTENTS        
C        
      IFILE = SCTOC        
      IF (.NOT.TOCOPN) CALL OPEN (*720,SCTOC,Z(BUF2),0)        
      CALL REWIND (SCTOC)        
      K = 0        
      J = 0        
   10 J = J + 1        
C        
      CALL READ (*30,*730,SCTOC,0,-3,0,NNN)        
      CALL READ (*30,*20,SCTOC,Z(SCORE+K),LCORE,1,NNN)        
   20 K = K + NNN        
      IF (J .LT. NPSUB) GO TO 10        
   30 IF (.NOT.TOCOPN) CALL CLOSE (SCTOC,1)        
      ISTNM = SCORE        
      SCORE = SCORE + K        
      NNAMES = K        
C        
      NSUB = 0        
      DO 40 J = 1,NPSUB        
      NSUB = NSUB + COMBO(J,5)        
   40 CONTINUE        
C        
C     WRITE THE FIRST GROUP OF THE EQSS        
C        
      IF (LONLY) GO TO 330        
C        
      NP2 = 2*NPSUB        
      DO 50 I = 1,NP2,2        
      J = I/2 + 1        
      NAMOLD(I  ) = COMBO(J,1)        
      NAMOLD(I+1) = COMBO(J,2)        
   50 CONTINUE        
      NPP = NPSUB        
      CALL SETLVL (CNAM,NPP,NAMOLD,ITEST,29)        
      IF (ITEST .EQ. 8) GO TO 700        
      ITEST = 3        
      CALL SFETCH (CNAM,NHEQSS,2,ITEST)        
      ITEST = 1        
      CALL SUWRT (CNAM,2,ITEST)        
      CALL SUWRT (NSUB,1,ITEST)        
      CALL SUWRT (NIPNEW,1,ITEST)        
      ITEST = 2        
      CALL SUWRT (Z(ISTNM),NNAMES,ITEST)        
C        
      IFILE = SCCONN        
      CALL OPEN (*720,SCCONN,Z(BUF1),0)        
      IFILE = SCSFIL        
      CALL OPEN (*720,SCSFIL,Z(BUF2),0)        
      IFILE = SCR1        
      CALL OPEN (*720,SCR1,Z(BUF3),1)        
      DO 180 I = 1,NPSUB        
      IPN = 0        
      KK  = 0        
   60 IPN = IPN + 1        
      CALL READ (*80,*70,SCCONN,CE,10,1,NNN)        
   70 IF (CE(I+2) .EQ. 0) GO TO 60        
      Z(SCORE+KK  ) = CE(  1)        
      Z(SCORE+KK+1) = CE(I+2)        
      Z(SCORE+KK+2) = IPN        
      KK = KK + 3        
      GO TO 60        
   80 NOIPN = (KK)/3        
      CALL SORT (0,0,3,2,Z(SCORE),KK)        
C        
C     READ BGSS FROM SUBFIL        
C        
      IFILE = SCSFIL        
      NPSP1 = COMBO(I,5) + 1        
      DO 90 J = 1,NPSP1        
      CALL FWDREC (*730,SCSFIL)        
   90 CONTINUE        
      SBGSS = SCORE + KK        
      LCORE = LCORE - KK        
      CALL READ (*730,*100,SCSFIL,Z(SBGSS),LCORE,1,LBGSS)        
      GO TO 740        
  100 CONTINUE        
      DO 110 J = 1,KK,3        
      JJ     = J - 1        
      GETIP  = Z(SCORE+JJ+1)        
      ENT(1) = Z(SBGSS+4*GETIP-4  )        
      ENT(2) = Z(SBGSS+4*GETIP-4+1)        
      ENT(3) = Z(SBGSS+4*GETIP-4+2)        
      ENT(4) = Z(SBGSS+4*GETIP-4+3)        
      ENT(5) = Z(SCORE+JJ+2)        
      CALL WRITE (SCR1,ENT,5,0)        
  110 CONTINUE        
      CALL WRITE (SCR1,ENT,0,1)        
      IF (I .EQ. 1) CALL REWIND (SCSFIL)        
      IF (I .NE. 1) CALL SKPFIL (SCSFIL,-1)        
      IF (I .NE. 1) CALL SKPFIL (SCSFIL, 1)        
      NCOMP = COMBO(I,5)        
      DO 170 J = 1,NCOMP        
      CALL READ (*720,*120,SCSFIL,Z(SBGSS),LCORE,1,NNN)        
      GO TO 740        
  120 IF (NNN .EQ. 0) GO TO  160        
      DO 150 JJ = 1,NNN,3        
      KID = Z(SBGSS+JJ)        
      CALL BISLOC (*150,KID,Z(SCORE+1),3,NOIPN,NWD)        
  130 IF (Z(SCORE+NWD) .NE. Z(SCORE+NWD-3)) GO TO 140        
      IF (NWD .LE. 1) GO TO 140        
      NWD = NWD - 3        
      GO TO 130        
  140 ENT(1) = Z(SBGSS+JJ -1)        
      ENT(2) = Z(SCORE+NWD+1)        
      ENT(3) = Z(SCORE+NWD-1)        
      CALL WRITE (SCR1,ENT,3,0)        
      IF (Z(SCORE+NWD) .NE. Z(SCORE+NWD+3)) GO TO 150        
      IF (NWD+3 .GE. NOIPN*3) GO TO 150        
      NWD = NWD + 3        
      GO TO 140        
  150 CONTINUE        
  160 CALL WRITE (SCR1,0,0,1)        
  170 CONTINUE        
      CALL SKPFIL (SCSFIL,1)        
      CALL REWIND (SCCONN)        
  180 CONTINUE        
      CALL CLOSE (SCSFIL,1)        
      CALL CLOSE (SCR1,1)        
C        
C     WRITE OUT EQSS ONTO SOF        
C        
      IFILE = SCR1        
      CALL OPEN (*720,SCR1,Z(BUF3),0)        
      DO 210 I = 1,NPSUB        
      NCOMP = COMBO(I,5)        
      CALL FWDREC (*730,SCR1)        
      DO 200 J = 1,NCOMP        
      CALL READ (*730,*190,SCR1,Z(SBGSS),LCORE,1,NNN)        
      GO TO 740        
  190 ITEST = 2        
      CALL SUWRT (Z(SBGSS),NNN,ITEST)        
  200 CONTINUE        
  210 CONTINUE        
C        
C     WRITE OUT MASTER SIL,C LIST FOR NEW STRUCTURE        
C        
      CALL REWIND (SCCONN)        
      KK   = 0        
      ISIL = 1        
  220 CALL READ (*240,*230,SCCONN,CE,10,1,NNN)        
  230 CALL DECODE (CE(1),Z(BUF2),NDOF)        
      Z(SBGSS+KK  ) = ISIL        
      Z(SBGSS+KK+1) = CE(1)        
      ISIL = ISIL + NDOF        
      KK   = KK + 2        
      GO TO 220        
  240 CONTINUE        
      ITEST = 2        
      CALL SUWRT (Z(SBGSS),KK,ITEST)        
      ITEST = 3        
      CALL SUWRT (ENT,0,ITEST)        
C        
C     WRITE BGSS ONTO SOF        
C        
      LCC = LCORE        
      KK  = 0        
      CALL REWIND (SCR1)        
      DO 270 I = 1,NPSUB        
      NCOMP = COMBO(I,5)        
      CALL READ (*730,*250,SCR1,Z(SBGSS+KK),LCC,1,NW)        
      GO TO 740        
  250 KK  = KK  + NW        
      LCC = LCC - NW        
      DO 260 J = 1,NCOMP        
      CALL FWDREC (*280,SCR1)        
  260 CONTINUE        
  270 CONTINUE        
  280 CALL SORT (0,0,5,5,Z(SBGSS),KK)        
      ITEST = 3        
      CALL SFETCH (CNAM,NHBGSS,2,ITEST)        
      ITEST = 1        
      CALL SUWRT (CNAM,2,ITEST)        
      ITEST = 2        
      CALL SUWRT (NIPNEW,1,ITEST)        
      KKK  = 0        
  290 ISUB = SBGSS + KKK        
      ENT(1) = Z(ISUB  )        
      ENT(2) = Z(ISUB+1)        
      ENT(3) = Z(ISUB+2)        
      ENT(4) = Z(ISUB+3)        
      IF (KKK.GT.0 .AND. Z(ISUB+4).EQ.Z(ISUB-1)) GO TO 300        
      ITEST = 1        
      CALL SUWRT (ENT,4,ITEST)        
  300 KKK = KKK + 5        
      IF (KKK .LT. KK) GO TO 290        
      ITEST = 2        
      CALL SUWRT (ENT,0,ITEST)        
      ITEST = 3        
      CALL SUWRT (ENT,0,ITEST)        
      CALL CLOSE (SCR1,1)        
      CALL CLOSE (SCCONN,1)        
C        
C     PROCESS CSTM ITEM        
C        
      CALL OPEN (*720,SCCSTM,Z(BUF3),0)        
      CALL READ (*310,*310,SCCSTM,Z(SCORE),LCORE,1,NNN)        
      GO TO 740        
  310 IF (NNN .EQ. 0) GO TO 320        
      ITEST = 3        
      CALL SFETCH (CNAM,NHCSTM,2,ITEST)        
      ITEST = 2        
      CALL SUWRT (CNAM,2,ITEST)        
      ITEST = 2        
      CALL SUWRT (Z(SCORE),NNN,ITEST)        
      ITEST = 3        
      CALL SUWRT (0,0,ITEST)        
  320 CALL CLOSE (SCCSTM,1)        
C        
C     PROCESS LODS ITEM        
C        
  330 NLV  = 0        
      NCS  = NNAMES/2        
      J    = 0        
      LITM = LODS        
      IF (PORA .EQ. PAPP) LITM = LOAP        
      DO 350 I = 1,NPSUB        
      NAMOLD(1) = COMBO(I,1)        
      NAMOLD(2) = COMBO(I,2)        
      CALL SFETCH (NAMOLD,LITM,1,ITEST)        
      IF (ITEST .EQ. 3) GO TO 340        
      CALL SUREAD (CE,4,NOUT,ITEST)        
      NLV = NLV + CE(3)        
      JDH = 1        
      CALL SJUMP (JDH)        
      CALL SUREAD (Z(SCORE+J),-2,NOUT,ITEST)        
      J = J + NOUT        
      GO TO 350        
  340 Z(SCORE+J  ) = 0        
      Z(SCORE+J+1) = EOG        
      J = J + 2        
  350 CONTINUE        
      ITEST = 3        
      CALL SFETCH (CNAM,LITM,2,ITEST)        
      ITEST = 1        
      CALL SUWRT (CNAM,2,ITEST)        
      CALL SUWRT (NLV ,1,ITEST)        
      CALL SUWRT (NCS ,1,ITEST)        
      ITEST = 2        
      CALL SUWRT (Z(ISTNM),NNAMES,ITEST)        
      ITEST = 3        
      CALL SUWRT (Z(SCORE),J,ITEST)        
      IF (LONLY) GO TO 580        
C        
C     PROCESS PLTS ITEM        
C        
C        
C     FIND OLD PLTS TRANSFORMATIONS        
C        
      NOUT  = 0        
      J     = 0        
      NNSUB = 0        
      DO 370 I = 1,NPSUB        
      NAMOLD(1) = COMBO(I,1)        
      NAMOLD(2) = COMBO(I,2)        
      CALL SFETCH (NAMOLD,NHPLTS,1,ITEST)        
      IF (ITEST .EQ. 3) GO TO 370        
      CALL SUREAD (Z(SCORE+J),3,NOUT,ITEST)        
      NNSUB = NNSUB + Z(SCORE+J+2)        
      CALL SUREAD (Z(SCORE+J),-1,NOUT,ITEST)        
      J = J + NOUT        
  370 CONTINUE        
      NPWD  = J        
      ISTRN = SCORE + NPWD        
      LLCO  = LCORE - NPWD        
      ITEST = 3        
      CALL SFETCH (CNAM,NHPLTS,2,ITEST)        
      ITEST = 1        
      CALL SUWRT (CNAM ,2,ITEST)        
      CALL SUWRT (NNSUB,1,ITEST)        
      NT = 0        
      IF (.NOT.TDAT(3)) GO TO 390        
      CALL OPEN (*720,SCBDAT,Z(BUF1),0)        
      CALL SKPFIL (SCBDAT,2)        
      CALL READ (*730,*380,SCBDAT,Z(ISTRN),LCORE,1,NT)        
      GO TO 740        
  380 CALL PRETRS (Z(ISTRN),NT)        
  390 IF (.NOT.TOCOPN) CALL OPEN (*720,SCTOC,Z(BUF2),1)        
      CALL REWIND (SCTOC)        
      IST  = ISTRN + NT        
      LLCO = LLCO  - NT        
      J = 0        
  400 J = J + 1        
      ITRAN = COMBO(J,3)        
      DO 410 I = 1,9        
      TMAT(I) = 0.0        
  410 CONTINUE        
      CALL READ (*530,*420,SCTOC,Z(IST),LLCO,1,NNN)        
      GO TO 740        
  420 IF (ITRAN .EQ. 0) GO TO 440        
      DO 430 I = 2,4        
      ECPT(I) = 0.0        
  430 CONTINUE        
      CALL TRANSS (ECPT,TMAT)        
      GO TO 450        
  440 TMAT(1) = 1.0        
      TMAT(5) = 1.0        
      TMAT(9) = 1.0        
C        
C     DETERMINE SYMMETRY        
C        
  450 IF (COMBO(J,4) .EQ. 0) GO TO 470        
      CALL DECODE (COMBO(J,4),LIST,NDIR)        
      DO 460 I = 1,NDIR        
      IDIR = LIST(I) + 1        
      IDIR = 4 - IDIR        
      TMAT(IDIR  ) = -TMAT(IDIR  )        
      TMAT(IDIR+3) = -TMAT(IDIR+3)        
      TMAT(IDIR+6) = -TMAT(IDIR+6)        
  460 CONTINUE        
  470 DO 480 I = 1,3        
      RENT(I) = ORIGIN(J,I)        
  480 CONTINUE        
      NNN = NNN - 1        
      DO 520 I = 3,NNN,2        
C        
C     PROCESS OLD TRANSFORMATIONS        
C        
      DO 490 KDH = 1,NPWD,14        
      IF (Z(IST+I).EQ.Z(SCORE+KDH-1) .AND. Z(IST+I+1).EQ.Z(SCORE+KDH))  
     1    GO TO 500        
  490 CONTINUE        
      GO TO 520        
  500 CALL GMMATS (TMAT,3,3,0, RZ(SCORE+KDH+1),3,1,0, SAV1)        
      DO 510  II = 1,3        
  510 SAV1(II) = SAV1(II)+RENT(II)        
      CALL GMMATS (TMAT,3,3,0, RZ(SCORE+KDH+4),3,3,0, SAV2)        
      ITEST = 1        
      CALL SUWRT (Z(IST+I),2,ITEST)        
      CALL SUWRT (SAV1(1) ,3,ITEST)        
      CALL SUWRT (SAV2(1) ,9,ITEST)        
      GO TO 520        
  520 CONTINUE        
      IF (J .LT. NPSUB) GO TO 400        
  530 IF (.NOT.TOCOPN) CALL CLOSE (SCTOC,1)        
      ITEST = 2        
      CALL SUWRT (0,0,ITEST)        
      ITEST = 3        
      CALL SUWRT (0,0,ITEST)        
      CALL CLOSE (SCBDAT,1)        
      CALL EQSOUT        
C        
C     PROCESS OUTPUT REQUESTS        
C        
      IF (ANDF(RSHIFT(IPRINT,12),1) .NE. 1) GO TO 550        
C        
C     WRITE EQSS FOR NEW STRUCTURE        
C        
      CALL SFETCH (CNAM,NHEQSS,1,ITEST)        
      CALL SUREAD (Z(SCORE),4,NOUT,ITEST)        
      CALL SUREAD (Z(SCORE),-1,NOUT,ITEST)        
      IST = SCORE + NOUT        
      DO 540 I = 1,NSUB        
      CALL SUREAD (Z(IST),-1,NOUT,ITEST)        
      IADD = SCORE + 2*(I-1)        
      CALL CMIWRT (1,CNAM,Z(IADD),IST,NOUT,Z,Z)        
  540 CONTINUE        
      CALL SUREAD (Z(IST),-1,NOUT,ITEST)        
      CALL CMIWRT (8,CNAM,0,IST,NOUT,Z,Z)        
  550 IF (ANDF(RSHIFT(IPRINT,13),1) .NE. 1) GO TO 560        
C        
C     WRITE BGSS FOR NEW STRUCTURE        
C        
      CALL SFETCH (CNAM,NHBGSS,1,ITEST)        
      NGRP = 1        
      CALL SJUMP (NGRP)        
      IST = SCORE        
      CALL SUREAD (Z(IST),-1,NOUT,ITEST)        
      CALL CMIWRT (2,CNAM,CNAM,IST,NOUT,Z,Z)        
  560 IF (ANDF(RSHIFT(IPRINT,14),1) .NE. 1) GO TO 570        
C        
C     WRITE CSTM ITEM        
C        
      CALL SFETCH (CNAM,NHCSTM,1,ITEST)        
      IF (ITEST .EQ. 3) GO TO 570        
      NGRP = 1        
      CALL SJUMP (NGRP)        
      IST = SCORE        
      CALL SUREAD (Z(IST),-1,NOUT,ITEST)        
      CALL CMIWRT (3,CNAM,CNAM,IST,NOUT,Z,Z)        
  570 IF (ANDF(RSHIFT(IPRINT,15),1) .NE. 1) GO TO 580        
C        
C     WRITE PLTS ITEM        
C        
      CALL SFETCH (CNAM,NHPLTS,1,ITEST)        
      IST = SCORE        
      CALL SUREAD (Z(IST), 3,NOUT,ITEST)        
      CALL SUREAD (Z(IST),-1,NOUT,ITEST)        
      CALL CMIWRT (4,CNAM,CNAM,IST,NOUT,Z,Z)        
  580 IF (ANDF(RSHIFT(IPRINT,16),1) .NE. 1) GO TO 600        
C        
C     WRITE LODS ITEM        
C        
      CALL SFETCH (CNAM,LODS,1,ITEST)        
      IF (ITEST .EQ. 3) GO TO 600        
      CALL SUREAD (Z(SCORE), 4,NOUT,ITEST)        
      CALL SUREAD (Z(SCORE),-1,NOUT,ITEST)        
      IST   = SCORE + NOUT        
      ITYPE = 5        
      IF (LITM .EQ. LOAP) ITYPE = 7        
      DO 590 I = 1,NSUB        
      IADD = SCORE + 2*(I-1)        
      CALL SUREAD (Z(IST),-1,NOUT,ITEST)        
      CALL CMIWRT (ITYPE,CNAM,Z(IADD),IST,NOUT,Z,Z)        
      ITYPE = 6        
  590 CONTINUE        
  600 CONTINUE        
      RETURN        
C        
  700 WRITE  (OUTT,710) UFM        
  710 FORMAT (A23,' 6518, ONE OF THE COMPONENT SUBSTRUCTURES HAS BEEN ',
     1       'USED IN A PREVIOUS COMBINE OR REDUCE.')        
      IMSG = -37        
      GO TO 750        
  720 IMSG = -1        
      GO TO 750        
  730 IMSG = -2        
      GO TO 750        
  740 IMSG = -8        
  750 CALL SOFCLS        
      CALL MESAGE (IMSG,IFILE,AAA)        
      RETURN        
      END        
