	;
	; A NUSIZ demo with space invaders like sprites dropping 
    ; missiles.
	;
    ; The original code used as a template is
	; by Oscar Toledo G.
	; https://nanochess.org/
	;
	; Adopted and modified by Nephen-Ka in 2024. 
    ; Not because anything was wrong with the code, but rather 
    ; because that's how I learn: modifying and re-writing 
    ; existing code.
	;

	PROCESSOR 6502
	INCLUDE "vcs.h"
    include "macro.h"
	include "xmacro.h"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Variables segment

	seg.u Variables
	org $80

FRAME   	.byte		; Frame number saved in this address.
SECONDS 	.byte		; Seconds value saved in this address.
MISSILE_VPOS 	.byte

ALIEN_SCANLINES equ 8

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Code segment
	seg Code
	ORG $F000
START:
	CLEAN_START

SHOW_FRAME:
	VERTICAL_SYNC   ; 1 VBLANK + 3 VSYNC
    TIMER_SETUP 37  ; 37 VBLANK

	LDA #$88	; Blue.
	STA COLUBK	; Background color.
	LDA #$0F	; White.
	STA COLUP0	; Player 0 color.
	LDA #$00	; Black.
	STA COLUP1	; Player 1 color.

	; high nibble, 1: wider missiles
    ; low nubble,  3: show 3 copies of each player
    LDA #$13	
	STA NUSIZ0	; Player 0 size/repeat.
	STA NUSIZ1	; Player 1 size/repeat.
        
    lda #35 ; player 1
	ldx #0  ; player object 1
    jsr PositionHoriz
        
    lda #100 ; player 1
	ldx #1  ; player object 1
    jsr PositionHoriz
    
    ; start position reset for the missile to the player position:
    STA WSYNC
    LDA #2
    STA RESMP0
    STA RESMP1
    
    ; finish position reset by allowing the missile to becme visible:
    STA WSYNC
    LDA #0
    STA RESMP0
    sta RESMP1
    
    ; Note that HMOVE updates *all* sprites, so we only want to 
	; do it once all our objects are positioned. Now is that time:
	sta WSYNC
	sta HMOVE   ; apply HMOVE to update the X position
	TIMER_WAIT
	; Turns off the Vertical Blank signal ( = image output on)
	lda #0
	sta VBLANK

	LDX #92		; 92 scanlines in blue
VISIBLE:
	STA WSYNC
	DEX
	BNE VISIBLE
 
 	LDY #ALIEN_SCANLINES
    CLC
DRAW_ALIENS:
 	LDA AlienBitmap,y
	STA WSYNC	; One scanline	; 
	STA GRP0
	STA GRP1
        
    DEY
    BNE DRAW_ALIENS
    
    lda #0		; disable the sprites
    STA GRP0
	STA GRP1

	LDA #$F8	; Sand color
	STA COLUBK

	LDX #91		; 91 scanlines
    LDY MISSILE_VPOS ; Y contains the missile scanline
VISIBLE2:
	STA WSYNC
    LDA #0		; disable missile
    CPY #0		; are we at the scanline for the missile?
    BNE DRAW_MISSILE
    LDA #2		; enable missile
DRAW_MISSILE:
	STA ENAM0	; player 1 missile
    STA ENAM1	; ...and for player 2
    DEY		; move the missile to the next scanline
        
	DEX
	BNE VISIBLE2

	; Overscan
	TIMER_SETUP 29
    ; Turns on the Vertical Blank signal ( = image output off)
	lda #2
    sta VBLANK

	INC FRAME	; Increase frame number
	LDA FRAME	; Read frame number
	CMP #60		; Is it 60?
	BNE L1		; Branch if not equal.
	LDA #0		; Reset frame number to zero.
	STA FRAME
    STA ENAM0	; Disalbe missile 1
    STA ENAM1	;  ...and missile 2
        
	INC SECONDS	; Increase number of seconds.
    INC MISSILE_VPOS ; animate the missiles dropping
L1:
	TIMER_WAIT
	JMP SHOW_FRAME

; The bitmap is rendered in reversed order:
AlienBitmap:
	.byte #0 ; padding
	.byte #$24
	.byte #$A5
	.byte #$BD
	.byte #$FF
	.byte #$5A
	.byte #$3C
	.byte #$24
	.byte #$42 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PositionHoriz subroutine
    sta WSYNC   ; wait for the next scanline
    ; To find the rough X-position, we divide by 15.
    ; We divide by 15 since that's the number of TIA 
    ; clock cycles consumed by our instructions in the 
    ; loop below (sbc and bcs).
    ;
    ; Of course, there's no division support on the 6502 so we 
    ; need to subtract instead until A becomes negative.
    sec         ; Always set carry when subtracting.
.RoughXPosition ; The . (dot) creates a local label.
    sbc #15
    bcs .RoughXPosition ; Until A is negative
    ; The fine position can be set within -7 <-> +8 pixels.
    ; To do this, we keep the reminder from our division 
    ; and shift those bits left into the higher nibble; the HMP0 
    ; registers wants it there.
    eor #7
    asl
    asl
    asl
    asl
    sta HMP0,x      ; the fine offset..
    sta RESP0,x     ; ..and its coarse position.
    rts

	ORG $FFFC
	 .word START
	 .word START