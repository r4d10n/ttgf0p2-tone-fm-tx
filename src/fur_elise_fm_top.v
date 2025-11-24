//-----------------------------------------------------------------------------
// Module: fur_elise_fm_top
//
// Description:
//   Simplified FM transmitter with musical tone generation.
//   Plays a simple C-major scale pattern via FM modulation.
//   Optimized for reduced ASIC area.
//
// Features:
//   - Plays built-in C-major scale melody via FM
//   - Audio frequency output for direct speaker connection
//   - Phase increment output for debugging/monitoring
//
// Ports:
//   clk           - Input clock (~50 MHz expected)
//   rst_n         - Active-low reset
//   enable        - Enable playback
//   loop          - Loop melody continuously
//   clk_2x_enable - Reserved (unused)
//   pwm_in        - Reserved (unused)
//   fm_out        - FM modulated RF output
//   audio_out     - Audio frequency output (speaker)
//   phase_inc_out - Current phase increment (32-bit, for debugging)
//   playing       - Melody currently playing
//   melody_end    - Pulse at end of melody
//
// Author: Based on iCEstick-hacks FM transmitter project
// Target: GF180MCU ASIC (architecture independent)
// License: MIT
//-----------------------------------------------------------------------------

module fur_elise_fm_top #(
    //-------------------------------------------------------------------------
    // Clock Parameters
    //-------------------------------------------------------------------------
    parameter CLK_FREQ_HZ = 100_000_000,

    //-------------------------------------------------------------------------
    // Timing Parameters
    //-------------------------------------------------------------------------
    // Base clocks per 16th note at 120 BPM
    parameter CLOCKS_PER_16TH = CLK_FREQ_HZ / 8,  // 12,500,000 for 100MHz

    //-------------------------------------------------------------------------
    // FM Modulation Parameters
    //-------------------------------------------------------------------------
    // Center frequency = (BASE_PHASE_INCREMENT / 2^32) * CLK_FREQ
    // For clk/4: BASE_PHASE_INCREMENT = 0x40000000 → 25 MHz with 100 MHz clock
    parameter [31:0] BASE_PHASE_INCREMENT = 32'h40000000,

    // Deviation per semitone (for melody mode)
    parameter [31:0] DEVIATION_PER_SEMITONE = 32'h00418937,

    // PWM input deviation scaling
    // Full scale PWM → ±75 kHz deviation
    // Phase inc per sample unit = (75000 / CLK_FREQ) * 2^32 / 32768
    parameter [31:0] PWM_DEVIATION_SCALE = 32'h00009A5E,

    //-------------------------------------------------------------------------
    // PWM Input Parameters
    //-------------------------------------------------------------------------
    parameter PWM_FREQ_HZ = 50_000,  // Expected PWM frequency

    //-------------------------------------------------------------------------
    // Melody Parameters
    //-------------------------------------------------------------------------
    parameter MELODY_LENGTH = 16,
    parameter ADDR_WIDTH    = 5
)(
    //-------------------------------------------------------------------------
    // Clock and Reset
    //-------------------------------------------------------------------------
    input  wire         clk,             // System clock (~100 MHz)
    input  wire         rst_n,           // Active-low asynchronous reset

    //-------------------------------------------------------------------------
    // Control Inputs
    //-------------------------------------------------------------------------
    input  wire         enable,          // Enable playback
    input  wire         loop,            // Loop melody continuously
    input  wire         clk_2x_enable,   // Enable clock doubling (jumper)

    //-------------------------------------------------------------------------
    // PWM Audio Input
    //-------------------------------------------------------------------------
    input  wire         pwm_in,          // External PWM audio input

    //-------------------------------------------------------------------------
    // Outputs
    //-------------------------------------------------------------------------
    output wire         fm_out,          // FM modulated RF output
    output wire         audio_out,       // Audio frequency output (speaker)
    output wire [31:0]  phase_inc_out,   // Phase increment (debug/monitoring)

    //-------------------------------------------------------------------------
    // Status Outputs
    //-------------------------------------------------------------------------
    output wire         playing,         // Melody currently playing
    output wire         melody_end,      // Pulse at end of melody
    output wire [ADDR_WIDTH-1:0] note_index  // Current note index (debug)
);

    //=========================================================================
    // Simplified Design - PWM and clock doubler removed for area optimization
    //=========================================================================

    //=========================================================================
    // Melody ROM and Sequencer
    //=========================================================================

    wire [ADDR_WIDTH-1:0] rom_addr;
    wire [15:0]           rom_data;
    wire signed [7:0]     current_pitch;
    wire                  pitch_valid;
    wire                  sequencer_playing;
    wire                  sequencer_melody_end;

    melody_rom #(
        .MELODY_LENGTH(MELODY_LENGTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) u_melody_rom (
        .clk    (clk),
        .addr   (rom_addr),
        .data   (rom_data)
    );

    melody_sequencer #(
        .CLOCKS_PER_16TH(CLOCKS_PER_16TH),
        .MELODY_LENGTH(MELODY_LENGTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) u_sequencer (
        .clk         (clk),
        .rst_n       (rst_n),
        .enable      (enable),
        .loop        (loop),
        .tempo_clocks(32'd0),  // Use default tempo
        .note_data   (rom_data),
        .note_addr   (rom_addr),
        .note_pitch  (current_pitch),
        .note_valid  (pitch_valid),
        .playing     (sequencer_playing),
        .melody_end  (sequencer_melody_end)
    );

    //=========================================================================
    // Note to Phase Increment (for melody)
    //=========================================================================

    wire [31:0] melody_phase_increment;
    wire        melody_is_rest;

    note_to_phase_increment #(
        .ACCUMULATOR_WIDTH(32)
    ) u_note_to_freq (
        .clk             (clk),
        .rst_n           (rst_n),
        .note_pitch      (current_pitch),
        .base_increment  (BASE_PHASE_INCREMENT),
        .deviation_step  (DEVIATION_PER_SEMITONE),
        .phase_increment (melody_phase_increment),
        .is_rest         (melody_is_rest)
    );

    // Output phase increment for debugging/monitoring
    assign phase_inc_out = melody_phase_increment;

    //=========================================================================
    // FM Modulator
    //=========================================================================

    wire fm_raw_out;

    fm_modulator #(
        .ACCUMULATOR_WIDTH(32)
    ) u_fm_mod (
        .clk             (clk),
        .rst_n           (rst_n),
        .enable          (enable & pitch_valid),
        .phase_increment (melody_phase_increment),
        .fm_out          (fm_raw_out),
        .phase_out       ()
    );

    assign fm_out = fm_raw_out;

    //=========================================================================
    // Audio Tone Generator (for speaker output)
    //=========================================================================

    audio_tone_generator #(
        .CLK_FREQ_HZ(CLK_FREQ_HZ),
        .ACCUMULATOR_WIDTH(32)
    ) u_audio_gen (
        .clk        (clk),
        .rst_n      (rst_n),
        .enable     (enable),
        .note_pitch (current_pitch),
        .note_valid (pitch_valid),
        .audio_out  (audio_out),
        .audio_pwm  ()
    );

    //=========================================================================
    // Status Outputs
    //=========================================================================

    assign playing    = sequencer_playing;
    assign melody_end = sequencer_melody_end;
    assign note_index = rom_addr;

endmodule
