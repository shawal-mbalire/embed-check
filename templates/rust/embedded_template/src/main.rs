#![no_std]
#![no_main]

// Pick a panic handler
use panic_halt as _;

#[cortex_m_rt::entry]
fn main() -> ! {
    // Initialize your board and peripherals here

    loop {
        // Your embedded application logic here
    }
}
