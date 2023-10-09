.data
    # dword -> 8 bytes
    # word -> 4 bytes
    test_1: .word 0x40200000, 0x40200000 # 2.5 * 2.5 = 6.25
    test_2: .word 0x3e800000, 0x40800000 # 0.25 * 4 = 1
    test_3: .word 0xc0600000, 0x417a0000 # -3.5 * 15.625 = -54.6875
    msg_string: .string "floating point multiplication \n"
    enter: .string "\n"

.text
main:
    addi sp, sp, -12
    
    # push pointers of test data onto the stack
    la t0, test_1
    sw t0, 0(sp)
    la t0, test_2
    sw t0, 4(sp)
    la t0, test_3
    sw t0, 8(sp)
 
    # initialize main_loop
    addi s0, zero, 3    # s0 : number of test case
    addi s1, zero, 0    # s1 : test case counter
    mv s2, sp           # s2 : points to test_1

main_loop:
    la a0, msg_string
    li a7, 4            # print string
    ecall
    
    lw a0, 0(s2)        # a0 : pointer to first test data 
    lw a1, 4(a0)        # a1 : second data in test data
    lw a0, 0(a0)        # a0 : first data in test data  
    
    jal fmul32          # a0 : result of fmul32
    
    # print the result 
    li a7, 2            # print float
    ecall               # print result
    la a0, enter
    li a7, 4
    ecall                #print next line
    
    addi s2, s2, 4      # s2 : points to next test_data
    addi s1, s1, 1      # counter++
    bne s1, s0, main_loop
    
    addi sp, sp, 12
    li a7, 10
    ecall


# mask_lowest_zero test
# main:   
#     la t0, test_1 # lui t0, test_1[31:12]  # lw t0, test_1[11:0]
#     lw a0, 0(t0) 
#     lw a1, 4(t0)
#     jal mask_lowest_zero
#     li       a7,  10           # return 0
# 	ecall

# inc test
# main:   
#     la s0, test_1 # lui t0, test_1[31:12]  # lw t0, test_1[11:0]
#     lw a0, 0(s0) 
#     lw a1, 4(s0)
#     jal inc
#     li       a7,  10           # return 0
# 	ecall

# getbit test
# main:   
#     la s0, test_1 # lui t0, test_1[31:12]  # lw t0, test_1[11:0]
#     lw a0, 0(s0) 
#     lw a1, 4(s0)
#     li a2, 2
#     jal getbit
#     li       a7,  10           # return 0
# 	ecall

# imul32 test
# main:   
#     la s0, test_1 # lui t0, test_1[31:12]  # lw t0, test_1[11:0]
#     lw a0, 0(s0) 
#     lw a1, 4(s0)
#     jal imul32
#     li       a7,  10           # return 0
# 	ecall

# fmul32 test
# main:   
#     la s0, test_1 # lui t0, test_1[31:12]  # lw t0, test_1[11:0]
#     lw a0, 0(s0) 
#     lw a1, 4(s0)
#     jal fmul32
#     li       a7,  10           # return 0
# 	ecall

fmul32:
    addi sp, sp, -24
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)

    srli s0, a0, 31
    srli s1, a1, 31
    xor s0, s0, s1  # s0 = sign_a ^ sign_b -> sign bit

    li t0, 0x7FFFFF
    li t1, 0x800000
    and s1, a0, t0
    or s1, s1, t1   # s1 = mantissa_a  
    and s2, a1, t0  
    or s2, s2, t1   # s2 = mantissa_b

    srli s3, a0, 23
    andi s3, s3, 0xFF # s3 = exp_a
    srli s4, a1, 23
    andi s4, s4, 0xFF # s4 = exp_b

    mv a0, s1
    mv a1, s2
    jal imul32
    mv s1, a0
    mv s2, a1        # s1,s2 = mantissa_a * mantissa_b
    srli s1, s1, 23
    slli s2, s2, 9
    or s1, s1, s2   # s1 = mantissa_a * mantissa_b >> 23
                     # s2 dont care
    mv a0, s1        # a0 = mantissa_a * mantissa_b >> 23
    li a2, 24        # a1 = 24
    jal getbit
    srl s1, s1, a0   # s1 = mantissa_a * mantissa_b >> 23 >> getbit

    add s3, s3, s4   # s3 = exp_a + exp_b
    addi s3, s3, -127
                     # s4 dont care
    # int32_t er = mshift ? inc(ertmp) : ertmp;
    # skip inc
    add s3, s3, a0   # s3 = er

    slli s0, s0, 31 # s0 = (sr << 31)
    andi s3, s3, 0xFF # s3 = er
    slli s3, s3, 23 # s3 = er << 23
    li t0, 0x7FFFFF
    and s1, s1, t0  # s1 = mr
    or s0, s0, s3   # s0 = (sr << 31) | (er << 23)
    or s0, s0, s1   # s0 = (sr << 31) | (er << 23) | mr
    mv a0, s0

    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    addi sp, sp, 24
    ret

