;.incsrc "asm2ips.asm"

; Code ASM pour les Combats
; Codé Par ManZ
;.memmapset (LOW,YES)
;.detect on

;sensé effacer des machins
;JSR.W $83E1
;.patch ($028A00)
;NOP
;NOP
;NOP
;.endp (0)
;idem
;.patch ($028A09)
;region de la mêmoire réservée à l'affichage des dégats
;.patch ($028A12)

;interessant enlève le haut et le bas des fenêtres
;029AEA JSR $8675     [028675] A:007E X:BE66 Y:7000 S:02E0 DB:7E D:0000 P:A4 e

;copie du background
;029201 JSR $8675     [028675] A:007E X:6CFD Y:5800 S:02E0 DB:7E D:0000 P:24 e

;yangtsérieng
;029222 JMP $8675     [028675] A:007E X:6CFD Y:5C00 S:02E0 DB:7E D:0000 P:24 e

;copie du tileset de la font
;029144 JSR $8675     [028675] A:000A X:F000 Y:5000 S:02E0 DB:7E D:0000 P:24 e

; ne fais rien de visuel
;0290BD JSR $8675     [028675] A:000A X:F760 Y:4DB0 S:02DC DB:7E D:0000 P:24 e
;idem
;028B3E JSR $8675     [028675] A:007E X:6CFD Y:6000 S:02E2 DB:7E D:0000 P:25 e

;copie des sprites des persos
;02E0D9 JSR $8675     [028675] A:001A X:8000 Y:0000 S:02E0 DB:7E D:0000 P:24 e

;calcul du pointeur vers la commande
;SIZE = $000C

;.patch ($029D15)
;	LDA.B #$0B
;.endp (0)

;longueur de commande à afficher
.patch ($029D42)
	CPY.W #$000C
.endp (0)
;.patch ($029D1E)
;LDA.B #$01
;.endp (0)
.patch ($029D5A)
	CPY.W #$000C
.endp (0)
.patch ($029D39)
	LDA.L commandes,X
.endp (0)

.patch ($16FE5A)
	.db $01, $00, $0C, $0D, $A6, $C1
	.db $0D, $00, $12, $0D, $A6, $C1
	.db $06, $00, $0C, $0D, $A6, $C1	;finestron :)
.endp (0)