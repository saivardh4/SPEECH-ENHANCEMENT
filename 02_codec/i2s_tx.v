// I2S transmitter skeleton.
// Presents one processed sample for left/right playback.
// Verify exact WM8731 I2S timing before hardware use.
module i2s_tx #(
    parameter integer SAMPLE_WIDTH = 16
)(
    input  wire clk_bclk,
    input  wire reset_n,
    input  wire i2s_bclk,
    input  wire i2s_lrclk,
    input  wire signed [SAMPLE_WIDTH-1:0] sample_left,
    input  wire signed [SAMPLE_WIDTH-1:0] sample_right,
    input  wire sample_valid,
    output reg i2s_dout
);
    reg [SAMPLE_WIDTH-1:0] tx_left, tx_right;
    reg [5:0] bit_count;
    reg lr_prev;

    always @(posedge i2s_bclk or negedge reset_n) begin
        if (!reset_n) begin
            tx_left  <= 0;
            tx_right <= 0;
            bit_count <= 0;
            lr_prev <= 0;
            i2s_dout <= 0;
        end else begin
            if (sample_valid) begin
                tx_left  <= sample_left;
                tx_right <= sample_right;
            end

            if (i2s_lrclk != lr_prev)
                bit_count <= 0;
            else if (bit_count < SAMPLE_WIDTH)
                bit_count <= bit_count + 1'b1;

            if (i2s_lrclk == 1'b0)
                i2s_dout <= tx_left[SAMPLE_WIDTH-1-bit_count];
            else
                i2s_dout <= tx_right[SAMPLE_WIDTH-1-bit_count];

            lr_prev <= i2s_lrclk;
        end
    end
endmodule
