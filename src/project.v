/*
 * Copyright (c) 2024 r4d10n
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

//-----------------------------------------------------------------------------
// Module: tt_um_tone_fm_tx
//
// Description:
//   TinyTapeout wrapper for FM transmitter with tone generation.
//   Plays a C-major scale pattern via FM modulation.
//   Supports optional clock doubling and PWM audio input.
//
// Pin Mapping:
//   ui_in[0]   = enable      - Enable playback
//   ui_in[1]   = loop        - Loop melody continuously
//   ui_in[2]   = clk_2x_en   - Enable clock doubling
//   ui_in[3]   = pwm_in      - External PWM audio input
//   ui_in[7:4] = reserved
//
//   uo_out[0]  = fm_out      - FM modulated RF output
//   uo_out[1]  = audio_out   - Audio frequency output (speaker)
//   uo_out[2]  = playing     - Melody currently playing
//   uo_out[3]  = melody_end  - Pulse at end of melody
//   uo_out[7:4]= status      - Status bits
//
//   uio[7:0]   = outputs     - Bidirectional I/O (configured as outputs)
//
//-----------------------------------------------------------------------------

module tt_um_tone_fm_tx (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

    //=========================================================================
    // Input Mapping
    //=========================================================================
    wire enable      = ui_in[0] & ena;
    wire loop        = ui_in[1];
    wire clk_2x_en   = ui_in[2];
    wire pwm_in      = ui_in[3];

    //=========================================================================
    // Internal Signals
    //=========================================================================
    wire        fm_out;
    wire        audio_out;
    wire [31:0] phase_inc_out;
    wire        playing;
    wire        melody_end;
    wire [4:0]  note_index;

    //=========================================================================
    // FM Transmitter Core
    //=========================================================================
    fur_elise_fm_top #(
        .CLK_FREQ_HZ(50_000_000),           // TinyTapeout clock is ~50 MHz
        .CLOCKS_PER_16TH(50_000_000 / 8),   // 120 BPM
        .MELODY_LENGTH(16),                 // Simplified 16-note melody
        .PWM_FREQ_HZ(50_000)
    ) u_fur_elise (
        .clk           (clk),
        .rst_n         (rst_n),
        .enable        (enable),
        .loop          (loop),
        .clk_2x_enable (clk_2x_en),
        .pwm_in        (pwm_in),
        .fm_out        (fm_out),
        .audio_out     (audio_out),
        .phase_inc_out (phase_inc_out),
        .playing       (playing),
        .melody_end    (melody_end),
        .note_index    (note_index)
    );

    //=========================================================================
    // Output Mapping
    //=========================================================================
    assign uo_out[0] = fm_out;
    assign uo_out[1] = audio_out;
    assign uo_out[2] = playing;
    assign uo_out[3] = melody_end;
    assign uo_out[7:4] = note_index[3:0];

    // Bidirectional IOs used as outputs for phase increment MSB
    assign uio_out = phase_inc_out[31:24];
    assign uio_oe  = 8'hFF;  // All outputs

    // Suppress unused input warnings
    wire _unused = &{uio_in, ui_in[7:4], note_index[4], 1'b0};

endmodule
