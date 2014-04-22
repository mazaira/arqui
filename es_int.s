*------------Autor-------------*
*Alberto Martin Mazaira s100231*



	ORG $0
	DC.L $8000 *Stack pointer
	DC.L    PPAL1




*Reserva de memoria
	ORG $400

BuffSA1: DS.B 2000
EndSA: DS.B 4
PuntSA1: DS.B 4
RecARTI: DS.B 4

BuffPA: DS.B 2000
EndPA: DS.B 4
PuntPA: DS.B 4
TrARTI: DS.B 4

BuffSB: DS.B 2000
EndSB: DS.B 4
PuntSB: DS.B 4
RecBRTI: DS.B 4


BuffPB: DS.B 2000
EndPB: DS.B 4
PuntPB: DS.B 4
TrBRTI: DS.B 4
IMRCopia: DS.B 2






****INIT****

INIT:
	MOVE.B #%00000011,$effc01 	*8bits por caracter en A y Receiver Ready MRA
	MOVE.B #%00000011,$effc11 	*8bits por caracter en B y Receiver Ready MRB
	MOVE.B #%00000000,$effc01 	*Eco desactivado en A
	MOVE.B #%00000000,$effc11 	*Eco desactivado en B
	MOVE.B #%11001100,$effc03 	*Vrecep=Vtrans=38400 bps en A
	MOVE.B #%11001100,$effc15 	*Vrecep=Vtrans=38400 bps en B
	MOVE.B #%00000101,$effc05 	*Full Duplex A
	MOVE.B #%00000101,$effc15 	*Full Duplex B
	MOVE.B #$40,$effc19 		*Vector de interrupción 40
	MOVE.B #%00100010,$effc0B 	*Habilitar las interrupciones en la mascara
	MOVE.B #%00100010,IMRCopia

	LEA RTI,A1
	MOVE.L #$100,A2
	MOVE.L A1,(A2)
	
	LEA BuffSA,A1
	MOVE.L A1,PuntSA
	MOVE.B PuntSA+2000,EndSA
	
	
	LEA BuffPA,A1
	MOVE.L A1,PuntPA
	MOVE.B PuntPA+2000,EndPA
	
	
	LEA BuffSB,A1
	MOVE.L A1,PuntSB
	MOVE.L #$2000,A2
	ADD.L A2,A1
	MOVE.L A1,EndSB

	LEA BuffPB,A1
	MOVE.L A1,PuntPB
	MOVE.L #$2000,A2
	ADD.L A2,A1
	MOVE.L A1,EndPB

	RTS

*****************

****LEECAR*******

LEECAR:
	LINK A6,#0
	MOVE.L D0,A3
	CMP.W #0,A3				*Switch 
	BEQ LEECARSA
	CMP.W #1,A3
	BEQ LEECARSB
	CMP.W #2,A3
	BEQ LEECARPA 
	CMP.W #3,A3
	BEQ LEECARPB
	MOVE.L #$FFFFFFFF,D0
	BRA FIN 

LEECARSA:
	MOVE.L PuntSA,A1
	MOVE.L BuffSA,A2
	CMP.W A1,A2
	BEQ EMPTY
	MOVE.B (A1)+,D0
	MOVE.L A1,PuntSA
	BRA FIN

LEECARSB:
	MOVE.L PuntSB,A1
	MOVE.L BuffSB,A2
	CMP.L A1,A2
	BEQ EMPTY
	MOVE.L (A1)+,D0
	MOVE.L A1,PuntSB
	BRA FIN

LEECARPA:
	MOVE.L PuntPA,A1
	MOVE.L BuffPA,A2
	CMP.L A1,A2
	BEQ EMPTY
	MOVE.L (A1)+,D0
	MOVE.L A1,PuntPA
	BRA FIN

LEECARPB:
	MOVE.L PuntPB,A1
	MOVE.L BuffPB,A2
	CMP.L A1,A2
	BEQ EMPTY
	MOVE.L (A1)+,D0
	MOVE.L A1,PuntPB
	BRA FIN
