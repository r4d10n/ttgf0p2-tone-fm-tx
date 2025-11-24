<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

This project is an FM transmitter with musical tone generation using Direct Digital Synthesis (DDS). It plays a 16-note C-major scale pattern and supports optional external PWM audio input for FM transmission.

### Core Components

**Direct Digital Synthesis (DDS)**: Uses a 32-bit phase accumulator that increments each clock cycle. The MSB toggles at the desired output frequency, creating square wave tones with precise frequency control.

**Melody Generation**: A ROM stores 16 notes of a C-major scale with duration information. The melody sequencer reads notes sequentially, calculates appropriate frequencies, and drives both the audio and FM modulators.

**FM Modulation**: Audio tones modulate the carrier frequency by adjusting the phase increment of the FM modulator. This creates frequency deviation around a ~12.5 MHz center carrier frequency (25 MHz with clock doubling enabled).

**Clock Doubling**: An optional XOR-based edge detector doubles the effective clock frequency by generating pulses on both rising and falling edges, allowing higher FM carrier frequencies.

**PWM Input Decoder**: Accepts external PWM audio signals (50 kHz expected) and decodes them into digital samples for FM modulation, enabling transmission of arbitrary audio instead of the built-in melody.

### Operating Modes

1. **Melody Mode**: Built-in C-major scale plays continuously when enabled
2. **PWM Input Mode**: External PWM audio modulates the FM carrier when active
3. **Clock Doubling**: Optional 2x clock multiplication for higher carrier frequency

The design outputs both the FM-modulated RF signal and a direct audio-frequency square wave for speakers or debugging.

## How to test

### Basic Melody Playback

1. Set `enable` (ui[0]) high to start playback
2. Set `loop` (ui[1]) high for continuous playback
3. Monitor `fm_out` (uo[0]) for the FM modulated RF signal
4. Monitor `audio_out` (uo[1]) for audio frequency output (connect to speaker/buzzer)
5. Observe `playing` (uo[2]) status - should go high when melody is active

### Clock Doubling

1. Set `clk_2x_enable` (ui[2]) high to double the FM carrier frequency
2. FM carrier will increase from ~12.5 MHz to ~25 MHz
3. Useful for reaching higher carrier frequencies without a PLL

### PWM Audio Input

1. Connect an external PWM audio source to `pwm_in` (ui[3])
2. PWM frequency should be approximately 50 kHz
3. The PWM signal will be automatically decoded and used to modulate the FM carrier
4. Built-in melody continues to play on `audio_out`

### Status Monitoring

- `playing` (uo[2]): High when melody is active
- `melody_end` (uo[3]): Pulses at the end of each melody cycle
- `status[3:0]` (uo[7:4]): Additional status information
- `bidir_out[7:0]` (uio[7:0]): Bidirectional output pins (configured as outputs)

### Expected Behavior

- When enabled without loop: Plays the 16-note C-major scale once and stops
- When enabled with loop: Plays the C-major scale continuously
- PWM input overrides melody for FM transmission but melody continues on audio output
- Clock doubling doubles the FM carrier frequency

## External hardware

### Optional External Hardware

1. **FM Receiver**: To receive and demodulate the FM signal from `fm_out`
   - Tune to approximately 12.5 MHz (or 25 MHz with clock doubling)
   - May require amplification and antenna for best results

2. **Speaker/Buzzer**: Connect to `audio_out` for direct audio playback
   - Small piezo buzzer or 8Ω speaker with suitable driver
   - Output is a square wave at audio frequencies (C4-C5 range)

3. **PWM Audio Source** (optional): For external audio input
   - Any microcontroller or audio device with PWM output
   - PWM frequency: ~50 kHz recommended
   - Connect to `pwm_in` input

4. **Oscilloscope** (recommended for testing):
   - Monitor FM carrier on `fm_out`
   - Observe audio waveforms on `audio_out`
   - Verify clock doubling effect

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
| ui[2] | clk_2x_enable | Input | Enable clock doubling |
| ui[3] | pwm_in | Input | External PWM audio input |
| uo[0] | fm_out | Output | FM modulated RF output |
| uo[1] | audio_out | Output | Audio frequency output |
| uo[2] | playing | Output | Melody playing status |
| uo[3] | melody_end | Output | End of melody pulse |
| uo[7:4] | status | Output | Status bits |
| uio[7:0] | bidir_out | Output | Bidirectional outputs |
