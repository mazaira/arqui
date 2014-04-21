*------------Autor-------------*
*Alberto Martin Mazaira s100231*



	ORG $0
	DC.L $7000 *Stack pointer
	DC.L    PPAL1




*Reserva de memoria
	ORG $400

BuffSA: DS.B 2000
EndSA: DS.B 4
PuntSA: DS.B 4
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
	ADD.L #5,A1
	MOVE.L A1,EndSA
	
	LEA BuffPA,A1
	MOVE.L A1,PuntPA
	MOVE.L #2000,A2
	ADD.L A2,A1
	MOVE.L A1,EndPA
	
	LEA BuffSB,A1
	MOVE.L A1,PuntSB
	MOVE.L #2000,A2
	ADD.L A2,A1
	MOVE.L A1,EndSB

	LEA BuffPB,A1
	MOVE.L A1,PuntPB
	MOVE.L #2000,A2
	ADD.L A2,A1
	MOVE.L A1,EndPB

	RTS

*****************

****LEECAR*******

LEECAR:
	LINK A6,#0
	MOVE.L D0,A0
	CMP.W #0,A0					*Switch 
	BEQ LEECARSA
	CMP.W #1,A0
	BEQ LEECARSB
	CMP.W #2,A0
	BEQ LEECARPA 
	CMP.W #3,A0
	BEQ LEECARPB
	MOVE.L #$FFFFFFFF,D0
	BRA FIN 

LEECARSA:
	MOVE.L PuntSA,A1
	MOVE.L BuffSA,A2
	CMP.L A1,A2
	BEQ EMPTY
	MOVE.L (A1)+,D0
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
	CMP.W #0,D0					*Switch 
	BEQ ESCCARSA
	CMP.W #1,D0
	BEQ ESCCARSB
	CMP.W #2,D0
	BEQ ESCCARPA 
	CMP.W #3,D0
	BEQ ESCCARPB
	MOVE.L #$FFFFFFFF,D0
	BRA FIN 

ESCCARSA:
	MOVE.W #$2700,SR
	BSET #0,IMRCopia
	MOVE.B IMRCopia,$effc0B
	MOVE.W #$2000,SR
	MOVE.L PuntSA,A2
	MOVE.L EndSA,A3
	CMP.L A2,A3
	BEQ FULL
	MOVE.B D1,(A2)+
	BRA FIN

ESCCARSB:
	MOVE.w #$2700,SR
	MOVE.B IMRCopia,$effc0B
	BSET #4,$effc0B
	MOVE.W #$2000,SR
	MOVE.L PuntSB,A2
	MOVE.L EndSB,A3
	CMP.L A2,A3
	BEQ FULL
	MOVE.B D1,(A2)+
	BRA FIN

ESCCARPA:
	MOVE.w #$2700,SR
	MOVE.B IMRCopia,$effc0B
	BSET #0,$effc0B
	MOVE.W #$2000,SR
	MOVE.L PuntPA,A2
	MOVE.L EndPA,A3
	CMP.L A2,A3
	BEQ FULL
	MOVE.L D1,(A2)+
	BRA FIN

ESCCARPB:
	MOVE.w #$2700,SR
	MOVE.B IMRCopia,$effc0B
	BSET #4,$effc0B
	MOVE.W #$2000,SR
	MOVE.L PuntPB,A2
	MOVE.L EndPB,A3
	CMP.L A2,A3
	BEQ FULL
	MOVE.L D1,(A2)+
	BRA FIN
FULL:
	MOVE.L #$FFFFFFFF,D0
	BRA FIN

**** FIN ESCCAR*******

****SCAN*******

SCAN:
	LINK A6,#0
	MOVE.L 8(A6),A1 *dir buffer
	MOVE.W 12(A6),A2 *descriptor
	MOVE.W 14(A6),A3 *tamaño
	MOVE.L A2,D0
BUCLE_SCAN:
	CMP.W #0,A3
	BEQ FIN
	BRA LEECAR
	SUB.W #1,A3
	BRA BUCLE_SCAN

**** FIN SCAN *******


****PRINT*******

PRINT:
	LINK A6,#0
	MOVE.L 8(A6),A1 *dir buffer
	MOVE.W 12(A6),A2 *descriptor
	MOVE.W 14(A6),A3 *tamaño
	MOVE.W A2,D0
BUCLE_PRINT:
	CMP.W #0,A3
	BEQ FIN
	MOVE.L (A1)+,D1
	BRA ESCCAR
	SUB.W #1,A3
	BRA BUCLE_PRINT


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
	MOVE.L A4,-(A7)
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
	MOVE.L (A7)+,A4
	MOVE.L (A7)+,A3
	MOVE.L (A7)+,A2
	MOVE.L (A7)+,A1
	MOVE.L (A7)+,A0
	MOVE.L (A7)+,D1
	MOVE.L (A7)+,D0
	RTE





		*** Prueba básica:
BUFFER1:
        DS.B		2000

PARDIR1:
        DC.L		0

PPAL1:
		BSR 		INIT 
		MOVE.W		#$2000,SR
		MOVE.L		#BUFFER1,PARDIR1
		MOVE.W 		#18,-(A7) 
		MOVE.W 		#1,-(A7) 
		MOVE.L		PARDIR1,-(A7) 
		BSR 		SCAN
		ADD.L 		#8,A7 			* Restablece la pila
		ADD.L       D0,PARDIR1 
		MOVE.W 		#18,-(A7) 
		MOVE.W 		#1,-(A7) 
		MOVE.L		PARDIR1,-(A7)
		BSR 		SCAN
		ADD.L 		#8,A7 			* Restablece la pila
		MOVE.L		#BUFFER1,PARDIR1
		MOVE.W 		#8,-(A7) 
		MOVE.W 		#0,-(A7) 
		MOVE.L		PARDIR1,-(A7)
		BSR 		PRINT
		BREAK



BUFFER: 
		DS.B 2100 					* Buffer para lectura y escritura de caracteres
CONTL: 
		DC.W 0 						* Contador de lŽineas
CONTC: 
		DC.W 0 						* Contador de caracteres
DIRLEC: 
		DC.L 0 						* DirecciŽon de lectura para SCAN
DIRESC: 
		DC.L 0 						* DirecciŽon de escritura para PRINT
TAME: 
		DC.W 0 						* Tama~no de escritura para print
DESA: 	EQU 0 						* Descriptor lŽinea A
DESB: 	EQU 1 						* Descriptor lŽinea B
NLIN: 	EQU 2 						* NŽumero de lŽineas a leer
TAML: 	EQU 10 						* Tama~no de lŽinea para SCAN
TAMB: 	EQU 10 						* Tama~no de bloque para PRINT