EMPTY:
	MOVE.L #$FFFFFFFF,D0
	BRA FIN




**** FIN LEECAR*******

*****  ESCCAR   *******

ESCCAR:
	LINK A6,#0
	MOVE.L D0,A1
	CMP.W #0,A1				*Switch 
	BEQ ESCCARSA
	CMP.W #1,A1
	BEQ ESCCARSB
	CMP.W #2,A1
	BEQ ESCCARPA 
	CMP.W #3,A1
	BEQ ESCCARPB
	MOVE.L #$FFFFFFFF,D0
	BRA FIN 

ESCCARSA:
	*MOVE.W #$2700,SR
	*BSET #0,IMRCopia
	*MOVE.B IMRCopia,$effc0B
	*MOVE.W #$2000,SR
	MOVE.W PuntSA,A2
	MOVE.L EndSA,A3
	CMP.W A2,A3
	BEQ FULL
	ADD.W #1,A2
	MOVE.B D1,D2
	MOVE.B D2,(A2)+
	CLR.W D0
	BRA FIN

ESCCARSB:
	*MOVE.w #$2700,SR
	*MOVE.B IMRCopia,$effc0B
	*BSET #4,$effc0B
	*MOVE.W #$2000,SR
	MOVE.W PuntSB,A2
	MOVE.L EndSB,A3
	CMP.L A2,A3
	BEQ FULL
	ADD.w #1,A2
	MOVE.B D1,D2
	MOVE.B D2,(A2)+
	CLR.W D0
	BRA FIN

ESCCARPA:
	*MOVE.w #$2700,SR
	*MOVE.B IMRCopia,$effc0B
	*BSET #0,$effc0B
	*MOVE.W #$2000,SR
	MOVE.L PuntPA,A2
	MOVE.L EndPA,A3
	CMP.L A2,A3
	BEQ FULL
	ADD.W #1,A2
	MOVE.B D1,D2
	MOVE.B D2,(A2)+
	CLR.W D0
	BRA FIN

ESCCARPB:
	*MOVE.w #$2700,SR
	*MOVE.B IMRCopia,$effc0B
	*BSET #4,$effc0B
	*MOVE.W #$2000,SR
	MOVE.L PuntPB,A2
	MOVE.L EndPB,A3
	CMP.L A2,A3
	BEQ FULL
	ADD.w #1,A2
	MOVE.B D1,D2
	MOVE.B D2,(A2)+
	CLR.W D0
	BRA FIN
FULL:
	MOVE.L #$FFFFFFFF,D0
	BRA FIN

**** FIN ESCCAR*******

****SCAN*******
CONTS	DS.W 	1
SCAN:
	LINK A6,#0
	MOVE.L 8(A6),A1 *dir buffer
	MOVE.W 12(A6),A2 *descriptor
	MOVE.W 14(A6),A3 *tamaño
	MOVE.L A2,D0
	

BUCLE_SCAN:
	CMP.W #0,A3
	BEQ FIN
	BSR LEECAR
	CMP.W #$FFFFFFFF,D0
	BEQ FIN_SCAN
	SUB.W #1,A3
	ADD.W #$1,CONTS
	CMP.W #0,A3
	BEQ FIN_SCAN
	BSR BUCLE_SCAN
FIN_SCAN:
	MOVE.L CONTS,D0
	BRA FIN


**** FIN SCAN *******


****PRINT*******
CONTP	DS.W 	1

PRINT:
	LINK A6,#0
	MOVE.L 8(A6),A1 *dir buffer
	MOVE.W 12(A6),A2 *descriptor
	MOVE.W 14(A6),A3 *tamaño
	MOVE.W A2,D0
BUCLE_PRINT:
	CMP.W #0,A3
	BEQ FIN
	MOVE.L A2,D1
	BSR ESCCAR
	CMP.W #$FFFFFFFF,D0
	BEQ FIN_PRINT
	SUB.W #1,A3
	ADD.W #$1,CONTP
	CMP.W #0,A3
	BEQ FIN_PRINT
	BSR BUCLE_PRINT
