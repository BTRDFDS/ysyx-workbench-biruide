ENTRY(_start)
MEMORY {
	flash	: ORIGIN = 0x30000000, LENGTH = 16M
	mrom	: ORIGIN = 0x20000000, LENGTH = 4K
	sram	: ORIGIN = 0x0f000000, LENGTH = 8K
	psram	: ORIGIN = 0x80000000, LENGTH = 16M
}
SECTIONS{
	. = ORIGIN(flash);

	.text : {
		*(entry)
		*(.text*)
	} > flash AT> flash
	.rodata : {
		*(.rodata*)
	} > flash AT> flash

	.data : {
		*(.data*)
		*(.sdata*)
		} > sram AT> flash
    PROVIDE(_data_start_ = ADDR(.data));
    PROVIDE(_data_size_ = SIZEOF(.data));
    PROVIDE(_data_begin_ = LOADADDR(.data));

	.bss : {
		*(.bss*)
		*(.sbss*)
		*(.scommon)
		} > sram
	PROVIDE(_bss_start_	= ADDR(.bss));
	PROVIDE(_bss_size_	= SIZEOF(.bss));
	_stack_pointer = ORIGIN(sram) + LENGTH(sram);

	PROVIDE(_heap_start	= ORIGIN(psram));
	PROVIDE(_heap_end	= ORIGIN(psram) + LENGTH(psram));
}