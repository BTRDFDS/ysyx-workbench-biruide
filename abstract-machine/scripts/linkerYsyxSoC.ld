ENTRY(_start)

SECTIONS
{
 . = 0x20000000;

  .text : {
    *(entry)
    *(.text*)
  }

  .rodata : {
    *(.rodata*)
  }
  _stack_pointer = 0x0f002000;
}