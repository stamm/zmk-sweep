# AGENTS.md

This file contains guidelines and commands for agentic coding agents working in this ZMK firmware repository.

## Project Overview

This is a ZMK (Zephyr Keyboard Firmware) repository for the Ferris Sweep keyboard, a split ergonomic keyboard. The repository contains keyboard configuration files, keymaps, and build definitions for ZMK firmware.

## Build System

This project uses the ZMK build system based on West (Zephyr's meta-tool).

### Essential Commands

**Build Commands:**
```bash
# Initialize West (if not already done)
west init -l config

# Update dependencies
west update

# Export Zephyr environment
west zephyr-export

# Build left half (Cradio/Sweep)
west build -s zmk/app -b 'nice_nano//zmk' -- -DSHIELD=cradio_left -DZMK_CONFIG="${PWD}/config"

# Build right half (Cradio/Sweep)
west build --pristine -s zmk/app -b 'nice_nano//zmk' -- -DSHIELD=cradio_right -DZMK_CONFIG="${PWD}/config"

# Clean build directory
west build --pristine
```

**Testing Commands:**
- ZMK doesn't have traditional unit tests
- Testing is done through hardware validation and build verification
- Always build both left and right halves to ensure complete functionality

**CI/CD:**
- GitHub Actions workflow in `.github/workflows/build.yml` handles automated builds
- Workflow builds both left and right halves and creates UF2 files for flashing

## Code Style Guidelines

### File Structure
- `config/` - Contains all keyboard configuration files
- `config/cradio.keymap` - Main keymap definition
- `config/cradio.conf` - Hardware and firmware configuration
- `config/west.yml` - West manifest for dependencies

### Devicetree (.keymap files) Style
- Use tabs for indentation (ZMK convention)
- Align bindings in readable columns
- Use descriptive names for behaviors and combos
- Group related functionality together

**Example formatting:**
```c
default_layer {
    bindings = <
        &kp Q      &kp W      &kp E        &kp R      &kp T     &kp Y &kp U      &kp I        &kp O       &kp P
        &hm LALT A &hm LCTL S &hm LSHIFT D &hm LGUI F &kp G     &kp H &hm RGUI J &hm RSHIFT K &hm RCTRL L &hm RALT SEMICOLON
    >;
};
```

### Configuration (.conf files) Style
- Use uppercase for configuration options
- Group related settings together
- Add comments explaining non-obvious configurations
- Use descriptive variable names

**Example formatting:**
```conf
# increase bluetooth signal power
CONFIG_BT_CTLR_TX_PWR_PLUS_8=y

CONFIG_ZMK_KEYBOARD_NAME="Ferris Sweep"

# enable deep sleep support
CONFIG_ZMK_SLEEP=y
```

### Naming Conventions
- **Layers:** Use `UPPERCASE` with descriptive names (BASE, LOWER, RAISE, ADJUST)
- **Behaviors:** Use `snake_case` for custom behaviors (homerow_mods)
- **Combos:** Use `snake_case` with descriptive prefixes (combo_minus, combo_quote)
- **Key positions:** Use numeric values as defined by hardware matrix

### Import Organization
- Standard ZMK includes first:
  ```c
  #include <behaviors.dtsi>
  #include <dt-bindings/zmk/keys.h>
  #include <dt-bindings/zmk/bt.h>
  ```
- Custom includes after standard ones
- Group related includes together

### Error Handling
- ZMK uses compile-time configuration validation
- Build errors indicate configuration issues
- Always check build output for warnings and errors
- Test keymap changes through build verification before flashing

### Keymap Design Principles
- Prioritize ergonomic hand movement
- Use homerow mods for modifier accessibility
- Implement logical layer transitions
- Consider frequency of symbol usage
- Maintain consistency between hands

### Combo Guidelines
- Keep timeout values low (50-100ms) for responsiveness
- Use intuitive key combinations
- Avoid conflicts with regular typing patterns
- Test combos thoroughly to prevent false triggers

### Hardware Configuration
- Set appropriate debounce values for responsiveness
- Configure sleep settings for battery life
- Optimize Bluetooth settings for range and power
- Use hardware-specific optimizations

## Development Workflow

1. **Make changes** to keymap or configuration files
2. **Build both halves** to verify changes
3. **Check build output** for warnings/errors
4. **Test on hardware** if available
5. **Commit changes** with descriptive messages

## Common Issues

- **Build fails:** Check west initialization and dependencies
- **Keymap errors:** Verify syntax and key codes
- **Configuration conflicts:** Check for duplicate settings
- **Hardware issues:** Verify board and shield configurations

## Repository Specifics

- Target board: `nice_nano//zmk` (nice!nano v2, board revision 2.0.0 under ZMK's HWMv2 naming; `nice_nano_v2` no longer exists)
- Shield: `cradio_left` and `cradio_right`
- Split keyboard with left/right halves
- Uses ZMK's behavioral system for advanced functionality
- Implements homerow mods, combos, and conditional layers