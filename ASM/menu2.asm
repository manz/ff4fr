;=========================================
; -Final Fantasy IV-
; Reprogrammation ASM
; modifié: 23:23 18/02/2004
;=========================================
.incsrc "asm2ips.asm" ; Codée par Meradrin
.memmapset (LOW,YES)
.detect on

; definition de la table à utiliser
.asctable
	"A".."Z"	=	$42
	"a".."z"	=	$5c
	$20		=	$FF
	"è"		=	$90
	"ê"		=	$91
	"é"		=	$92
	"ë"		=	$93
	"à"		=	$94
	"ô"		=	$96
	"ù"		=	$97
	"û"		=	$98
	$2E		= 	$C1
	"%"		=	$C6
.end
; Petite fenètre "Impossible ..." : $01A7DE
.patch ($01A80D)
NOP
NOP
NOP
.endp (0)

; Patch des noms des personages
.patch ($0FA710)
	.asc "Cecil ","Cain  ","Rydia ","Tella ","Gibert","Rosa  ","Yang  "
	.asc "Palom ","Porom ","Cid   ","Edge  ","FuSoYa","Golbez","Anna  "
.endp (0)

.patch ($0FA764)
.asc "Chevalier Noir  "
.asc "Cheva"
;li
.db $9E
.asc "er Dragon "
.asc "Invocatrice     "
.endp (0)


; NIVEAU
.patch ($0189C3)
	LDA.B #$9A
	STA.W $000A,X

	LDA.B #$9B
	STA.W $000C,X

	LDA.B #$9C
	STA.W $000E,X
	
	LDA.B #$9D
	STA.W $0010,X
	
	LDA.B #$70
	STA.W $0012,X

	LDA.B #$51
	STA.W $0040,X
	STA.W $0080,X
	JSL.L deroutage

	NOP
	NOP
.endp (0)

;deroutage du grisement de "sauver"
.patch ($018939)
	JSR.L derout_save
	NOP

	NOP
	NOP
	NOP

	NOP
	NOP
	NOP

	NOP
	NOP
	NOP

.endp (0)

;modification des fenètres:
.patch ($01DB61)
	.dw $0000, $1A1C	;fenètre principale
	.dw $04EE, $0507	;fenètre Gils
	.dw $04EE, $0507	;fenètre temps
	.dw $006E, $0F07	;fenètre menu principal
.endp (0)

;*****************
;** Decalages ! **
;*****************

; décalage du niveau (ex: 10)
.patch ($0189FA)
	STA.W $0014,X
	XBA
	STA.W $0016,X
.endp (0)

; deplacement du nom du perso
.patch ($0183D5)
	STA.W $0040,Y
	XBA
	STA.W $0080,Y
.endp (0)

; decalage du nombre de Gils
.patch ($018FAF)
	ADC.W #$0012
.endp (0)


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

;**************************
;** Classes des Persos ! **
;**************************
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
	LDA.B #$0F
.endp (0)

.patch ($018FE7)
	JSL.L _8x16
	JSL.L _8x16dis2
	NOP
	NOP
	NOP
.endp (0)

;exemple d'appel
;
;	LDA.B #$numptr
;	JSL.L textload	;textload(numptr)

;deroutage pour charger le menu à l'aide d'un pointeur 24bit
.patch ($018931)
	JSR.W PT0000	
.endp (0)

; TIME
.patch ($0187CE)
	LDA.B #$01
	JSL.L textload
	NOP
	NOP
	NOP
.endp (0)

; Gils
.patch ($0187C5)
	LDA.B #$02
	JSL.L textload
	NOP
	NOP
	NOP
.endp (0)

; "Ne peux utiliser"
.patch ($01AED9)
	JSR.W PT0001
.endp (0)

; fenètre Ne peut utiliser
.patch ($01DD40)
	.dw $0210, $0310
.endp (0)

;*************************************
;** Menu Objet                      **
;*************************************
;Objet:
;Layer 4
.patch ($01A817)
	JSR.W PT0002
.endp (0)

;layer 2
.patch ($019F59)
	JSR.W PT0002
