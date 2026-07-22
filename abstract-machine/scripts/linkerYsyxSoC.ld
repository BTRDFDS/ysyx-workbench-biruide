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
	.text : {
		*(.text*)
	} > psram AT> flash
	PROVIDE(_text_start_ = ADDR(.text));
	PROVIDE(_text_size_ = SIZEOF(.text));
	PROVIDE(_text_begin_ = LOADADDR(.text));

	.data : {
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

	PROVIDE(_heap_start	= ORIGIN(psram) + _text_size_ + _data_size_ + _bss_size_);
	PROVIDE(_heap_end	= ORIGIN(psram) + LENGTH(psram));
}