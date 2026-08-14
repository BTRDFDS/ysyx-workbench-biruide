int main() {
    asm volatile ("la t0, 1f");
    asm volatile ("li t1, 0x00000513");
    asm volatile ("sw t1, 0(t0)");
    asm volatile ("fence.i");
    asm volatile ("1: li a0, 20");
    asm volatile ("ebreak");
    return 0;
}