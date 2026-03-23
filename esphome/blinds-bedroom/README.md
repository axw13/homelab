# 🪟 Motorized Bedroom Blinds — ESPHome + ULN2003 Stepper

ESPHome configuration for a DIY motorized blind using a 28BYJ-48 stepper motor and ULN2003 driver board, running on a NodeMCU v2 (ESP8266). Integrates natively with Home Assistant as a `cover` entity with full position control.

---

## ✨ Features

- **Full position control** — open, close, stop, or set any position (0–100%) from Home Assistant
- **Calibration system** — set open/closed endpoints via HA buttons, no hardcoded step counts
- **Position survives power loss** — last stepper position is persisted to flash and restored on boot
- **Smart publish** — cover position only updates HA when actually moving or changed, no unnecessary traffic
- **Direction invert** — swap open/close direction with a single substitution flag (`COVER_INVERT`)
- **Manual step control** — number entity for absolute step positioning during setup
- **WiFi stability fixes** — `power_save_mode: none` prevents periodic drop-outs on ESP8266
- **Fallback AP** — captive portal hotspot if WiFi is unreachable

---

## 🔧 Hardware

| Component | Details |
|-----------|---------|
| **MCU** | NodeMCU v2 (ESP8266) |
| **Motor** | 28BYJ-48 5V stepper motor |
| **Driver** | ULN2003 driver board |
| **Power** | 5V USB or dedicated supply |

### Wiring

| ULN2003 Pin | NodeMCU GPIO |
|-------------|-------------|
| IN1 | GPIO5 (D1) |
| IN2 | GPIO4 (D2) |
| IN3 | GPIO14 (D5) |
| IN4 | GPIO12 (D6) |
| VCC | 5V |
| GND | GND |

> ⚠️ Power the ULN2003 from an external 5V supply if possible — powering it from the NodeMCU's 3.3V pin will cause motor jitter and resets under load.

---

## 📦 Installation

### Prerequisites
- [ESPHome](https://esphome.io) installed (via Home Assistant addon or CLI)
- `secrets.yaml` with the following keys:

```yaml
wifi_ssid: "YourSSID"
wifi_password: "YourWiFiPassword"
api_key: "your-32-byte-base64-api-key"
ota_password: "your-ota-password"
ap_password: "your-fallback-ap-password"
```

### Flash

```bash
esphome run blinds.yaml
```

Or use the ESPHome dashboard in Home Assistant.

---

## 🎛️ Calibration

Once flashed and added to Home Assistant:

1. Use the **"Blinds Manual Move Steps"** number entity to jog the motor to the **fully open** position
2. Press **"Calibrate: Set Open Position"** button
3. Jog to the **fully closed** position
4. Press **"Calibrate: Set Closed Position"** button
5. The cover entity is now fully operational with accurate position reporting

To recalibrate (e.g. after remounting): press **"Calibrate: Clear All"** and repeat.

---

## ⚙️ Configuration Notes

- **`COVER_INVERT: "false"`** — change to `"true"` if open/close direction is physically reversed
- **`max_speed: 150 steps/s`** — safe for 28BYJ-48; increase cautiously, motor skips steps above ~200
- **`flash_write_interval: 300s`** — reduced from default 60s to minimise CPU blocking during movement
- **`sleep_when_done: true`** — cuts motor current when idle, reduces heat significantly

---

## 🐛 Known Issues

- NodeMCU v2 has a weak onboard WiFi antenna — signal at -88 dBm in some locations causes occasional reconnects. `power_save_mode: none` mitigates but doesn't fully solve this; a better antenna or closer AP is the real fix.
- Position accuracy degrades if the motor skips steps (usually caused by too much load or too high speed). Recalibrate if the cover drifts over time.

---

## 📁 Part of

This project is part of my [homelab repository](../../README.md) — see the main README for the full smart home and infrastructure setup.
