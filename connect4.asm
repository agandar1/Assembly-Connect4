include Irvine32.inc

.data
welc1  byte " _    _      _                            _         ", 0ah, 0dh, 0
welc2  byte "| |  | |    | |                          | |        ", 0ah, 0dh, 0
welc3  byte "| |  | | ___| | ___ ___  _ __ ___   ___  | |_ ___   ", 0ah, 0dh, 0
welc4  byte "| |/\| |/ _ \ |/ __/ _ \| '_ ` _ \ / _ \ | __/ _ \  ", 0ah, 0dh, 0
welc5  byte "\  /\  /  __/ | (_| (_) | | | | | |  __/ | || (_) | ", 0ah, 0dh, 0
welc6  byte " \/  \/ \___|_|\___\___/|_| |_| |_|\___|  \__\___/  ", 0ah, 0dh, 0
welc7  byte "                                                    ", 0ah, 0dh, 0
welc8  byte " _____                             _     ___ _      ", 0ah, 0dh, 0
welc9  byte "/  __ \                           | |   /   | |     ", 0ah, 0dh, 0
welc10 byte "| /  \/ ___  _ __  _ __   ___  ___| |_ / /| | |     ", 0ah, 0dh, 0
welc11 byte "| |    / _ \| '_ \| '_ \ / _ \/ __| __/ /_| | |     ", 0ah, 0dh, 0
welc12 byte "| \__/\ (_) | | | | | | |  __/ (__| |_\___  |_|     ", 0ah, 0dh, 0
welc13 byte " \____/\___/|_| |_|_| |_|\___|\___|\__|   |_(_)     ", 0ah, 0dh, 0
welc14 byte "Enter a 1 for Singleplayer, or a 2 for Multiplayer: ", 0
top    byte "------------------------------------------- ", 0
empty  byte "|     |     |     |     |     |     |     | ", 0
key    byte "   1     2     3     4     5     6     7    ", 0ah, 0dh, 0
wall1  byte "| ", 0
wall2  byte " ", 0
p1     byte " X", 0
p2     byte " O", 0
id1    byte "Player 1: ", 0
id2    byte "Player 2: ", 0
prompt byte "Enter a Column(1-7): ", 0
wins   byte "Wins!", 0ah, 0dh, 0
ties   byte "There has been a tie!", 0ah, 0dh, 0
board  dword 42 dup(0)              ;array for board
winner dword 0                      ;stores who won
edge   dword 0                      ;used to check if chip is on column 1 or 7
who    dword 0                      ;stores whos turn it is
mode   dword 0                      ;stores game mode
count  dword 0                      ;counts adjacent chips
last   dword 0                      ;stores location of player1's last chip
last1  dword 0                      ;stores last column used by player1
test1  dword 0                      ;tells the check procs if the check is for real or just a test
tmp    dword 0                      ;temp variable for general use
tmp1   dword 0                      ;temp variable for general use
tmp2   dword 0                      ;temp variable for general use
s_1    dword 0                      ;used for searching proc: who are we searching for
s_2    dword 0                      ;used for searching proc: how many chips are we looking for
here   dword 0                      ;used for when search proc finds a good spot



.code
welcome proc                        ;procedure to print out a welcome for the user
    mov edx, offset welc1
    call writestring
    mov edx, offset welc2
    call writestring
    mov edx, offset welc3
    call writestring
    mov edx, offset welc4
    call writestring
    mov edx, offset welc5
    call writestring
    mov edx, offset welc6
    call writestring
    mov edx, offset welc7
    call writestring
    mov edx, offset welc8
    call writestring
    mov edx, offset welc9
    call writestring
    mov edx, offset welc10
    call writestring
    mov edx, offset welc11
    mov edx, offset welc12
    call writestring
    mov edx, offset welc13
    call writestring
    call crlf
    mov edx, offset welc14
    call writestring
    call readint
    mov mode, eax
ret
welcome endp



