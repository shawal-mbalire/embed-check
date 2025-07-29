use std::env;
use std::fs::File;
use std::io::Write;
use std::path::PathBuf;

fn main() {
    // Put `linker.ld` in our output directory and ensure it's on the linker search path.
    let out = &PathBuf::from(env::var_os("OUT_DIR").unwrap());
    File::create(out.join("memory.x"))
        .unwrap()
        .write_all(include_bytes!("memory.x"))
        .unwrap();
    println!("cargo:rustc-link-search={}", out.display());

    // By default, Cargo will re-run this build script if the build script itself or
    // any of its dependencies change. By specifying `memory.x` as a dependency, we
    // ensure that if the linker script changes, the build script is re-run.
    println!("cargo:rerun-if-changed=memory.x");

    // Set the linker to `ld` (GNU linker) or `lld` (LLVM linker).
    // You might need to adjust this based on your toolchain.
    println!("cargo:rustc-link-arg=-Tmemory.x");
}
