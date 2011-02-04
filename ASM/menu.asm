; Code ASM pour les menus
; Codé Par ManZ

.incsrc "asm2ips.asm" ; Codée par Meradrin

.startfile (LOW,YES)
.detect on

; definition de la table à utiliser
.asctable
	"A".."Z"	=	$42
	"a".."z"	=	$5c
	$20		=	$FF
	"."		= 	$C1
	"é"		=	$90
	"è"		=	$91
	"ê"		=	$92
.end

;TESTS:
;01881A: Curseur menu
;.patch ($01881A)
;	ADC.B #$00
;.endp (0)

;affichage du portrait
;.patch ($019358)
;LDA.W #$000F
;
;.endp (0)

;.patch ($0192F2)
;	LDA.B #$09
;.endp (0)

; affichage Curseur
;.patch ($018CF2)
;	LDA.W #$0003
;.endp (0)

;fin du test

; Décalage du "TIME"
;.patch ($0187A9)
;	STA.L $7E0002,X
;.endp (0)

;********************
;** Menu Principal **
;********************

; décalage du Temps
.patch ($018BC1)
	LDA.B #$80
	STA.W $0578,Y
	XBA
	STA.W $057A,Y
	REP #$20
	LDA.B $73
	SEP #$20
	JSR.W $81D6
	LDA.B $5B
	STA.W $0570,Y
	LDA.B $5D
	STA.W $0572,Y
	LDA.B $5E
	STA.W $0574,Y
	LDA.B #$C8
	STA.W $0576,Y
.endp (0)

; affichage du nombre de Gils
.patch ($018FAF)
	ADC.W #$0012
;	SBC.W #$002F
.endp (0)

; deplacement du nom du perso
.patch ($0183D5)
	STA.W $0040,Y
	XBA
	STA.W $0080,Y
.endp (0)

; déplacement du niveau (ex: 10)
.patch ($0189FA)
	STA.W $0018,X
	XBA
	STA.W $001A,X
.endp (0)

; NIVEAU
.patch ($0189C3)
	LDA.B #$4F	;N
	STA.W $000A,X

	LDA.B #$4A	;I
	STA.W $000C,X

	LDA.B #$57	;V
	STA.W $000E,X
	STA.W $0042,X

	LDA.B #$46	;E
	STA.W $0010,X

	LDA.B #$42	;A
	STA.W $0012,X

	LDA.B #$56	;U
	STA.W $0014,X

	LDA.B #$51	;P
	STA.W $0040,X
	STA.W $0080,X
	JSL.L deroutage

	NOP
	NOP
.endp (0)

.patch ($02FFC2)
	deroutage:
		LDA.B #$4E	;M
		STA.W $0082,X

		LDA.B #$C7	;/
		STA.W $004E,X
		STA.B $008E,X
		RTL
.endp (0)

; Patch des noms des personages
.patch ($0FA710)
	.asc "Cecil ","Cain  ","Rydia ","Tella ","Gibert","Rosa  ","Yang  "
	.asc "Palom ","Porom ","Cid   ","Edge  ","FuSoYa","Golbez","Anna  "
.endp (0)

; Modification pour alonger les noms des classes.
; Deplacement du nom des classe vers la gauche
.patch ($018C1A)
	ADC.W #$0000
.endp (0)

; alongement des noms de classe à 16 caractères.
.patch ($018FD3)
	ASL
	ASL
	ASL
	ASL
	NOP
	NOP
	STA.B $45
	STZ.B $46
	LDX.B $45
	LDA.B #$10
.endp (0)

;test de classes ;) "..."

.patch ($0FA764)
.asc "Chevalier Noir  "
.asc "Chevalier Dragon"
.endp (0)

; menu principal:

; deplacement du texte des menus:
.patch ($01892E)
	LDY.W #!menup
.endp (0)

; patch des fenètres
.patch ($01DB61)
	.db $00, $00, $1C , $1A
.endp (0)

.patch ($01DB65)
	.dw $04EE, $0507	;fenètre Gils
	.dw $04EE, $0507	;fenètre temps
	.dw $006E, $0F07	;fenètre menu principal
.endp (0)


; On déplace dans un peu de place "libre"
;.patch ($01FF36)
;	.dw $006E, $0F07 ;coordonées de la fenètre
;	.db $70, $00
;
;	.asc "Objets"
;	.db $01, $F0, $00
;	
;	.asc "Magie"
;	.db $01, $70, $01
;
;	.asc "Equiper"
;	.db $01, $F0, $01
;
;	.asc "Etat"
;	.db $01, $70, $02
;
;	.asc "Placer"
;	.db $01, $F0, $02
;
;	.asc "Changer"
;	.db $01, $70, $03
;
;	.asc "Config"
;	.db $01, $F0, $03
;
;	.asc "Sauver"
;	.db 0
;gils:
;	.asc "Gils"
;	.db 0
;cantuse:
;	.db $10, $02, $10, $03	; Coordonnées de la fenètre
;	.db $52, $02
;	.asc " Non utilisable"
;	.db 0
;time:
;	.asc "Temps"
;	.db 0
;.endp (0)


.patch ($0187CE)
	LDY.W #!gils
	LDX.W #$05B0
.endp (0)