imul32:
    addi sp, sp, -28
    sw ra,0(sp)
    sw s0,4(sp)
    sw s1,8(sp)
    sw s2,12(sp)
    sw s3,16(sp)
    sw s4,20(sp)
    sw s5,24(sp)
    mv s0, a0   # a
    mv s1, a1   # b
    li s2, 0   
    li s3, 0    # result s3,s2 
    li s4, 0    # i counter
    li s5, 32   # loop bound
imul32_loop:
    beq s4, s5, imul32_end
    mv a0, a1   # a0 = b
                # a1 dont care
    mv a2, s4   # a2 = i
    jal getbit
    beq a0, zero, imul_skip # if (getbit(b, i))
    sub t2, s5, s4  # t2 = 32 - i 
    mv t0, s0       # t0 = a
    srl t1, t0, t2  # shift left i
    sll t0, t0, s4  # shift left i

    slli t3, s2, 31 # overflow check
    slli t4, t0, 31 # overflow check
    and t5, t3, t4  # overflow check
    beq t5, zero, 8   # if (overflow)
    addi s3, s3, 1  # result++
    add s2, s2, t0  
    add s3, s3, t1  # r += a << i
imul_skip:
    addi s4, s4, 1  # i++
    j imul32_loop

imul32_end:
    mv a0, s2
    mv a1, s3
    lw ra,0(sp)
    lw s0,4(sp)
    lw s1,8(sp)
    lw s2,12(sp)
    lw s3,16(sp)
    lw s4,20(sp)
    lw s5,24(sp)
    addi sp,sp,28
    ret


getbit:
    addi sp, sp, -8
    sw ra, 0(sp)
    sw s0, 4(sp)
    li s0, 32

    bge a2, s0, getbit_l        # if (pos >= 32);
    srl a0, a0, a2
    andi a0, a0, 1
    j getbit_end
getbit_l:
    sub s0, a2, s0   
    srl a1, a1, s0
    andi a1, a1, 1
    mv a0, a1
getbit_end:
    lw ra, 0(sp)
    lw s0, 4(sp)
    addi sp, sp, 8
    ret

inc:
    addi sp, sp -12
    sw ra, 0(sp)
    sw a0, 4(sp)
    sw a1, 8(sp)     # save parameters

    jal mask_lowest_zero
    mv t0, a0
    mv t1, a1        # t1,t0 mask
    
    lw a0, 4(sp)
    lw a1, 8(sp)     # restore parameters
    
    slli t3, t1, 1
    srli t2, t0, 31
    or t3, t3, t2
    slli t2, t0, 1    # a1,a0 << 1
    ori t2, t2, 1      # a1,a0 | 1

    xor t2, t2, t0
    xor t3, t3, t1    #  t2,t3  z1

    not t1, t1
    not t0, t0         # ~mask       

    and a1, a1, t1
    and a0, a0, t0    # a1,a0 & ~mask

    or a1, a1, t3
    or a0, a0, t2     # a1,a0 | z1

    lw ra, 0(sp)
    addi sp, sp, 12
    ret 


mask_lowest_zero:
    addi sp, sp, -4
    sw ra, 0(sp)
    # a0 low , a1 high 
    # mask &= (mask << 1) | 1;
    # a1,a0 = 64 bits parameter 
    slli t1, a1, 1
    srli t0, a0, 31
    or t1, t1, t0     # t1,t0 
    slli t0, a0, 1    # t0 = a0 << 1
    ori t0, t0, 1     # x = x | 1

    and a0, a0, t0
    and a1, a1, t1

    # mask &= (mask << 2) | 0x3;
    slli t1, a1, 2
    srli t0, a0, 30
    or t1, t1, t0     # left  32 bits
    slli t0, a0, 2    # t0 = a0 << 2
    ori t0, t0, 3     # x = x | 3

    and a0, a0, t0
    and a1, a1, t1

    # mask &= (mask << 4) | 0xF;
    slli t1, a1, 4
    srli t0, a0, 28
    or t1, t1, t0     # left  32 bits
    slli t0, a0, 4    # t0 = a0 << 4
    ori t0, t0, 0xF   # x = x | 0xF

    and a0, a0, t0
    and a1, a1, t1

    # mask &= (mask << 8) | 0xFF;
    slli t1, a1, 8
    srli t0, a0, 24
    or t1, t1, t0     # left  32 bits
    slli t0, a0, 8    # t0 = a0 << 8
    ori t0, t0, 0xFF  # x = x | 0xFF

    and a0, a0, t0
    and a1, a1, t1

    # mask &= (mask << 16) | 0xFFFF;
    li t3 , 0xFFFF # lui + addi
    slli t1, a1, 16
    srli t0, a0, 16
    or t1, t1, t0     # left  32 bits
    slli t0, a0, 16   # t0 = a0 << 16
    or t0, t0, t3    # x = x | 0xFFFF

    and a0, a0, t0
    and a1, a1, t1

    # mask &= (mask << 32) | 0xFFFFFFFF;
    and a1, a1,a0

    lw ra, 0(sp)
    addi sp, sp, 4
    ret
    
    