#include <stdint.h>
#define SYSCTL_RCGCGPIO_R (*((volatile uint32_t *)0x400FE608))
#define GPIO_PORTF_DIR_R  (*((volatile uint32_t *)0x40025400))
#define GPIO_PORTF_DEN_R  (*((volatile uint32_t *)0x4002551C))
#define GPIO_PORTF_DATA_R (*((volatile uint32_t *)0x400253FC))

int main(void) {
    SYSCTL_RCGCGPIO_R |= 0x20; // Enable clock for Port F
    GPIO_PORTF_DIR_R |= 0x02;  // Set PF1 as output (red LED)
    GPIO_PORTF_DEN_R |= 0x02;  // Enable digital for PF1
    while (1) {
        GPIO_PORTF_DATA_R ^= 0x02; // Toggle PF1
        for (volatile int i = 0; i < 100000; i++); // Delay
    }
    return 0;
} 