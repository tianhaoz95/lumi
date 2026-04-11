use std::env;
use std::path::Path;

fn main() {
    // Re-run build script if this env var changes
    println!("cargo:rerun-if-env-changed=LITERT_NATIVE_DIR");

    let target = env::var("TARGET").unwrap_or_default();
    // Allow an override path for native libs (useful in CI or dev machines)
    if let Ok(native_dir) = env::var("LITERT_NATIVE_DIR") {
        let p = Path::new(&native_dir);
        if p.exists() {
            println!("cargo:rustc-link-search=native={}", p.display());
            // Choose a sensible default library name; the actual file names should
            // be provided by the native SDK packaging (e.g., liblitert.a / liblitert.so)
            if target.contains("android") {
                println!("cargo:rustc-link-lib=static=litert_android");
            } else if target.contains("apple") || target.contains("darwin") {
                println!("cargo:rustc-link-lib=static=litert_ios");
            } else if target.contains("windows") {
                println!("cargo:rustc-link-lib=dylib=litert_windows");
            } else {
                println!("cargo:rustc-link-lib=static=litert");
            }
            return;
        } else {
            println!("cargo:warning=LITERT_NATIVE_DIR={}- does not exist", native_dir);
        }
    }

    // Fallback: try to detect common platform SDK env vars or default locations
    if target.contains("aarch64-linux-android") {
        // Android NDK builds typically provide prebuilt libs via ANDROID_NDK_HOME or similar.
        if let Ok(ndk) = env::var("ANDROID_NDK_HOME") {
            let arch_path = Path::new(&ndk).join("toolchains/llvm/prebuilt/").join("lib");
            println!("cargo:warning=No LITERT_NATIVE_DIR set; ensure native liteRT libs are available for target. ANDROID_NDK_HOME={}", ndk);
            println!("cargo:rustc-link-search=native={}", arch_path.display());
            println!("cargo:rustc-link-lib=static=litert_android");
            return;
        }
        println!("cargo:warning=Building for Android target but LITERT_NATIVE_DIR not set; link may fail if native libs are missing.");
    } else if target.contains("apple") || target.contains("darwin") {
        println!("cargo:warning=Building for Apple target; set LITERT_NATIVE_DIR to the directory containing liblitert_ios.a or .dylib");
    } else if target.contains("windows") {
        println!("cargo:warning=Building for Windows target; set LITERT_NATIVE_DIR to the directory containing litert_windows.lib");
    } else {
        // Host build — do nothing. This keeps local dev builds working without native libs.
        println!("cargo:warning=No LITERT native libs configured; building without linking native LiteRT libs for target {}.", target);
    }
}
