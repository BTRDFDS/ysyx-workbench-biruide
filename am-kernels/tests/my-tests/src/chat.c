#define UART_BASE 0x10000000L
#define UART_TX   0
void main() {
  // *(volatile char *)(UART_BASE + UART_TX) = '\0';
  *(volatile char *)(UART_BASE + UART_TX) = 'A';
  *(volatile char *)(UART_BASE + UART_TX) = 'B';
  // *(volatile char *)(UART_BASE + UART_TX) = 'C';
  // *(volatile char *)(UART_BASE + UART_TX) = 'A';
  // *(volatile char *)(UART_BASE + UART_TX) = 'B';
  // *(volatile char *)(UART_BASE + UART_TX) = 'C';
  // *(volatile char *)(UART_BASE + UART_TX) = 'A';
  // *(volatile char *)(UART_BASE + UART_TX) = 'B';
  // *(volatile char *)(UART_BASE + UART_TX) = 'C';
//   *(volatile char *)(UART_BASE + UART_TX) = '\n';
  asm("ebreak");
  // while (1);
}