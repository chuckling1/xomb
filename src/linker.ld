/* 
linker.ld

- This script is given as the only script to the linker
- Will map boot.S to LMA, and then everything else
  will be linked to the VMA and mapped at the LMA
- _etext, _edata, _end are defined here

*/


/*  KERNEL LINK LOCATIONS

these are the locations to map to
they need to be set within boot.h
as well  */

kernel_VMA = 0xffffffff80000000;
kernel_LMA = 0x100000;

/* start from the entry point */
ENTRY(_start)
SECTIONS
{
    /* link from LMA */
    . = kernel_LMA;

	_boot = .;

    /* boot.S is ran in linear addresses */
    .text_boot : 
    {
        kernel/arch/x86_64/boot/boot.o (.text)
    }

	_eboot = .;

	PROVIDE(_trampoline = .);

	.text_trampoline ALIGN(0x1000) : 
	{
		kernel/arch/x86_64/boot/trampoline.o (.text)
	}

	PROVIDE(_etrampoline = .);

    /* link from VMA */
    . = . + kernel_VMA;

	_text = .;

	PROVIDE(_kernel = .);
	PROVIDE(_kernelBase = kernel_VMA);

    /* the rest of the code links to higher memory */
    .text : AT(ADDR(.text) - kernel_VMA + kernel_LMA)
    {
        code = .;
        *(.text)
		*(.text*)

        /* read only data */
        *(.rodata*)
        *(.rdata*)

        . = ALIGN(4096);
    }  

	PROVIDE(_ekernel = .);

    /* _etext defined */
    PROVIDE (_etext = .);

	_data = .;

    /* data section */	
    .data : AT(ADDR(.data) - kernel_VMA + kernel_LMA)
    {
        data = .;
        *(.data)

        /* constructors and deconstructors 
           (if needed, doesn't hurt) */

        start_ctors = .;
        *(.ctor*)
        end_ctors = .;

        start_dtors = .;
        *(.dtor*)
        end_dtors = .;

        . = ALIGN(4096);
    }

    /* _edata defined */
    _edata = .; PROVIDE (edata = .);

    /* static code */
    .bss : AT(ADDR(.bss) - kernel_VMA + kernel_LMA)
    {
        *(.bss)
        . = ALIGN(4096);
    }

    /*  */	
    .ehframe : AT(ADDR(.ehframe) - kernel_VMA + kernel_LMA)
    {
        ehframe = .;
        *(.ehframe)
        . = ALIGN(4096);
    }  

    /* _end defined */
    _end = .; PROVIDE (end = .);

}


