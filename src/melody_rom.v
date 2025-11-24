//-----------------------------------------------------------------------------
// Module: melody_rom
//
// Description:
//   Read-only memory containing Beethoven's "Für Elise" melody encoded as
//   note data. Each entry contains a note pitch (as semitone offset from A4)
//   and duration code.
//
// Design Notes:
//   - Architecture independent (no vendor primitives)
//   - Synthesizes to LUT-based ROM
//   - Notes encoded as signed offset from A4 (440 Hz)
//   - Duration encoded as power-of-2 multiplier
//
// Encoding Format:
//   [15:8] = Note pitch (signed, semitones from A4, 0x80 = REST)
//   [7:6]  = Reserved
//   [5:0]  = Duration code (0=16th, 1=8th, 2=quarter, 3=half, 4=whole, etc.)
//
// Note Reference (semitones from A4):
//   C4  = -9    D4  = -7    E4  = -5    F4  = -4
//   G4  = -2    G#4 = -1    A4  =  0    A#4 = +1
//   B4  = +2    C5  = +3    D5  = +5    D#5 = +6
//   E5  = +7    F5  = +8    G5  = +10   A5  = +12
//
// Author: Based on iCEstick-hacks FM transmitter project
// Target: GF180MCU ASIC (architecture independent)
// License: MIT
//-----------------------------------------------------------------------------

module melody_rom #(
    parameter MELODY_LENGTH = 128,           // Number of notes in melody
    parameter ADDR_WIDTH    = 7              // log2(MELODY_LENGTH)
)(
    input  wire                    clk,
    input  wire [ADDR_WIDTH-1:0]   addr,
    output reg  [15:0]             data
);

    //-------------------------------------------------------------------------
    // Note Definitions (semitones from A4 = 440 Hz)
    //-------------------------------------------------------------------------
    localparam signed [7:0] REST = 8'h80;    // Special: silence
    localparam signed [7:0] C4   = -8'd9;
    localparam signed [7:0] D4   = -8'd7;
    localparam signed [7:0] E4   = -8'd5;
    localparam signed [7:0] F4   = -8'd4;
    localparam signed [7:0] G4   = -8'd2;
    localparam signed [7:0] Gs4  = -8'd1;    // G#4
    localparam signed [7:0] A4   =  8'd0;
    localparam signed [7:0] As4  =  8'd1;    // A#4
    localparam signed [7:0] B4   =  8'd2;
    localparam signed [7:0] C5   =  8'd3;
    localparam signed [7:0] D5   =  8'd5;
    localparam signed [7:0] Ds5  =  8'd6;    // D#5
    localparam signed [7:0] E5   =  8'd7;
    localparam signed [7:0] F5   =  8'd8;
    localparam signed [7:0] G5   =  8'd10;
    localparam signed [7:0] A5   =  8'd12;

    //-------------------------------------------------------------------------
    // Duration Definitions
    //-------------------------------------------------------------------------
    localparam [5:0] DUR_16TH    = 6'd0;     // Sixteenth note
    localparam [5:0] DUR_8TH     = 6'd1;     // Eighth note
    localparam [5:0] DUR_QUARTER = 6'd2;     // Quarter note
    localparam [5:0] DUR_HALF    = 6'd3;     // Half note
    localparam [5:0] DUR_WHOLE   = 6'd4;     // Whole note
    localparam [5:0] DUR_DOT8TH  = 6'd5;     // Dotted eighth (1.5x eighth)

    //-------------------------------------------------------------------------
    // Helper function to encode note
    //-------------------------------------------------------------------------
    function [15:0] note;
        input signed [7:0] pitch;
        input [5:0] duration;
        begin
            note = {pitch, 2'b00, duration};
        end
    endfunction

    //-------------------------------------------------------------------------
    // Melody ROM - Simple C-Major Scale Pattern (16 notes)
    // Simplified to reduce area utilization for ASIC build
    //-------------------------------------------------------------------------
    always @(posedge clk) begin
        case (addr)
            //=================================================================
            // Simple ascending and descending C-major scale pattern
            //=================================================================
            7'd0:  data <= note(C4,   DUR_8TH);      // C4
            7'd1:  data <= note(D4,   DUR_8TH);      // D4
            7'd2:  data <= note(E4,   DUR_8TH);      // E4
            7'd3:  data <= note(F4,   DUR_8TH);      // F4
            7'd4:  data <= note(G4,   DUR_8TH);      // G4
            7'd5:  data <= note(A4,   DUR_8TH);      // A4
            7'd6:  data <= note(B4,   DUR_8TH);      // B4
            7'd7:  data <= note(C5,   DUR_8TH);      // C5 (octave up)
            7'd8:  data <= note(C5,   DUR_8TH);      // C5
            7'd9:  data <= note(B4,   DUR_8TH);      // B4
            7'd10: data <= note(A4,   DUR_8TH);      // A4
            7'd11: data <= note(G4,   DUR_8TH);      // G4
            7'd12: data <= note(F4,   DUR_8TH);      // F4
            7'd13: data <= note(E4,   DUR_8TH);      // E4
            7'd14: data <= note(D4,   DUR_8TH);      // D4
            7'd15: data <= note(C4,   DUR_QUARTER);  // C4 (longer ending)

            // Padding with rests for remaining addresses
            default: data <= note(REST, DUR_QUARTER);
        endcase
    end

    //-------------------------------------------------------------------------
    // Melody length output for sequencer
    //-------------------------------------------------------------------------
    // The actual melody ends at address 15 (16 notes total)

endmodule
