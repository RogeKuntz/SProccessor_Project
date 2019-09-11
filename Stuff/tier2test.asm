# Tier 2 Test file
# Updated 12/11 to fix a couple of silly mistakes.
# Add the following to the initial block of your data memory:
# Be sure that reg 0 = 0
 addi $1, $0, 42
 addi $3, $0, 6
 j 4
# This instruction shouldn't execute
 add $2, $1, $1
 sub $5, $1, $3
 addi $6, $0, 36
# This branch should execute once
 beq $6, $5, 1
# This instruction shouldn't execute
 sw $2, 7($0)
 sw $5, 1($0)
