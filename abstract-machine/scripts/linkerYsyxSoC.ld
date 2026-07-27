ENTRY(_start)
MEMORY {
	flash	: ORIGIN = 0x30000000, LENGTH = 16M
	mrom	: ORIGIN = 0x20000000, LENGTH = 4K
	sram	: ORIGIN = 0x0f000000, LENGTH = 8K
	psram	: ORIGIN = 0x80000000, LENGTH = 16M
	sdram	: ORIGIN = 0xa0000000, LENGTH = 128M
}
SECTIONS{
	_lma = ORIGIN(flash);
	.boot : AT(_lma){
		. = ALIGN(0x4);
		*(entry)
		*(.text._trm_init)
		. = ALIGN(0x4);
	} > flash 
	_lma = _lma + SIZEOF(.boot);
	_lma = ALIGN(_lma, 0x4);

	.load : AT(_lma){
		*(.text._bootloader)
	} > sram 
	PROVIDE(_load_start_ = ADDR(.load));
	PROVIDE(_load_size_ = SIZEOF(.load));
	PROVIDE(_load_begin_ = LOADADDR(.load));
	_lma = _lma + SIZEOF(.load);
	_lma = ALIGN(_lma, 0x4);

	.imag : AT(_lma){/*image*/
		*(.text*)
		*(.rodata*)
		*(.srodata*)
		*(.data*)
		*(.sdata*)
		
		/* rt-thread */
			. = ALIGN(8);
			__fsymtab_start = .;
			KEEP(*(FSymTab))
			__fsymtab_end = .;
			. = ALIGN(8);
			__vsymtab_start = .;
			KEEP(*(VSymTab))
			__vsymtab_end = .;
			. = ALIGN(8);
			__rt_init_start = .;
			KEEP(*(SORT(.rti_fn*)))
			__rt_init_end = .;
			. = ALIGN(8);

			__rt_utest_tc_tab_start = .;
			KEEP(*(UtestTcTab))
			__rt_utest_tc_tab_end = .;

			. = ALIGN(8);
			__am_apps_data_start = .;
			*(__am_apps.data*)
			*(__am_apps.sdata*)
			__am_apps_data_end = .;
			. = ALIGN(8);
		/* rt-thread */
	} > sdram 
	PROVIDE(_imag_start_ = ADDR(.imag));
	PROVIDE(_imag_size_	 = SIZEOF(.imag));
	PROVIDE(_imag_begin_ = LOADADDR(.imag));
	_lma = _lma + SIZEOF(.imag);
	_lma = ALIGN(_lma, 0x4);

	.base : {
		. = ALIGN(0x4);
		*(.bss*)
		*(.sbss*)
		*(.scommon)
		/* rt-thread */
			. = ALIGN(8);
			__am_apps_bss_start = .;
			*(__am_apps.bss*)
			*(__am_apps.sbss*)
			*(__am_apps.scommon*)
			__am_apps_bss_end = .;
			. = ALIGN(8);
		/* rt-thread */
	} > sdram

	PROVIDE(_base_start_ = ADDR(.base));
	PROVIDE(_base_size_	 = SIZEOF(.base));

	_lma = ALIGN(_lma, 0x4);
	. = ALIGN(0x1000);
	PROVIDE(_heap_start	= .);
	PROVIDE(_heap_end	= ORIGIN(sdram) + LENGTH(sdram));

	_stack_pointer = ORIGIN(sram) + LENGTH(sram);

}