![](../../workflows/gds/badge.svg) ![](../../workflows/docs/badge.svg) ![](../../workflows/test/badge.svg) ![](../../workflows/fpga/badge.svg)

# Audio Tone Generator & FM Transmitter

A TinyTapeout FM transmitter project featuring musical tone generation using Direct Digital Synthesis (DDS). This design plays a C-major scale pattern via FM modulation.

- [Read the full documentation](docs/info.md)

## Features

- 🎵 **Musical Tone Generation**: Plays a 16-note C-major scale pattern
- 📻 **FM Modulation**: Generates FM-modulated RF output signal (~12.5 MHz)
- 🔊 **Audio Output**: Direct audio-frequency square wave output
- 🔁 **Loop Mode**: Continuous melody playback
- 📊 **Debug Outputs**: Status monitoring and control signals
- ⚡ **Optimized Design**: Simplified for efficient ASIC implementation

## How It Works

The design uses Direct Digital Synthesis (DDS) with a 32-bit phase accumulator to generate precise frequencies for both audio tones and FM carrier signals. A melody ROM stores a 16-note C-major scale which is sequenced and converted to FM-modulated RF output at ~12.5 MHz.

Key components:
- **Melody ROM**: 16-note C-major scale pattern
- **DDS Engine**: 32-bit phase accumulator for frequency synthesis
- **FM Modulator**: Modulates carrier with audio tones
- **Audio Generator**: Creates audio-frequency square wave output
- **Sequencer**: Controls note timing and progression

### Block Diagram

```
┌─────────────┐     ┌──────────────┐     ┌─────────────┐
│   Melody    │────▶│  Frequency   │────▶│     FM      │────▶ fm_out
│    ROM      │     │  Calculator  │     │  Modulator  │
└─────────────┘     └──────────────┘     └─────────────┘
                           │
                           │
                           ▼
                    ┌──────────────┐
                    │    Audio     │────▶ audio_out
                    │  Generator   │
                    └──────────────┘
```

## Quick Start

### Basic Usage

1. Set `enable` (ui[0]) high to start playback
2. Set `loop` (ui[1]) high for continuous playback
3. Monitor `fm_out` (uo[0]) for FM signal
4. Monitor `audio_out` (uo[1]) with speaker/oscilloscope

### Pin Mapping

| Pin | Name | Description |
|-----|------|-------------|
| ui[0] | enable | Enable playback |
| ui[1] | loop | Loop melody continuously |
| uo[0] | fm_out | FM modulated RF output |
| uo[1] | audio_out | Audio frequency output |
| uo[2] | playing | Melody playing status |
| uo[3] | melody_end | End of melody pulse |

## Technical Specifications

- **Clock Frequency**: 50 MHz
- **FM Carrier**: ~12.5 MHz
- **Tempo**: 120 BPM
- **Melody**: 16-note C-major scale
- **Architecture**: Fully synthesizable Verilog
- **Target**: GF180MCU ASIC (1x2 tiles)

## Testing

The project includes cocotb-based testbenches:

```bash
cd test
make
```

Tests verify:
- Melody playback enable/disable
- Loop mode functionality
- Status signal generation
- Basic FM modulator operation

## External Hardware (Optional)

1. **FM Receiver**: Tune to ~12.5 MHz to receive FM signal
2. **Speaker/Buzzer**: Connect to `audio_out` for direct audio
3. **Oscilloscope**: For signal monitoring and debugging

## Design Optimizations

The design has been optimized for ASIC implementation:
- ✅ Simplified 16-note melody (vs. 82-note Für Elise)
- ✅ Reduced lookup tables for area efficiency
- ✅ Pure behavioral Verilog (no vendor primitives)
- ✅ Single clock domain
- ✅ Fully synthesizable for GF180MCU

## Author

**Rakesh Peter**

## License

Apache-2.0

## Acknowledgments

Based on the iCEstick-hacks FM transmitter project, adapted for TinyTapeout and GF180MCU ASIC implementation.

---

## What is Tiny Tapeout?

Tiny Tapeout is an educational project that aims to make it easier and cheaper than ever to get your digital and analog designs manufactured on a real chip.

To learn more and get started, visit https://tinytapeout.com.

## Resources

- [FAQ](https://tinytapeout.com/faq/)
- [Digital design lessons](https://tinytapeout.com/digital_design/)
- [Learn how semiconductors work](https://tinytapeout.com/siliwiz/)
- [Join the community](https://tinytapeout.com/discord)
- [Build your design locally](https://www.tinytapeout.com/guides/local-hardening/)

## What next?

- [Submit your design to the next shuttle](https://app.tinytapeout.com/)
- Share your project on social media:
  - LinkedIn [#tinytapeout](https://www.linkedin.com/search/results/content/?keywords=%23tinytapeout) [@TinyTapeout](https://www.linkedin.com/company/100708654/)
  - Mastodon [#tinytapeout](https://chaos.social/tags/tinytapeout) [@matthewvenn](https://chaos.social/@matthewvenn)
  - X (formerly Twitter) [#tinytapeout](https://twitter.com/hashtag/tinytapeout) [@tinytapeout](https://twitter.com/tinytapeout)
  - Bluesky [@tinytapeout.com](https://bsky.app/profile/tinytapeout.com)
