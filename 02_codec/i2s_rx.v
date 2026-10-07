// I2S receiver skeleton.
// Receives serial audio data and presents one signed sample at a time.
// Verify WM8731 format, word length, LRCLK/BCLK polarity and timing
// against the DE2-115 documentation.
module i2s_rx #(
    parameter integer SAMPLE_WIDTH = 16
)(
    input  wire clk_bclk,
    input  wire reset_n,
    input  wire i2s_bclk,
    input  wire i2s_lrclk,
    input  wire i2s_din,
    output reg signed [SAMPLE_WIDTH-1:0] sample_left,
    output reg signed [SAMPLE_WIDTH-1:0] sample_right,
    output reg sample_valid
);
    reg [5:0] bit_count;
    reg signed [SAMPLE_WIDTH-1:0] shift_reg;
    reg lr_prev;

    always @(posedge i2s_bclk or negedge reset_n) begin
        if (!reset_n) begin
            bit_count    <= 0;
            shift_reg    <= 0;
            sample_left  <= 0;
            sample_right <= 0;
            sample_valid <= 1'b0;
            lr_prev      <= 1'b0;
        end else begin
            sample_valid <= 1'b0;
            shift_reg <= {shift_reg[SAMPLE_WIDTH-2:0], i2s_din};

            if (bit_count == SAMPLE_WIDTH-1) begin
                if (i2s_lrclk == 1'b0)
                    sample_left <= {shift_reg[SAMPLE_WIDTH-2:0], i2s_din};
                else
                    sample_right <= {shift_reg[SAMPLE_WIDTH-2:0], i2s_din};
                bit_count <= 0;
                if (i2s_lrclk != lr_prev)
                    sample_valid <= 1'b1;
            end else begin
                bit_count <= bit_count + 1'b1;
            end
            lr_prev <= i2s_lrclk;
        end
    end
endmodule
