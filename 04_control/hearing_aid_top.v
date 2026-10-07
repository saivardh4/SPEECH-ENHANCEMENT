// Top-level DSP demonstration chain:
// input sample -> FIR -> LMS -> AGC -> VAD -> output sample.
//
// CODEC/I2S pins are intentionally not hard-wired here because the exact
// DE2-115 pin assignments and WM8731 clock/configuration must be verified
// from the board documentation.
module hearing_aid_top (
    input  wire clk,
    input  wire reset_n,
    input  wire signed [15:0] audio_in,
    input  wire audio_valid,
    input  wire signed [15:0] noise_reference,
    output wire signed [15:0] audio_out,
    output wire audio_valid_out,
    output wire speech_active
);
    wire signed [15:0] fir_out;
    wire signed [15:0] lms_out;
    wire signed [15:0] agc_out;
    wire fir_valid, lms_valid, agc_valid, vad_valid;

    fir_filter u_fir (
        .clk(clk), .reset_n(reset_n),
        .sample_in(audio_in), .sample_valid(audio_valid),
        .sample_out(fir_out), .out_valid(fir_valid)
    );

    lms_filter u_lms (
        .clk(clk), .reset_n(reset_n),
        .desired_in(fir_out),
        .reference_in(noise_reference),
        .sample_valid(fir_valid),
        .sample_out(lms_out), .out_valid(lms_valid)
    );

    agc u_agc (
        .clk(clk), .reset_n(reset_n),
        .sample_in(lms_out), .sample_valid(lms_valid),
        .sample_out(agc_out), .out_valid(agc_valid)
    );

    vad u_vad (
        .clk(clk), .reset_n(reset_n),
        .sample_in(agc_out), .sample_valid(agc_valid),
        .sample_out(audio_out), .speech_active(speech_active),
        .out_valid(vad_valid)
    );

    assign audio_valid_out = vad_valid;
endmodule
