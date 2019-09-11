# Tier 1 Test file
# Updated 12/11 so that the branch actually branches
# Fixed AGAIN so it doesn't branch eternally.
# Add the following to the initial block of your data memory:
# dataMemory[6] <= 32'd42;
# And be sure that reg 0 = 0
 lw $1, 6($0)
 add $2, $1, $1
 sub $3, $2, $1
# This branch should execute once
 beq $1, $1, 1
# Useless instruction that gets skipped
 sub $3, $3, $3
 sw $2, 7($0)
