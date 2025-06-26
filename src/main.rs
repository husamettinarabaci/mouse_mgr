use evdev::{Device, InputEventKind, Key};
use std::fs;
use std::io;
use std::process::Command;
use std::{thread, time};

fn main() -> io::Result<()> {
    // Daemon main loop
    loop {
        let paths = match fs::read_dir("/dev/input") {
            Ok(p) => p,
            Err(_) => {
                thread::sleep(time::Duration::from_secs(2));
                continue;
            }
        };

        for entry in paths {
            let entry = match entry {
                Ok(e) => e,
                Err(_) => continue,
            };
            let path = entry.path();
            if let Some(name) = path.file_name() {
                if name.to_string_lossy().starts_with("event") {
                    if let Ok(mut dev) = Device::open(&path) {
                        if let Some(keys) = dev.supported_keys() {
                            if keys.contains(Key::BTN_LEFT) {
                                // Read events
                                loop {
                                    if let Ok(events) = dev.fetch_events() {
                                        for ev in events {
                                            if let InputEventKind::RelAxis(axis) = ev.kind() {
                                                let axis_str = format!("{:?}", axis);
                                                if axis_str == "REL_HWHEEL"
                                                    || axis_str == "REL_HWHEEL_HI_RES"
                                                {
                                                    let value = ev.value();
                                                    if value < 0 {
                                                        let output = Command::new("amixer")
                                                            .args(["set", "Master", "1%+"])
                                                            .output();
                                                        match output {
                                                            Ok(out) => {
                                                                println!(
                                                                    "[mouse_mgr] Volume up (value: {}): {} {}",
                                                                    value,
                                                                    String::from_utf8_lossy(
                                                                        &out.stdout
                                                                    ),
                                                                    String::from_utf8_lossy(
                                                                        &out.stderr
                                                                    )
                                                                );
                                                            }
                                                            Err(e) => {
                                                                println!(
                                                                    "[mouse_mgr] Volume up (value: {}) failed: {}",
                                                                    value, e
                                                                );
                                                            }
                                                        }
                                                    } else if value > 0 {
                                                        let output = Command::new("amixer")
                                                            .args(["set", "Master", "1%-"])
                                                            .output();
                                                        match output {
                                                            Ok(out) => {
                                                                println!(
                                                                    "[mouse_mgr] Volume down (value: {}): {} {}",
                                                                    value,
                                                                    String::from_utf8_lossy(
                                                                        &out.stdout
                                                                    ),
                                                                    String::from_utf8_lossy(
                                                                        &out.stderr
                                                                    )
                                                                );
                                                            }
                                                            Err(e) => {
                                                                println!(
                                                                    "[mouse_mgr] Volume down (value: {}) failed: {}",
                                                                    value, e
                                                                );
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    thread::sleep(time::Duration::from_millis(10));
                                }
                            }
                        }
                    }
                }
            }
        }
        thread::sleep(time::Duration::from_secs(2));
    }
}