chips proc                          ;this proc prints out the players' chips
    mov edx, offset wall1           ;print out an inner wall
    call writestring
    mov edx, 1                      ;check if player 1 has a chip at that location
    cmp [esi], edx                  ;compare player 1 chip to array element
        je player1                  ;jump if player 1 has chip
        jg player2                  ;jump if player 2 has chip

    mov edx, offset wall2           ;print a space if spot is empty
    call writestring
    call writestring
    jmp end1                        ;jump ahead

    player1:
        mov edx, offset p1          ;print X at that spot
        call writestring
        jmp end1                    ;jump ahead
    player2:
        mov edx, offset p2          ;print O at that spot
        call writestring
    end1:
        mov edx, offset wall2       ;print 2 spaces for the board to look nice
        call writestring
        call writestring
    add esi, 4
ret
chips endp                          ;end of chips proc



draw1 proc                          ;this proc re-draws the board
    mov esi, offset board           ;go to start of array
    mov edx, offset top             ;print the top of the board
    call writestring
    call crlf
 
    mov ecx, 6                      ;number of rows
    outer:                          ;loop for the rows
        mov edx, offset empty       ;print blank row
        call writestring
        call crlf

        mov ebx, ecx                ;save outer counter to ebx
        mov ecx, 7                  ;set counter for the column loop
        inner:                      ;loop for the columns
            call chips              ;call procedure that prints each player's chips
        loop inner

        mov edx, offset wall1       ;print out an inner wall
        call writestring
        call crlf
        mov edx, offset empty       ;print out empty row
        call writestring
        call crlf
        mov edx, offset top         ;print row divider
        call writestring   
        call crlf
        mov ecx, ebx                ;reset the row counter
    loop outer
    mov edx, offset key
    call writestring
ret
draw1 endp                          ;end of drawing proc


check_h  proc                       ;checks for horizontal connect 4
    mov eax, [esi]                  ;see what player just put down a chip
    mov ebx, esi                    ;get location of that chip
    mov count, 1                     ;set chip count to 1
    
    right:                          ;counts chips to right of OG chip
        add esi, 4                  ;move one space right
        cmp [esi], eax              ;check if its owned by that player
            je matchr               ;jump to matchr if they match
            jne reset               ;jump to reset if no match

    matchr:                         ;jump here if chips match
        inc count                    ;add 1 to chip count
        mov edge, offset board      ;edge used to check if we've reached an edge
        add edge, 24                ;move from top left to top right corner
        mov ecx, 7                  ;set loop counter to check all edge positions
        stop:                       ;stop loop checks if we are at any tile on right edge
            cmp esi, edge           ;compare current location to edge location
                je reset            ;jump to reset if we are at an edge
            add edge, 28            ;go down a slot to check next edge spot
        loop stop                   ;loop to check next edge spot
            
        jmp right                   ;if we are not at an edge, we can check another slot to the right
 
    reset:                          ;reset;
        mov esi, ebx                ;go back to OG chip location to start checking left side

    left:                           ;check to the left side now                     
        sub esi, 4                  ;move one slot to the left
        cmp [esi], eax              ;check if chips match
            je matchl               ;if match, goto matchl
            jne verify              ;if not go to verify

    matchl:                         ;jmp here if the chips matched
        inc count                   ;add one to counter
        mov edge, offset board      ;move edge to top left corner
        mov ecx, 7                  ;set loop counter to check all edge slots
        stop2:                      ;stop2 loop checks if we are at ant tile on left side
            cmp esi, edge           ;compare current location to an edge location
                je verify           ;if we are at edge, jump to verify
            add edge, 28            ;if not, move an edge tile down
        loop stop2                  ;loop to check next tile down

        jmp left                    ;if not at an edge, we can check another spot to the left

    verify:                         ;verify;
        cmp count, 4                ;compare number of horizontal chips to 4
        jl nowin                    ;if its under 4, goto nowin
    
    cmp test1, 1
        je nowin
    mov winner, eax                 ;if it is >= 4, move the player # to winner variable
    
nowin:                          ;nowin;
    mov esi, ebx               ;move back to OG chip to check another direction
    mov last, ebx
ret
check_h endp



