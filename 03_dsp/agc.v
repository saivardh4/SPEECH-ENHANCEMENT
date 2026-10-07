// Simple peak-based AGC.
// This is an educational FPGA implementation, not a clinical hearing-aid AGC.
module agc #(
    parameter integer SAMPLE_WIDTH = 16,
    parameter integer TARGET = 12000,
    parameter integer MAX_GAIN_Q8 = 768,  // 3.0x
    parameter integer MIN_GAIN_Q8 = 128   // 0.5x
)(
    input  wire clk,
    input  wire reset_n,
    input  wire signed [SAMPLE_WIDTH-1:0] sample_in,
    input  wire sample_valid,
    output reg signed [SAMPLE_WIDTH-1:0] sample_out,
    output reg out_valid
);
    reg [31:0] magnitude;
    reg [31:0] gain_q8;
    reg signed [47:0] scaled;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            gain_q8 <= 256; // 1.0x
            sample_out <= 0;
            out_valid <= 0;
        end else begin
            out_valid <= 0;
            if (sample_valid) begin
                magnitude = (sample_in < 0) ? -sample_in : sample_in;

                if (magnitude > TARGET && gain_q8 > MIN_GAIN_Q8)
                    gain_q8 <= gain_q8 - 1;
                else if (magnitude < TARGET/2 && gain_q8 < MAX_GAIN_Q8)
                    gain_q8 <= gain_q8 + 1;

                scaled = sample_in * gain_q8;
                if ((scaled >>> 8) > 32767)
                    sample_out <= 16'sd32767;
                else if ((scaled >>> 8) < -32768)
                    sample_out <= -16'sd32768;
                else
                    sample_out <= scaled >>> 8;

                out_valid <= 1'b1;
            end
        end
    end
endmodule
