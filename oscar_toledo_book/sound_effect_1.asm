;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Generating sound effects on the 2600.
;
; A VCS sound can change three parameters: waweform, frequence, 
; and volume. The typical VCS strategy is to generate the 
; sound effects while generating the upper and/or lower border.
; On the VCS, we need to interlace sound with the drawing of 
; graphics + game logic.
;
        processor 6502
        include "vcs.h"
        include "macro.h"
        include "xmacro.h"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Variables segment

        seg.u Variables
        org $80
        
DurationCounter .byte

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Code segment

        seg Code
        org $f000

Start
        CLEAN_START

NextFrame:
        lsr SWCHB       ; test Game Reset switch
        bcc Start       ; reset cartridge?
        
        lda #$88        ; blue background
        sta COLUBK
; 1 + 3 lines of VSYNC
        VERTICAL_SYNC
; 37 lines of underscan
        TIMER_SETUP 37
        TIMER_WAIT
; 192 lines of frame
        TIMER_SETUP 192

        TIMER_WAIT      ; timer is already 0, no-op
; 29 lines of overscan
        TIMER_SETUP 29
        
        ; Press joystick 1 button to launch the sound effect
        lda INPT4
        bmi PlaySound   ; negative (no jump) unless pressed
        lda DurationCounter
        bne PlaySound   ; do not start a new sound if already playing
        lda #10         ; start new sound -- duration of the sound effect
        sta DurationCounter
PlaySound:
        lda DurationCounter
        beq StopSound
        dec DurationCounter
        clc
        adc #2          ; drop the volume on each frame (12 -> 2)
        sta AUDV0       ; volume, 0 (silence) -> 15 (loudest)
        adc #5          ; lower the frequency on each frame (17 -> 7)
        sta AUDF0
        lda #4          ; set the wawe form. 4 is a pure tone.
        sta AUDC0
        jmp WaitForNextFrame
        
StopSound:
        lda #0
        sta AUDV0       ; turn of the sound
WaitForNextFrame:
        TIMER_WAIT
; total = 262 lines, go to next frame
        jmp NextFrame

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Epilogue

        org $fffc
        .word Start     ; reset vector
        .word Start     ; BRK vector