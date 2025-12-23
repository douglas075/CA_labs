        .globl  __start

        .rodata
msg:
        .asciiz "Empty!"
newline:
        .asciiz "\n"
        .text

push_front_list:
# a0 sp, a1 value
### save ra、s0 ###
        addi    sp, sp, -16
        sw      ra, 12(sp)
        sw      s0, 8(sp)
        sw      s1, 4(sp)
        mv      s1, a1                  # s1 value
        mv      s0, a0                  # s0 head
### if(list == NULL)return; ###
        beqz    a0, LBB0_2
### node_t *new_node = (node_t*)sbrk(sizeof(*new_node)); ###
        li      a0, 8
        call    sbrk                    # a0 *cur
### new_node->value = value; ###
        sw      s1, 0(a0)
### new_node->next = list->head; ###
        lw      a1, 0(s0)
        sw      a1, 4(a0)
### list->head = new_node; ###
        sw      a0, 0(s0)
LBB0_2:
### exit handling ###
        lw      ra, 12(sp)
        lw      s0, 8(sp)
        lw      s1, 4(sp)
        addi    sp, sp, 16
        ret

print_list:
# about space
############################################
# TODO: Print out the linked list #
# #
# arg: a0 head
        addi    sp, sp, -16
        sw      ra, 12(sp)
        sw      s0, 8(sp)

        mv      s0, a0
        lw      a0, 4(s0)
## if next is null
        beqz    a0, print_list_epilogue

# recursive call
        call    print_list

print_list_epilogue:
# print value in s0
        lw      a0, 0(s0)
        call    print_int
        lw      ra, 12(sp)
        lw      s0, 8(sp)
        addi    sp, sp, 16
        ret
############################################



############################################
# TODO: Sort the linked list #
# s0: unsorted, s1: sorted, s2: unsorted->next, s3: unsorted->value
sort_list:
        addi    sp, sp, -16
        sw      ra, 12(sp)
        sw      s0, 8(sp)
        sw      s1, 4(sp)

        mv      s1, x0                  # sorted = NULL
        mv      s0, a0                  # s0 = head (current)

sort_loop:
        beqz    s0, sort_done
        lw      s2, 4(s0)               # unsorted_head->next

        beqz    s1, insert_front
        lw      s3, 0(s0)               # unsorted_head->value
        lw      t0, 0(s1)               # sorted->value
        blt     s3, t0, insert_front

        mv      t0, s1                  # cur = sorted
find_place:
        lw      t1, 4(t0)               # cur->next
        beqz    t1, insert_here
        lw      t2, 0(t1)               # cur->next->value
        bge     t2, s3, insert_here     
        mv      t0, t1                  # cur = cur->next
        j       find_place

insert_here:
        # t0 cur, t1 cur->next
        # s0: unsorted, s1: sorted, s2: unsorted->next, s3: unsorted->value
        # use s0 to ref inserted node
        sw      s0, 4(t0)
        sw      t1, 4(s0)
        j       advance

insert_front:
        sw      s1, 4(s0)
        mv      s1, s0
advance:
        mv      s0, s2                  # move to next original node
        j       sort_loop

sort_done:
        mv      a0, s1

        lw      ra, 12(sp)
        lw      s0, 8(sp)
        lw      s1, 4(sp)
        addi    sp, sp, 16
        ret


############################################

__start:
### save ra、s0 ###
        addi    sp, sp, -16
        sw      ra, 12(sp)
        sw      s0, 8(sp)
### read the numbers of the linked list ###
        call    read_int
### if(nums == 0) output "Empty!" ###
        beqz    a0, LBB2_2
### if(nums <= 0) exit
        mv      s0, a0
        blez    a0, exit
LBB2_1:
        call    read_int
### set push_front_list argument ###
        mv      a1, a0                  # a1: int read
        mv      a0, sp
        call    push_front_list
        addi    s0, s0, -1
        bnez    s0, LBB2_1
        lw      a0, 0(sp)
        j       LBB2_3
LBB2_2:
        call    print_str
        j       exit
LBB2_3:
        mv      s0, a0
        call    print_list
        call    print_newline
        mv      a0, s0
        call    sort_list # return sorted head in a0
        sw      a0, 0(sp)
        # mv      a0, s0
        call    print_list
exit:
### exit handling ###
        li      a0, 0
        lw      ra, 12(sp)
        lw      s0, 8(sp)
        addi    sp, sp, 16
        li      a0, 10
        ecall

read_int:
        li      a0, 5
        ecall
        jr      ra

sbrk:
        mv      a1, a0
        li      a0, 9
        ecall
        jr      ra

print_int:
        mv      a1, a0
        li      a0, 1
        ecall
        li      a0, 11
        li      a1, ' '
        ecall
        jr      ra

print_str:
        li      a0, 4
        la      a1, msg
        ecall
        jr      ra

print_newline:
        li      a0, 4
        la      a1, newline
        ecall
        jr      ra