check_v  proc                       ;Vertical: same as horizontal check, but checks down then up
    mov eax, [esi]
    mov ebx, esi
    mov count, 1

    down:
        add esi, 28
        cmp [esi], eax
            je matchd
            jne reset

    matchd:
        inc count 

        mov edge, offset board
        add edge, 168
        mov ecx, 8
        stopp:
            cmp esi, edge
                je toofar
            add edge, 4
        loop stopp

        jmp down

    toofar: 
        dec count

    reset:
        mov esi, ebx

    up:
        sub esi, 28
        cmp [esi], eax
            je matchu
            jne verify

    matchu:
        inc count 
        jmp up

    verify:
        cmp count, 4
        jl nowin
    
    cmp test1, 1
        je nowin

    mov winner, eax

nowin:
    mov esi, ebx
    mov last, ebx
ret
check_v endp


    
check_d1  proc                      ;Diagonal1: same as other checks, but checks down-right then up-left
    mov eax, [esi]
    mov ebx, esi
    mov count, 1

    downr:
        add esi, 32
        cmp [esi], eax
            je matchdr
            jne reset

    matchdr:
        inc count
  
        mov edge, offset board
        add edge, 24
        mov ecx, 7
        stop:
            cmp esi, edge
                je reset
            add edge, 28
        loop stop

        jmp downr

    reset:
        mov esi, ebx
        mov edge, offset board
        mov ecx, 7
        stop1:
            cmp esi, edge
                je verify
            add edge, 28
        loop stop1

    upl:
        sub esi, 32
        cmp [esi], eax
            je matchul
            jne verify

    matchul:
        inc count

        mov edge, offset board
        mov ecx, 7
        stop2:
            cmp esi, edge
                je verify
            add edge, 28
        loop stop2

        jmp upl

    verify:
        cmp count, 4
        jl nowin
    
    cmp test1, 1
        je nowin

    mov winner, eax

nowin:
    mov esi, ebx
    mov last, ebx
ret
check_d1 endp


    
check_d2  proc                      ;Diagonal2: same as others, but checks up-right then down-left 
    mov eax, [esi]
    mov ebx, esi
    mov count, 1

    downl:
        add esi, 24
        cmp [esi], eax
            je matchdl
            jne reset

    matchdl:
        inc count

        mov edge, offset board
        mov ecx, 7
        stop:
            cmp esi, edge
                je reset
            add edge, 28
        loop stop
        
        mov edge, offset board
        add edge, 168
        mov ecx, 8
        stopp:
            cmp esi, edge
                je toofar
            add edge, 4
        loop stopp

        jmp downl

    toofar:
        dec count

    reset:
        mov esi, ebx
        mov edge, offset board
        add edge, 24
        mov ecx, 7
        stop1:
            cmp esi, edge
                je verify
            add edge, 28
        loop stop1

    upr:
        sub esi, 24
        cmp [esi], eax
            je matchur
            jne verify

    matchur:
        inc count

        mov edge, offset board
        add edge, 24
        mov ecx, 7
        stop2:
            cmp esi, edge
                je verify
            add edge, 28
        loop stop2

    jmp upr

    verify:
        cmp count, 4
        jl nowin
   
    cmp test1, 1
        je nowin
 
    mov winner, eax

nowin:
    mov esi, ebx
    mov last, ebx
ret
check_d2 endp



check_tie proc                      ;checks for a tie
    mov esi, offset board           ;move to top left of array
    sub esi, 4                      ;set location back because we start loop by adding
    mov edx, 0                      ;save 0 to edx, 0 represents an empty slot
    mov ecx, 8                      ;loop will run 8 times
    redo:                           ;loop will run through top row and look for empty slot
        add esi, 4                  ;move to next slot
        cmp [esi], edx              ;see if its empty
            je notie                ;if an empty slot is found in top row, no tie yet
    loop redo                       ;check next row for empty slot
    
    mov winner, 3                   ;if no empty slot on top row, all others must be full,
                                    ;a 3 in the winner variable represents a tie
    notie:
ret
check_tie endp



