ENTRY(_start)
MEMORY {
	flash	: ORIGIN = 0x30000000, LENGTH = 16M
	mrom	: ORIGIN = 0x20000000, LENGTH = 4K
	sram	: ORIGIN = 0x0f000000, LENGTH = 8K
	psram	: ORIGIN = 0x80000000, LENGTH = 16M
}
SECTIONS{
	_flash_lma = ORIGIN(flash);
	.boot : AT(_flash_lma){
		. = ALIGN(0x4);
		*(entry)
		*(.text._trm_init)
		. = ALIGN(0x4);
	} > flash 
	_flash_lma = _flash_lma + SIZEOF(.boot);
	_flash_lma = ALIGN(_flash_lma, 0x4);

	.load : AT(_flash_lma){
		*(.text._bootloader)
	} > psram 
	PROVIDE(_load_start_ = ADDR(.load));
	PROVIDE(_load_size_ = SIZEOF(.load));
	PROVIDE(_load_begin_ = LOADADDR(.load));
	_flash_lma = _flash_lma + SIZEOF(.load);
	_flash_lma = ALIGN(_flash_lma, 0x4);

	.data : AT(_flash_lma){
		*(.text*)
		*(.rodata*)
		*(.srodata*)
		*(.data*)
		*(.sdata*)
		} > psram 
    PROVIDE(_data_start_ = ADDR(.data));
    PROVIDE(_data_size_ = SIZEOF(.data));
    PROVIDE(_data_begin_ = LOADADDR(.data));
	_flash_lma = _flash_lma + SIZEOF(.data);
	_flash_lma = ALIGN(_flash_lma, 0x4);

	. = ALIGN(0x4);
	.bss : {
		*(.bss*)
		*(.sbss*)
		*(.scommon)
	} > psram

	PROVIDE(_bss_start_	= ADDR(.bss));
	PROVIDE(_bss_size_	= SIZEOF(.bss));

	. = ALIGN(0x1000);
	PROVIDE(_heap_start	= .);
	PROVIDE(_heap_end	= ORIGIN(psram) + LENGTH(psram));

	_stack_pointer = ORIGIN(sram) + LENGTH(sram);

}