# Tier 3 Test Program
# Be sure $0 = 0.
# This should calculate n*(n+1) for whatever immediate value is
# in the first instruction.
# Initialize $1 with the value of n
 addiu $1, $0, 5
# Calculate n+1
 addi $2, $1, 1
# Calculate n*(n+1)
# First, copy n from $1 to $6 as a counter.
 andi $6, $1, 255
# Subtract 1
 addi $6, $6, -1
# Initialize first partial product
 addiu $4, $2, 0
# Add $2 to $4 as another partial product
 add $4, $4, $2
# Decrement the counter
 addi $6, $6, -1
# Compare the count to 0 and loop back to add $4, $4, $2
 bne $0, $6, -3
# Store the result
 sw $4, 4($0)
