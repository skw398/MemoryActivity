@available(macOS, deprecated: 26)
let macOS26Available =
    if #available(macOS 26, *) {
        true
    } else {
        false
    }

@available(macOS, deprecated: 15)
let macOS15Available =
    if #available(macOS 15, *) {
        true
    } else {
        false
    }
