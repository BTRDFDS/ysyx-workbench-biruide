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
		. = ALIGN(0x4);
		*(entry)
		*(.text._trm_init)
	} > flash AT> flash

	.load : {
		*(.text._bootloader)
	} > psram AT> flash
	PROVIDE(_load_start_ = ADDR(.load));
	PROVIDE(_load_size_ = SIZEOF(.load));
	PROVIDE(_load_begin_ = LOADADDR(.load));

	.data ALIGN(4): {
		*(.text*)
		*(.rodata*)
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
		} > psram AT> flash
    PROVIDE(_data_start_ = ADDR(.data));
    PROVIDE(_data_size_ = SIZEOF(.data));
    PROVIDE(_data_begin_ = LOADADDR(.data));
	
	.bss ALIGN(4): {
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
	} > psram

	PROVIDE(_bss_start_	= ADDR(.bss));
	PROVIDE(_bss_size_	= SIZEOF(.bss));

	. = ALIGN(0x4);
	PROVIDE(_heap_start	= .);
	PROVIDE(_heap_end	= ORIGIN(psram) + LENGTH(psram));

	_stack_pointer = ORIGIN(sram) + LENGTH(sram);

}