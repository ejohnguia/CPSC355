/*
Ezra John Guia
30031697
Assignment 5
Assembly Source - a5b.asm
355 LEC - 02
Tutorial - T08
*/

//----------Macros----------//
define(argc_r,   w19)    //Number of args
define(argv_r,   x20)    //Array of pointers

define(month_r,     w21)    //Month saved
define(day_r,       w22)    //Day saved
define(suffix_r,    w23)    //Determined suffix
define(season_r,    w24)    //Determined season

define(month_base_r,    x25)    //Month base address
define(season_base_r,    x26)   //Season base address
define(suffix_base_r,    x27)   //Suffix base address

//----------Strings----------//
//----------[months]----------//
m1:     .string "January"
m2:     .string "February"
m3:     .string "March"
m4:     .string "April"
m5:     .string "May"
m6:     .string "June"
m7:     .string "July"
m8:     .string "August"
m9:     .string "September"
m10:    .string "October"
m11:    .string "November"
m12:    .string "December"

//----------[suffix]----------//
fst:    .string "st"
scd:    .string "nd"
thr:    .string "rd"
oth:    .string "th"

//----------[season]----------//
win_m:    .string "Winter"
spr_m:    .string "Spring"
sum_m:    .string "Summer"
fal_m:    .string "Fall"

//----------[errors and result]----------//
usageS:     .string "usage: a5b mm dd\n"                //Error written if arguments are missing
invalidS:   .string "error: an argument was invalid\n"  //Error if an argument is invalid
resultS:    .string "%s %d%s is %s\n"                   //Final print statement

        .data
        .balign 8

month_m:    .dword  m1,m2,m3,m4,m5,m6,m7,m8,m9,m10,m11,m12  //Month array 
suffix_m:   .dword  fst,    scd,    thr,    oth             //Suffix array
season_m:   .dword  win_m,  spr_m,  sum_m,  fal_m           //Season array

        .text
        .balign 4
        .global main

	fp	.req	x29		//Replaces x29/x30 with something more readable
	lr	.req	x30

main:
	stp	fp,	lr,	[sp, -16]!  //Allocates memory
	mov	fp,	sp              //Updates the fp

    mov argc_r, w0  //Saves the number of arguments given
    mov argv_r, x1  //Saves the array of pointers to the arguments provided

//arg check
    cmp     argc_r, 3   //Checks if 3 arguments were provided
    b.eq    skipArg     //If so skip the usage error

    adrp    x0, usageS              //Prints the usage error
    add     x0, x0, :lo12:usageS
    bl      printf
    b       end                     //Goes to the end of the program

//string conversion
skipArg:
    mov w9, 1                       //w9 = 1
    ldr x0, [argv_r, w9, SXTW 3]    //Load 1st arg
    bl  atoi                        //String -> Int
    mov month_r, w0                 //Save the month

    mov w9, 2                       //w9 = 2
    ldr x0, [argv_r, w9, SXTW 3]    //Load the 2nd arg
    bl  atoi                        //String -> Int
    mov day_r, w0                   //Save the day

//error check
    cmp     month_r,    wzr     //Checks if the month <= 0
    b.le    error
    cmp     month_r,    12      //Checks if the month > 12
    b.gt    error               //Either would branch to the error statement

//check day
    cmp     day_r,      wzr     //Checks if the day <= 0
    b.le    error
    cmp     day_r,      31      //Checks if the day > 31
    b.gt    error               //Either would branch to the error statement

//anomalies
    cmp     month_r,    2   //Checks if month is February
    b.ne    skipFeb         //If not Feb, skip it
    cmp     day_r,      28  //If it is Feb, check if day > 28
    b.gt    error           //If so branch to the error statement
    b       janJune         //We know it's Feb, skip through the rest

skipFeb:
    cmp     month_r,    4   //April
    b.eq    day30
    cmp     month_r,    6   //June
    b.eq    day30
    cmp     month_r,    9   //Sept
    b.eq    day30
    cmp     month_r,    11  //Nov
    b.eq    day30           //All checks for day 30 months
    b       skipError       //Otherwise error checking complete

day30:
    cmp     day_r,  30      //Checks if day <= 30
    b.le    skipError       //If so skip the error

