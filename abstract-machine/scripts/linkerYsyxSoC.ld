ENTRY(_start)
MEMORY {
	flash	: ORIGIN = 0x30000000, LENGTH = 16M
	mrom	: ORIGIN = 0x20000000, LENGTH = 4K
	sram	: ORIGIN = 0x0f000000, LENGTH = 8K
	psram	: ORIGIN = 0x80000000, LENGTH = 16M
}
SECTIONS{
	. = ORIGIN(flash);

	.boot : {
		*(entry)
		*(.text._trm_init)
	} > flash AT> flash
	.load : {
		*(.text._bootloader)
	} > psram AT> flash
	PROVIDE(_load_start_ = ADDR(.load));
	PROVIDE(_load_size_ = SIZEOF(.load));
	PROVIDE(_load_begin_ = LOADADDR(.load));

	.data : {
		*(.text*)
		*(.rodata*)
		*(.data*)
		*(.sdata*)
		} > psram AT> flash
    PROVIDE(_data_start_ = ADDR(.data));
    PROVIDE(_data_size_ = SIZEOF(.data));
    PROVIDE(_data_begin_ = LOADADDR(.data));

	.bss : {
		*(.bss*)
		*(.sbss*)
		*(.scommon)
		} > psram
	PROVIDE(_bss_start_	= ADDR(.bss));
	PROVIDE(_bss_size_	= SIZEOF(.bss));
	_stack_pointer = ORIGIN(psram) + LENGTH(psram);

	PROVIDE(_heap_start	= ORIGIN(psram) + _load_size_ + _data_start_ + _bss_size_);
	PROVIDE(_heap_end	= ORIGIN(psram) + LENGTH(psram));
}