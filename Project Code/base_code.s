# final code boys lets go
# This code is base implementation:
# Using sub instead of addi for -1
# delay of 20ms split up into 10ms each
# addi 25 in the middle to see if delay is working appropriately

# initializing all servos to 0
addi $1, $0, 0
addi $2, $0, 0
addi $3, $0, 98
addi $4, $0, 0
addi $5, $0, 0

addi $20, $0, 98 #load 98 into r20 for comparison later
addi $21, $0, 1 #load 1 into r21 for comparison later

#decoding all values from r7 and r8
#r10 <- LS1 - Up
#r11 <- LS1 - Down
#r12 <- LS1 - Left
#r13 <- LS1 - Right
#r14 <- LS2 - Up
#r15 <- LS2 - Down
#r16 <- LS2 - Left
#r17 <- LS2 - Right

#all values are decoded into their specific registers
start:
sll $10, $7, 31
sra $10, $10, 31

sll $11, $7, 30
sra $11, $11, 31

sll $12, $7, 29
sra $12, $12, 31

sll $13, $7, 28
sra $13, $13, 31

sll $14, $8, 31
sra $14, $14, 31

sll $15, $8, 30
sra $15, $15, 31

sll $16, $8, 29
sra $16, $16, 31

sll $17, $8, 28
sra $17, $17, 31


check_1:
bne $10, $0, check_2 #if not equal to 0, go to check_2
blt $20, $1, check_2 #if 98 < duty cycle, then go to check_2
addi $1, $1, 1

check_2:
bne $11, $0, check_3 #if not equal to 0, go to check_3
blt $1, $21, check_3 #if duty cycle < 1, go to check 3
sub $1, $1, $21

check_3:
bne $12, $0, check_4 #if not equal to 0, go to check_4
blt $20, $2, check_4 #if 98 < duty cycle, then go to check_4
addi $2, $2, 1

check_4:
bne $13, $0, check_5 #if not equal to 0, go to check_5
blt $2, $21, check_5 #if duty cycle < 1, go to check_5
sub $2, $2, $21

check_5:
bne $14, $0, check_6 #if not equal to 0, go to check_6
blt $20, $3, check_6 #if 98 < duty cycle, then go to check_6
addi $3, $3, 1

check_6:
bne $15, $0, check_7 #if not equal to 0, go to check_7
blt $3, $21, check_7 #if duty cycle < 1, go to check_7
sub $3, $3, $21

check_7:
bne $16, $0, check_8 #if not equal to 0, go to check_8
blt $20, $4, check_8 #if 98 < duty cycle, then go to check_8
addi $4, $4, 1

check_8:
bne $17, $0, delay #if not equal to 0, go to start
blt $4, $21, delay #if duty cycle < 1, go to start
sub $4, $4, $21

delay:
addi $25, $25, 1
nop
nop
nop
nop
nop
nop #delay of 10ms
nop
nop
nop
nop
nop
addi $25, $25, 0
nop
nop
nop
nop
nop
nop #delay of 10ms
nop
nop
nop
nop
nop
j start
nop
nop
nop
nop
nop