search_v proc
    mov ecx, 7
    rows1:
        mov esi, offset board
        mov eax, 7
        sub eax, ecx
        mov tmp2, eax
        mov edx, 4
        imul edx
        add esi, eax
        add esi, 140

        mov tmp1, ecx
        mov ecx, 6
        columns1:
            mov edx, 0
            cmp [esi], edx
                je check1
            sub esi, 28  
        loop columns1
        jmp skip1

        check1:
            mov tmp, edx
            mov edx, s_1
            mov [esi], edx          
            mov edx, s_2

            call check_v
            cmp count, edx
                jge goodspot
    
            mov edx, 0
            mov [esi], edx
            mov edx, tmp                        
        skip1:
        mov ecx, tmp1
    dec ecx
    jnz rows1
    jmp finish

    goodspot:
        mov here, 1
finish:
ret
search_v endp



search_d1 proc
    mov ecx, 7
    rows1:
        mov esi, offset board
        mov eax, 7
        sub eax, ecx
        mov tmp2, eax
        mov edx, 4
        imul edx
        add esi, eax
        add esi, 140

        mov tmp1, ecx
        mov ecx, 6
        columns1:
            mov edx, 0
            cmp [esi], edx
                je check1
            sub esi, 28  
        loop columns1
        jmp skip1

        check1:
            mov tmp, edx
            mov edx, s_1
            mov [esi], edx          
            mov edx, s_2

            call check_d1
            cmp count, edx
                jge goodspot
    
            mov edx, 0
            mov [esi], edx
            mov edx, tmp                        
        skip1:
        mov ecx, tmp1
    dec ecx
    jnz rows1
    jmp finish

    goodspot:
        mov here, 1
finish:
ret
search_d1 endp



search_d2 proc
    mov ecx, 7
    rows1:
        mov esi, offset board
        mov eax, 7
        sub eax, ecx
        mov tmp2, eax
        mov edx, 4
        imul edx
        add esi, eax
        add esi, 140

        mov tmp1, ecx
        mov ecx, 6
        columns1:
            mov edx, 0
            cmp [esi], edx
                je check1
            sub esi, 28  
        loop columns1
        jmp skip1

        check1:
            mov tmp, edx
            mov edx, s_1
            mov [esi], edx          
            mov edx, s_2

            call check_d2
            cmp count, edx
                jge goodspot
    
            mov edx, 0
            mov [esi], edx
            mov edx, tmp                        
        skip1:
        mov ecx, tmp1
    dec ecx
    jnz rows1
    jmp finish

    goodspot:
        mov here, 1
finish:
ret
search_d2 endp


    
search_h proc
    mov ecx, 7
    rows1:
        mov esi, offset board
        mov eax, 7
        sub eax, ecx
        mov tmp2, eax
        mov edx, 4
        imul edx
        add esi, eax
        add esi, 140

        mov tmp1, ecx
        mov ecx, 6
        columns1:
            mov edx, 0
            cmp [esi], edx
                je check1
            sub esi, 28  
        loop columns1
        jmp skip1

        check1:
            mov tmp, edx
            mov edx, s_1
            mov [esi], edx          
            mov edx, s_2

            call check_h
            cmp count, edx
                jge goodspot
    
            mov edx, 0
            mov [esi], edx
            mov edx, tmp                        
        skip1:  
        mov ecx, tmp1
    dec ecx
    jnz rows1
    jmp finish

    goodspot:
        mov here, 1
finish:
ret
search_h endp


    
makeChoice proc
    mov test1, 1                    ;set test1 to true so game doesnt end during testing

    mov s_1, 2
    mov s_2, 4
    mov here, 0
    call search_v
    cmp here, 1
        je place
    call search_d1
    cmp here, 1
        je place
    call search_d2
    cmp here, 1
        je place
    call search_h
    cmp here, 1
        je place

    mov s_1, 1
    mov s_2, 4
    mov here, 0
    call search_v
    cmp here, 1
        je place
    call search_d1
    cmp here, 1
        je place
    call search_d2
    cmp here, 1
        je place
    call search_h
    cmp here, 1
        je place

    mov s_1, 2
    mov s_2, 3
    mov here, 0
    call search_v
    cmp here, 1
        je place
    call search_d1
    cmp here, 1
        je place
    call search_d2
    cmp here, 1
        je place
    call search_h
    cmp here, 1
        je place

    mov s_1, 2
    mov s_2, 2
    mov here, 0
    call search_v
    cmp here, 1
        je place
    call search_d1
    cmp here, 1
        je place
    call search_d2
    cmp here, 1
        je place
    call search_h
    cmp here, 1
        je place

    mov eax, 8
    sub eax, 1
    call RandomRange
    mov tmp2, eax       

    place:
        mov edx, 0
        mov [esi], edx
        mov eax, tmp2   
        add eax, 1
    