.endp (0)

;fenètre Objet
.patch ($01DCFC)
	.dw $0000, $0307
.endp (0)

;fenètre Description objet
.patch ($01DCD6)
	.dw $0010, $0316
.endp (0)

.patch ($01A36F)
	LDA.B #$05
	JSL.L textload
.endp (0)

;Fenètre principale objet
.patch ($01DCCE)
	.dw $0000, $301E
.endp (0)

;*************************************
;** Menu Configuration              **
;*************************************

; Configuration
.patch ($01D1A7)
	JSR.W PT0003
.endp (0)

.patch ($01E168)
	.dw $0102, $141C
.endp (0)

;RGB -> RVB :o)
.patch ($01D1BB)
	LDA.B #$57
.endp (0)

;fenètre du titre "options"
.patch ($01E15C)
	.dw $0054, $0209
.endp (0)

;"Options"
.patch ($01D1B0)
	LDA.B #$07
	JSL.L textload
.endp (0)

;déplacement du curseur principal des options
.patch ($01D247)
	LDA.B #$00
.endp (0)

;main dans le menu controle
;x
.patch ($01D4E6)
	LDA.B #$03
.endp (0)

;y
.patch ($01D4E2)
	ADC.B #$4C
.endp (0)

; "buttons" :)
.patch ($01D496)
	LDA.B #$0F
	JSL.L textload
.endp (0)

; 
.patch ($01E200)
	.dw $01C0, $0C1C
.endp (0)

;multiple:
.patch ($01D662)
	JSR.W derout_mult
.endp (0)

.patch ($01D685)
	LDA.B #$13
	JSL.L textload
.endp (0)

;*************************************
;** Menu Magie	                    **
;*************************************
.patch ($01AFA2)
	LDA.B #$08
	JMP.W derout_magie
.endp (0)

.patch ($01AFB6)
	LDA.B #$09
	JMP.W derout_magie2
.endp (0)

.patch ($01AFCA)
	LDA.B #$0A
	JMP.W derout_magie3
.endp (0)

;.patch ($01AFA7)
;LDA.B #$11
;	JMP.W derout_magie4
;.endp (0)

.patch ($01AFDE)
	LDA.B #$11
	JSL.L textload
.endp (0)

;MP needed
.patch ($01B0EC)
	LDA.B #$10
	JSL.L textload
	NOP
	NOP
	NOP
.endp (0)

;décalage du cout
.patch ($01B0F7)
	STA.W $C858
.endp (0)

.patch ($01B0E6)
	LDY.W #$025C
.endp (0)


;décalage de la "main"
.patch ($01B0CE)
	LDA.B #$00
.endp (0)

;Grisement des types sorts : "Blancs" "Noirs" etc ...
.patch ($01B419)
	LDY.W #$0007
	STA.W $C5FF,X
.endp (0)

.patch ($01B345)
	LDA.B #$07
.endp (0)


;*************************************
;** Menu Status	                    **
;*************************************

;décalage du nom vers le haut
.patch ($01A9B7)
	LDY.W #$0044
.endp (0)

.patch ($01A99E)
	LDA.B #$0B
	JSL.L textload
.endp (0)

.patch ($01AAE9)
	LDA.B #$0C
	JSL.L textload
.endp (0)

;experience et tout le bidule
.patch ($01ABBC)
	LDA.B #$0D
	JSL.L textload
.endp (0)

.patch ($01D48D)
	LDA.B #$0E
	JSL.L textload
.endp (0)

;*******************
;** Menu Equiper  **
;*******************

;dernière fenètre a apparaitre:
.patch ($01DDA9)
	.dw $0000, $0B1E
.endp (0)

;données pour translater ...
.patch ($01DD95)
	.dw $0000, $0B1E
.endp (0)

.patch ($01BD12)
	JSR.W derout_equip
.endp (0)

;*********************************
;** Décalage des objets equipés **
;*********************************

;Main D
.patch ($01BD92)
	LDX.W #$0068
.endp (0)

;Main G
.patch ($01BDA8)
	LDX.W #$00E8
