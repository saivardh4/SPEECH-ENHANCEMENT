// Simple energy/absolute-amplitude VAD with hangover.
// Outputs zero during detected non-speech segments.
module vad #(
    parameter integer SAMPLE_WIDTH = 16,
    parameter integer THRESHOLD = 1000,
    parameter integer HANGOVER = 2000
)(
    input  wire clk,
    input  wire reset_n,
    input  wire signed [SAMPLE_WIDTH-1:0] sample_in,
    input  wire sample_valid,
    output reg signed [SAMPLE_WIDTH-1:0] sample_out,
    output reg speech_active,
    output reg out_valid
);
    reg [31:0] mag;
    reg [31:0] hang_count;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            sample_out <= 0;
            speech_active <= 0;
            hang_count <= 0;
            out_valid <= 0;
        end else begin
            out_valid <= 0;
            if (sample_valid) begin
                mag = (sample_in < 0) ? -sample_in : sample_in;

                if (mag >= THRESHOLD) begin
                    speech_active <= 1'b1;
                    hang_count <= HANGOVER;
                end else if (hang_count != 0) begin
                    hang_count <= hang_count - 1;
                    speech_active <= 1'b1;
                end else begin
                    speech_active <= 1'b0;
                end

                if (speech_active || mag >= THRESHOLD)
                    sample_out <= sample_in;
                else
                    sample_out <= 0;

                out_valid <= 1'b1;
            end
        end
    end
endmodule