noplace:
    mov test1, 0                    ;set it back so checks work for real
ret
makeChoice endp



turn1 proc                          ;proc for player 1's turn 
    redo:                           ;redo for if chosen row is full
        cmp who, 1
            je player1

        cmp mode, 1
            je computer

        mov edx, offset id2
        jmp prompt1

        computer:
            call makeChoice
            jmp skipPrompt

        player1:
            mov edx, offset id1 

    prompt1:
        call writestring
        mov edx, offset prompt
        call writestring
        call readint
        mov last1, eax

    skipPrompt: 
        sub eax, 1                  ;sub 1 because arrays start at 0
        mov ebx, 4                  ;save 4 for ebx for multiplying
        imul ebx                    ;multiply by 4 to get # of bits to skip
    
        mov esi, offset board       ;move to start of array
        add esi, eax                ;skip to desired column
        mov edx, 0                  ;save 0 for compare
        cmp [esi], edx              ;see if the top box is empty
            jg redo                 ;redo if box(and therefore column) is full

        add eax, 140                ;add 140 to go to bottom of column
        mov esi, offset board       ;move esi to start of array
        add esi, eax                ;move esi to bottom of chosen column

        mov ecx, 6                  ;set up loop counter (6 rows)
        open1:                      ;loop that finds open box
            mov ebx, 0              ;save 0 for compare
            cmp [esi], ebx          ;see if the box is empty
                je found            ;if it is go to found
            sub esi, 28             ;if not move up one row
            jmp end2                ;then jump to end of loop

            found:                  ;run this if spot is empty
                mov ebx, who        ;move the player's number to ebx
                mov [esi], ebx      ;save the number to the array
                jmp end1            ;jump to end1
            
            end1:                   ;end1
                mov ecx, 1          ;drop counter to 1 to end loop
            end2:
        loop open1
    ret
turn1 endp                          ;end of turn



main proc                           ;start of main game
    call welcome                    ;prints out the welcome sign
    call draw1                      ;draw empty board

    mov ecx, 5                      ;loop counter(sice ecx changes in the procs, this will
                                    ;basically run infinetly until someone wins or there is a tie)
    turns:                          ;game loop
        cmp who, 1                  ;check if player 1 went last
            jne p1turn              ;if not, its p1's turn
    
        mov who, 2                  ;if it was p1, then now its p2's turn
        jmp checks                  ;now that its player 2's turn go to their turn

        p1turn:                     ;if its p1's turn now, set who to 1
            mov who, 1
    
        checks:                     ;jump here for a player's turn
            call turn1              ;call turn function to let player place a chip
  
            call check_h            ;check if they won horizontally
            call check_v            ;check if they won vertically
            call check_d1           ;check if they won diagonally
            ;call check_d2           ;check if they won on the other diagonal
            call check_tie          ;check if there is tie
            call draw1              ;update the board

        cmp winner, 0               ;compare winner variable to 0
            jne won                 ;if it is no longer 0, someone won or there was a tie
    loop  turns                     ;if no one won this turn, do next turn

    won:                            ;jump here if someone won
        call draw1                  ;update board
        cmp winner, 3               ;check if it was a tie
            je tied
        cmp winner, 1               ;check if p1 won
            je p1w

        mov edx, offset id2         ;if it wasnt a tie and p1 didnt win,
        call writestring            ;print out that player 2 won
        mov edx, offset wins
        call writestring
        jmp close                   ;go to close
    
        p1w:                        ;if player 1 wom
            mov edx, offset id1     ;print out that player 1 won
            call writestring
            mov edx, offset wins
            call writestring
            jmp close

        tied:                       ;if there is a tie
            mov edx, offset ties    ;print out that there was a tie
            call writestring
    close:                          ;close the game and exit program
    call waitmsg 
exit
main endp
END main