error:
    adrp    x0, invalidS            //Invalid arguments were provided
    add     x0, x0, :lo12:invalidS
    bl      printf
    b       end                     //Goes to the end of the program

skipError:
//month finder
    cmp     month_r,    7   //Halves the months
    b.ge    julDec          //If month >= 7 branch to July - Dec

janJune:
    cmp     month_r,    4   //Halves the months of the first 6 months
    b.ge    aprJun          //If month >= 4 branch to Apr - Jun

    mov     season_r,   0   //We can assume it's winter
    cmp     month_r,    3   //...unless it's March
    b.eq    march           //If so, branch to March
    b       findSuffix      //Otherwise branch to find suffix

march:
    cmp     day_r,      20  //If day <= 20
    b.le    findSuffix      //It's winter
    mov     season_r,   1   //Otherwise it's spring
    b       findSuffix      //Branch to the suffix

aprJun:
    mov     season_r,   1   //Assume it's spring
    cmp     month_r,    6   //Unless it's June
    b.eq    june            //If so brnach to June
    b       findSuffix      //Branch to the suffix

june:
    cmp     day_r,      20  //If day <= 20
    b.le    findSuffix      //It's spring
    mov     season_r,   2   //Otherwise it's summer
    b       findSuffix      //Branch to the suffix

julDec:                     //Second half of the months
    cmp     month_r,    10  //Check if it's after October
    b.ge    octDec          //If so branch to Oct - Dec

    mov     season_r,   2   //We can assume it's summmer
    cmp     month_r,    9   //Unless it's Sept
    b.eq    sept            //If so branch to Sept
    b       findSuffix      //Otherwise branch to suffix

sept:
    cmp     day_r,      20  //If day <= 20, it's summer
    b.le    findSuffix      //Branch to the suffix
    mov     season_r,   3   //Otherwise, it's fall
    b       findSuffix      //Branch to find the suffix

octDec:
    mov     season_r,   3   //Assume it's  fall
    cmp     month_r,    12  //Unless it's Dec
    b.eq    dec             //If so branch to Dec
    b       findSuffix      //Branch to the suffix

dec:
    cmp     day_r,      20  //If day <= 20, it's fall
    b.le    findSuffix      //Branch to the suffix
    mov     season_r,   0   //Otherwise it's winter

//Suffix check
findSuffix:
    cmp     day_r,  1   //Check if day ends with a 1
    b.eq    stB
    cmp     day_r,  21
    b.eq    stB
    cmp     day_r,  31
    b.eq    stB

    cmp     day_r,  2
    b.eq    ndB
    cmp     day_r,  22
    b.eq    ndB

    cmp     day_r,  3
    b.eq    rdB
    cmp     day_r,  23
    b.eq    rdB

    mov     suffix_r,   3   //Otherwise it's "th"
    b       output          //Branch to output

stB:
    mov suffix_r,   0   //"st" suffix
    b   output
ndB:
    mov suffix_r,   1   //"nd" suffix
    b   output
rdB:
    mov suffix_r,   2   //"rd" suffix

//Printing the result
output:
    adrp    month_base_r,   month_m                         //Calc base address
    add     month_base_r,   month_base_r,   :lo12:month_m   //Format bits

    adrp    season_base_r,   season_m                           //Calc base address
    add     season_base_r,   season_base_r,   :lo12:season_m    //Format bits

    adrp    suffix_base_r,   suffix_m                           //Calc base address
    add     suffix_base_r,   suffix_base_r,   :lo12:suffix_m    //Format bits

    sub     month_r,    month_r,    1               //Counting starts at 0
    
    adrp    x0, resultS                             //Base address of result string
    add     x0, x0, :lo12:resultS                   //Format the bits
    ldr     x1, [month_base_r, month_r, SXTW 3]     //Add the month base address with the offset
    mov     w2, day_r                               //Add the day as it is
    ldr     x3, [suffix_base_r, suffix_r, SXTW 3]   //Add the suffix base address with the offset
    ldr     x4, [season_base_r, season_r, SXTW 3]   //Add the season base address with the offset
    bl      printf                                  //Print!

end:
    mov w0, 0               //Return 0 int
	ldp	fp,	lr,	[sp],	16  //Deallocate
	ret                     //Return