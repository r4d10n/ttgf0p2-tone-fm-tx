<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

This project is an FM transmitter with musical tone generation using Direct Digital Synthesis (DDS). It plays a 16-note C-major scale pattern via FM modulation. The design has been optimized for efficient ASIC implementation.

### Core Components

**Direct Digital Synthesis (DDS)**: Uses a 32-bit phase accumulator that increments each clock cycle. The MSB toggles at the desired output frequency, creating square wave tones with precise frequency control.

**Melody Generation**: A ROM stores 16 notes of a C-major scale with duration information. The melody sequencer reads notes sequentially, calculates appropriate frequencies, and drives both the audio and FM modulators.

**FM Modulation**: Audio tones modulate the carrier frequency by adjusting the phase increment of the FM modulator. This creates frequency deviation around a ~12.5 MHz center carrier frequency.

**Audio Generator**: Creates audio-frequency square wave output directly from the note frequencies, suitable for driving speakers or buzzers.

**Sequencer**: Controls note timing and progression through the melody, with support for looping playback.

The design outputs both the FM-modulated RF signal and a direct audio-frequency square wave for speakers or debugging.

## How to test

### Basic Melody Playback

1. Set `enable` (ui[0]) high to start playback
2. Set `loop` (ui[1]) high for continuous playback
3. Monitor `fm_out` (uo[0]) for the FM modulated RF signal
4. Monitor `audio_out` (uo[1]) for audio frequency output (connect to speaker/buzzer)
5. Observe `playing` (uo[2]) status - should go high when melody is active

### Status Monitoring

- `playing` (uo[2]): High when melody is active
- `melody_end` (uo[3]): Pulses at the end of each melody cycle
- `status[3:0]` (uo[7:4]): Additional status information
- `bidir_out[7:0]` (uio[7:0]): Bidirectional output pins (configured as outputs)

### Expected Behavior

- When enabled without loop: Plays the 16-note C-major scale once and stops
- When enabled with loop: Plays the C-major scale continuously
- FM carrier operates at ~12.5 MHz
- Audio output provides direct tone generation for speaker/buzzer

## External hardware

### Optional External Hardware

1. **FM Receiver**: To receive and demodulate the FM signal from `fm_out`
   - Tune to approximately 12.5 MHz
   - May require amplification and antenna for best results

2. **Speaker/Buzzer**: Connect to `audio_out` for direct audio playback
   - Small piezo buzzer or 8Ω speaker with suitable driver
   - Output is a square wave at audio frequencies (C4-C5 range)

3. **Oscilloscope** (recommended for testing):
   - Monitor FM carrier on `fm_out`
   - Observe audio waveforms on `audio_out`
   - Measure signal characteristics

### No External Hardware Required

The design is fully functional without any external hardware:
- Internal melody plays automatically when enabled
- All signals can be monitored on output pins
- Self-contained demonstration of FM modulation and DDS principles

### Pin Connections Summary

| Pin | Name | Direction | Description |
|-----|------|-----------|-------------|
| ui[0] | enable | Input | Enable playback |
| ui[1] | loop | Input | Loop melody continuously |
| ui[2] | - | Input | Unused |
| ui[3] | - | Input | Unused |
| uo[0] | fm_out | Output | FM modulated RF output |
| uo[1] | audio_out | Output | Audio frequency output |
| uo[2] | playing | Output | Melody playing status |
| uo[3] | melody_end | Output | End of melody pulse |
| uo[7:4] | status | Output | Status bits |
| uio[7:0] | bidir_out | Output | Bidirectional outputs |
