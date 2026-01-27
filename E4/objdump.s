0000000000000000 <main>:
       0: 79 71         addi    sp, sp, -48
       2: 06 f4         sd      ra, 40(sp)
       4: 22 f0         sd      s0, 32(sp)
       6: 00 18         addi    s0, sp, 48
       8: 01 45         li      a0, 0
       a: 23 3c a4 fc   sd      a0, -40(s0)
       e: 23 26 a4 fe   sw      a0, -20(s0)
      12: 29 45         li      a0, 10
      14: 23 24 a4 fe   sw      a0, -24(s0)
      18: 51 45         li      a0, 20
      1a: 23 22 a4 fe   sw      a0, -28(s0)
      1e: 03 25 84 fe   lw      a0, -24(s0)
      22: 83 25 44 fe   lw      a1, -28(s0)
      26: 2d 9d         addw    a0, a0, a1
      28: 23 20 a4 fe   sw      a0, -32(s0)
      2c: 83 25 04 fe   lw      a1, -32(s0)

0000000000000030 <.LBB0_1>:
      30: 17 05 00 00   auipc   a0, 0
      34: 13 05 05 00   mv      a0, a0
      38: 97 00 00 00   auipc   ra, 0
      3c: e7 80 00 00   jalr    ra
      40: 03 35 84 fd   ld      a0, -40(s0)
      44: a2 70         ld      ra, 40(sp)
      46: 02 74         ld      s0, 32(sp)
      48: 45 61         addi    sp, sp, 48
      4a: 82 80         ret