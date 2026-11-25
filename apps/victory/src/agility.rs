//! Opt in to the application-local Direct3D 12 Agility SDK 1.620.2.

#[unsafe(no_mangle)]
pub static D3D12SDKVersion: u32 = 620;

#[repr(transparent)]
pub struct SdkPath(*const std::ffi::c_char);

// SAFETY: The pointer always refers to immutable, static string data.
unsafe impl Sync for SdkPath {}

#[unsafe(no_mangle)]
pub static D3D12SDKPath: SdkPath = SdkPath(c".\\D3D12\\".as_ptr());
