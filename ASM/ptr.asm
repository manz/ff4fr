;************************************
;** Fonctions de calcul (pointers) **
;************************************
 PointeurBank1de1
 	REP #$20
 	LDA.L $218000,X
 	STA.B $3D
 	LDA.W #$0000
 	SEP #$20
 	LDA.L $218002,X
 	STA.B $3F
 	LDA.B #$01
 	RTL
 PointeurBank1de2
 	REP #$20
 	LDA.L $218300,X
 	STA.B $3D
 	LDA.W #$0000
 	SEP #$20
 	LDA.L $218302,X
 	STA.B $3F
 	LDA #$01
 	RTL
 PointeurBank3
 	REP #$20
 	LDA.L $218600,X
 	STA.B $3D
 	LDA.W #$0000
 	SEP #$20
 	LDA.L $218602,X
 	STA.B $3F
 	LDA #$02
 	RTL
 CalculePositionTb
 	LDA.B $B2
 	STA.B $3D
 	STZ.B $3E
 	REP #$20
 	LDA.B $3D
 	CLC
 	ASL
 	ADC.B $3D
 	TAX
 	SEP #$20
 	RTL
 PointeurBank2
 	REP #$20
 	LDA.B $3D
 	ASL
 	CLC
 	ADC.B $3D
 	TAX	
 	LDA.L $218800,X
 	STA.B $3D
 	LDA.W #$0000
 	SEP #$20
 	LDA.L $218802,X
 	STA.B $3F
 	LDX.B $3D
 	LDA.B $B2
 	BEQ _FinBk2
 	TAY
 _LoopBk2
 	JSR.W ChargeLettreIncBk2
 	BNE _LoopBk2
 	JSR.W ChargeLettreDecBk2
 	PHA
 	JSR.W ChargeLettreIncBk2
 	PLA
 	CMP #$03
 	BEQ _LoopBk2
 	PHA
 	PLA
 	CMP #$04
 	BEQ _LoopBk2
 	DEY
 	BNE _LoopBk2
 	INX
 _FinBk2
 	STX.W $0772
 	STZ.B $DD
 	RTL
 ChargeLettreDecBk2
 	LDX.B $3D
 	DEX
 	BMI _OkBk2
 	DEC.B $3F
 	LDX.W #$FFFF
 	BRA _OkBk2
 ChargeLettreIncBk2
 	LDX.B $3D
 	INX
 	BMI _OkBk2
 	INC.B $3F
 	LDX.W #$8000
 _OkBk2
 	STX.B $3D
 ChargeLettreBk2
 	LDX.B $3D
 	PHB
 	LDA.B $3F
 	PHA
 	PLB
	LDA.W $0000,X
	PLB
 	PHA
 	PLA
	RTS

incpointer:
	PHX
	LDX.W $0772
	INX
	BNE _ok
	INC.B $3F
	LDX.W #$8000
	_ok:
	STX.W $0772
	PLX
RTS

 ;=====================================================================
 ; Fonction de lecture de caractère
 ;=====================================================================
 .mem 8
 .index 16
 ChargeLettreInc
 	LDX.W $0772
 	INX
 	CPX.W #$0000
 	BNE _AucunDepassement
	INC.B $3F
 	LDX.W #$8000
 _AucunDepassement
 	STX.W $0772
 ChargeLettre
	LDX.W $0772
 	PHB
 	LDA.B $3F
 	PHA
 	PLB
	LDA.W $0000,X
	STA.B CURRENT_C
	PLB
 	PHA
 	PLA

 	RTS
 