.endp (0)

;Tête
.patch ($01BD7B )
	LDX.W #$0168
.endp (0)

;Corps
.patch ($01BD82)
	LDX.W #$01E8
.endp (0)

;Bras
.patch ($01BD89)
	LDX.W #$0268
.endp (0)

.patch ($01903F)
	LDA.B #$0A
.endp (0)

.patch ($019028)
	JSR.W calc_itempos
	retcalcpos:
.endp (0)

.patch ($019047)
	JSR.W _8x16item
.endp (0)

; Routines d'affichage de differents textes ^^
.patch ($01FF36)
retmag 	= $01AFAD
retmag2	= $01AFC1
retmag3	= $01AFD5

;ça foire si je mets autre chose que des ASL
calc_itempos:
	ASL
	ASL
	ASL
	ASL
	RTS

_8x16item:
	JSL.L _8x16
	RTS

derout_magie:
	JSL.L textload
	JMP.W retmag

derout_magie2:
	JSL.L textload
	JMP.W retmag2

derout_magie3:
	JSL.L textload
	JMP.W retmag3

derout_mult:
	JSR.W $80D9
	LDA.B #$12
	JSL.L textload
	RTS

derout_equip:
	LDA.B #$14
	JSL.L textload
	RTS
PT0000:
	JSR.W $80D9
	LDA.B #$00
	JSL.L textload
	RTS

PT0001:
	JSR.W $80D9
	LDA.B #$03
	JSL.L textload
	RTS
PT0002:
	JSR.W $80D9
	LDA.B #$04
	JSL.L textload
	RTS
PT0003:
	JSR.W $80D9
	LDA.B #$06
	JSL.L textload
	RTS
.endp (0)
.patch ($20B000)

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

_8x16dis2:	
	CMP #$00
	BEQ no2_8x16
	STA.W $0000,Y
	
	no2_8X16:
		XBA
		STA.W $0040,Y	
	INY
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

;deroutage pour le grisement de "Sauver
derout_save:
	LDA.B #$24
	STA $CA31	;S
	STA $CA33	;a
	STA $CA35	;u
	STA $CA37	;v
	STA $CA39	;e
	STA $CA3B	;r
	RTL

;deroutage pour l'affichage du NIVEAU
deroutage:
	LDA.B #$4E	;M
	STA.W $0082,X

	LDA.B #$57	;V
	STA.W $0042,X

;	LDA.B #$C7	;/
;	STA.W $004E,X
;	STA.W $008E,X
	RTL


;chargement du pointeur et chargement du texte

textload:
	;chargement du pointeur
	PHX
	REP #$20
	AND.W #$00FF
	STA $00
	ASL
	ADC.B $00
	TAX
	
	LDA ptrtbl,X
	INX
	INX
	TAY
	SEP #$20

	LDA ptrtbl,X
	STA $02
	STZ $01
	STZ $00
wram:
	REP #$20
	LDA [$00],Y
	INY
	INY
	CLC
	ADC $29
	TAX
	SEP #$20	
loop:
	LDA [$00],Y
	BEQ fin
	INY

	CMP #$01
	BEQ wram

	JSL _8x16
	JSL _8x16disp
	
	BRA loop	
fin:
	PLX
	RTL


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
	.dw $608A,$608B,$608C,$608D,$5C8A,$5C8B,$6A8B,$708A,$708B,$ffff,$ffff,$ffff,$ffff,$ffff,$9E00,$ffff	;$9
	.dw $ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff	;$A
	.dw $ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff	;$B
	.dw $C000,$C100,$C200,$C300,$C400,$C500,$C600,$C700,$C800,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff	;$C
	.dw $ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff	;$D
	.dw $ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff	;$E
	.dw $ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ff00	;$F


; addresse de la table des pointeurs pour le code :)
ptrtbl:
	; table de pointeurs 24 bits pour les textes du menu
	; ainsi que les textes qui vont avec yay ! \o/
	.incsrc "tx_menus.txt"

commandes:
.asc "Attaquer           "
	
.endp (0)
.incsrc "battle.asm"