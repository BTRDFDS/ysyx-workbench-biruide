ENTRY(_start)
MEMORY {
	mrom : ORIGIN = 0x20000000, LENGTH = 4K
	sram : ORIGIN = 0x0f000000, LENGTH = 8K
}
SECTIONS{
	. = ORIGIN(mrom);

	.text : {
		*(entry)
		*(.text*)
	} > mrom AT> mrom
	.rodata : {
		*(.rodata*)
	} > mrom AT> mrom

	.data : {*(.data*)} > sram AT> mrom
    PROVIDE(_data_start_ = ADDR(.data));
    PROVIDE(_data_size_ = SIZEOF(.data));
    PROVIDE(_data_begin_ = LOADADDR(.data));

	.bss : {*(.bss*)} > sram

	_stack_pointer = ORIGIN(sram) + LENGTH(sram);
}