FIN_PRINT:
	MOVE.L CONTP,D0
	BRA FIN


**** FIN PRINT*******

*****FIN*****

FIN:
	UNLK A6
	RTS
*** FIN FIN ******


**** RTI *******

RTI:
	MOVE.L D0,-(A7)
	MOVE.L D1,-(A7)
	MOVE.L A0,-(A7)
	MOVE.L A1,-(A7)
	MOVE.L A2,-(A7)
	MOVE.L A3,-(A7)
	MOVE.B IMRCopia,D1

	BTST #0,D1
	BNE TrA
	BTST #1,D1
	BNE RecA
	BTST #4,D1
	BNE TrB
	BTST #5,D1
	BNE RecB
	BRA FIN_RTI
TrA:
	BRA LEECAR
	MOVE.L D0,$eff07
	MOVE.W #$2700,SR		
	BCLR #0,IMRCopia		
	MOVE.B IMRCopia,$effc0B	
	MOVE.W #$2000,SR		
	BRA FIN_RTI		

TrB:
	BRA LEECAR
	MOVE.L D0,$eff17
	MOVE.W #$2700,SR		
	BCLR #0,IMRCopia		
	MOVE.B IMRCopia,$effc0B	
	MOVE.W #$2000,SR		
	BRA FIN_RTI	
RecA:
	MOVE.L $eff07,D1
	MOVE.L #1,D0
	BRA ESCCAR
	BRA FIN_RTI	
RecB:
	MOVE.L $eff17,D1
	MOVE.L #2,D0
	BRA ESCCAR
	BRA FIN_RTI	
	
	
FIN_RTI:
	MOVE.L (A7)+,A3
	MOVE.L (A7)+,A2
	MOVE.L (A7)+,A1
	MOVE.L (A7)+,A0
	MOVE.L (A7)+,D1
	MOVE.L (A7)+,D0
	RTE





		*** Prueba básica:



**************************** PROGRAMA PRINCIPAL **************************************
	ORG $4000

* Bufferes para PRINT 
*BUFFER	DC.B	$61,$62,$d,$63,$64,$d,$65,$66,$31,$32,$d,$33,$34,$d,$35,$36
*BUFFER	DC.B	$61,$d
BuffSA	DC.B	$d,$a,$31,$32,$33,$d,$a,$34,$35,$36
    DC.B	$31,$32,$33,$34,$35,$36,$37,$38,$39,$30
    DC.B	$31,$32,$33,$34,$35,$36,$37,$38,$39,$30
    DC.B	$31,$32,$33,$34,$35,$36,$37,$38,$39,$30
    DC.B	$31,$32,$33,$34,$35,$36,$37,$38,$39,$30
    DC.B	$31,$32,$33,$34,$35,$36,$37,$38,$39,$30
    DC.B	$31,$32,$33,$34,$35,$36,$37,$38,$39,$30
    DC.B	$31,$32,$33,$34,$35,$36,$37,$38,$39,$30
    DC.B	$31,$32,$33,$34,$35,$36,$37,$38,$39,$30
    DC.B	$31,$32,$33,$34,$35,$36,$37,$38,$39,$30
    DC.B	$31,$32,$33,$34,$35,$36,$37,$38,$39,$30
    DC.B    $31,$d,$31,$d

PuntSA: DC.L 0




*** PRUEBA SCAN
    MOVE.W #10,-(A7) * tamano
    MOVE.W #0,-(A7) * descriptor
    MOVE.L #$4500,-(A7)
    BSR SCAN
*** FIN PRUEBA SCAN

	BREAK

**************************** FIN PROGRAMA PRINCIPAL **********************************

PPAL1:
	MOVE.L #$8000,A7 * dir de pila
	BSR INIT
	MOVE.W #4,-(A7) * tamano
    MOVE.W #1,-(A7) * descriptor
    MOVE.L #$4000,-(A7)
	BSR PRINT

	

	BREAK




*$BSVC/68kasm -la es_int.s