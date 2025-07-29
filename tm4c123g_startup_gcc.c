#include <stdint.h>

extern int main(void);
void ResetISR(void);
void DefaultISR(void);

__attribute__ ((section(".isr_vector")))
void (* const g_pfnVectors[])(void) = {
    (void (*)(void))(0x20008000), // Initial stack pointer (32KB SRAM)
    ResetISR,                     // Reset handler
    DefaultISR,                   // NMI
    DefaultISR,                   // HardFault
    DefaultISR,                   // MPU Fault
    DefaultISR,                   // Bus Fault
    DefaultISR,                   // Usage Fault
    0, 0, 0, 0,                   // Reserved
    DefaultISR,                   // SVCall
    DefaultISR,                   // Debug monitor
    0,                            // Reserved
    DefaultISR,                   // PendSV
    DefaultISR,                   // SysTick
    // ... (other vectors can be added as needed)
};

void ResetISR(void) {
    main();
    while (1);
}

void DefaultISR(void) {
    while (1);
} 