.patch ($01AED6)
	LDY.W #!cantuse
.endp (0)

.patch ($0187C5)
	LDY.W #!time
	LDX #$0530
.endp (0)

.patch ($018301)

	PHB
	PHD
	PHX
	LDX.W #$0100
	PHX
	PLD
	PHK
	PLB
;mod
LDA.B #$02
STA $02
STZ $01
STZ $00
;/mod

wrampos:
	REP #$20
	LDA.B [$00],Y
	CLC
	ADC $29
	TAX
	SEP #$20
	INY
	INY

loop:
;LDA $0000,Y
	LDA.B [$00],Y
	BEQ fin
	INY
	CMP #$01
	BEQ wrampos
	JSL.L _8x16
	JSL.L _8x16disp
;JSR $8E32
;STA $7E0000,X
;XBA
;STA $7E0040,X
;INX
;INX
	BRA loop
fin:
	PLX
	PLD
	PLB
	RTS


.endp (0)





;********************
;**   Menu Objet   **
;********************

;Fenètre description
.patch ($01DCD6)
	.dw $0010, $0316
.endp (0)

.patch ($01A36F)
	LDY.W #!cant_use
.endp (0)

;Fenètre principale objet
.patch ($01DCCE)
	.dw $0000, $301E
.endp (0)

.patch ($019F56)
	LDY.W #!item_title
.endp (0)

.patch ($01DCFC)
item_title:
	.dw $0000, $0307
	.db $44, $00
	.asc "Objets"
	.db 0
cant_use:
	.dw $0052
	.asc "Impossible a Utiliser."
	.db 0

.endp (0)

;deroutage pour le calcul du pointeur des items
.patch ($019023)
	JSL.L ptr_items
	NOP
	NOP
	NOP
.endp (0)

;alongement des noms d'objets
.patch ($01903F)
	LDA.B #$0A
.endp (0)

; suppression du ":"
.patch ($01A208)
	NOP
	NOP

	NOP
	NOP
.endp (0)

;Menu Configuration
;.patch ($01D1A4)
;	LDY.W #$E169
;.endp (0)

;.patch ($01E15C)
;	.dw $E1B4, $20C2
;.endp (0)

;deroutage dans la routine des menus pour charger du texte pour les menus ailleurs :)


;.patch ($018318)
;	LDA.W $0001,Y
;.endp (0)

;modif pour pouvoir placer le texte des menus allieurs ^^
.patch ($20A000)

; routine de 8x16
_8x16:
	PHX
	REP #$20
	AND.W #$00FF
	ASL
	TAX
	LDA.L _8x16tbl,X
	SEP #$20
	PLX
	RTL

; modification de la 8x16 pour le menu
_8x16disp:	
	CMP #$00
	BEQ no_8x16
	STA.L $7E0000,X
	
	no_8X16:
		XBA
		STA.L $7E0040,X
	INX
	INX
	RTL

;pointeur Items:
ptr_items:
	LDA.B $43
	ASL
	PHA
	ADC.B $43
	STA.B $43
	PLA
	ASL
	ASL
	ADC.B $43
	RTL

menup:
	.dw $006E, $0F07 ;coordonées de la fenètre
	.db $70, $00

	.asc "Objets"
	.db $01, $F0, $00
	
	.asc "Magie"
	.db $01, $70, $01

	.asc "Equiper"
	.db $01, $F0, $01

	.asc "Etat"
	.db $01, $70, $02

	.asc "Placer"
	.db $01, $F0, $02

	.asc "Changer"
	.db $01, $70, $03

	.asc "Config"
	.db $01, $F0, $03

	.asc "Sauver"
	.db 0
gils:
	.asc "Gils"
	.db 0
cantuse:
	.db $10, $02, $10, $03	; Coordonnées de la fenètre
	.db $52, $02
	.asc " Non utilisable"
	.db 0
time:
	.asc "Temps"
	.db 0


_8x16tbl:
;00= on affiche rien au dessus de la lettre :)
;ex: $4200 affiche un A majuscule sans rien au dessus
;	    0     1     2     3     4     5     6     7     8     9     A     B     C     D     E     F
	.dw $ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff	;$0
	.dw $ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff	;$1
	.dw $ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff	;$2
	.dw $ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff	;$3
	.dw $ff00,$ff00,$4200,$4300,$4400,$4500,$4600,$4700,$4800,$4900,$4A00,$4B00,$4C00,$4D00,$4E00,$4F00	;$4
	.dw $5000,$5100,$5200,$5300,$5400,$5500,$5600,$5700,$5800,$5900,$5A00,$5B00,$5C00,$5D00,$5E00,$5F00	;$5
	.dw $6000,$6100,$6200,$6300,$6400,$6500,$6600,$6700,$6800,$6900,$6A00,$6B00,$6C00,$6D00,$6E00,$6F00	;$6
	.dw $7000,$7100,$7200,$7300,$7400,$7500,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff	;$7
	.dw $ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff	;$8
	.dw $608C,$608D,$608E,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff	;$9
	.dw $ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff	;$A
	.dw $ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff	;$B
	.dw $ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff	;$C
	.dw $ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff	;$D
	.dw $ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff	;$E
	.dw $ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ff00	;$F


.endp (0)

.endfile (0)