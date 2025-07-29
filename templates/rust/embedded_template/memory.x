/* Linker script for a generic Cortex-M microcontroller */

MEMORY
{
  FLASH : ORIGIN = 0x08000000, LENGTH = 1024K
  RAM : ORIGIN = 0x20000000, LENGTH = 128K
}

/* Sections */
SECTIONS
{
  .text : ALIGN(4)
  {
    KEEP(*(.vector_table))
    *(.text)
    *(.text.*)
    *(.rodata)
    *(.rodata.*)
    . = ALIGN(4);
  } > FLASH

  .data : ALIGN(4)
  {
    *(.data)
    *(.data.*)
    . = ALIGN(4);
  } > RAM AT > FLASH

  .bss : ALIGN(4)
  {
    *(.bss)
    *(.bss.*)
    . = ALIGN(4);
  } > RAM

  .uninit : ALIGN(4)
  {
    *(.uninit)
    *(.uninit.*)
    . = ALIGN(4);
  } > RAM

  /DISCARD/ :
  {
    *(.ARM.exidx)
    *(.ARM.exidx.*)
  }
}
