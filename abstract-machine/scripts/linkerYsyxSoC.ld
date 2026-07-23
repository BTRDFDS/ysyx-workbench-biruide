ENTRY(_start)
MEMORY {
	flash	: ORIGIN = 0x30000000, LENGTH = 16M
	mrom	: ORIGIN = 0x20000000, LENGTH = 4K
	sram	: ORIGIN = 0x0f000000, LENGTH = 8K
	psram	: ORIGIN = 0x80000000, LENGTH = 16M
}
SECTIONS{
	. = ORIGIN(flash);

	. = ALIGN(0x4);
	.boot : {
		*(entry)
		*(.text._trm_init)
	} > flash AT> flash

	. = ALIGN(0x4);
	.load : {
		*(.text._bootloader)
	} > psram AT> flash
	PROVIDE(_load_start_ = ADDR(.load));
	PROVIDE(_load_size_ = SIZEOF(.load));
	PROVIDE(_load_begin_ = LOADADDR(.load));

	. = ALIGN(0x4);
	.data : {
		*(.text*)
		*(.rodata*)
		*(.data*)
		*(.sdata*)
		} > psram AT> flash
    PROVIDE(_data_start_ = ADDR(.data));
    PROVIDE(_data_size_ = SIZEOF(.data));
    PROVIDE(_data_begin_ = LOADADDR(.data));
	
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