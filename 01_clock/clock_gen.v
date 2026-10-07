// Generic clock/reset wrapper.
// NOTE: For DE2-115 hardware, replace this with the actual PLL/divider
// required by the board clock and WM8731 audio clocking scheme.
module clock_gen #(
    parameter integer DIVIDE = 1
)(
    input  wire clk_in,
    input  wire reset_n,
    output wire clk_out,
    output wire reset
);
    reg [31:0] count;
    reg clk_r;

    always @(posedge clk_in or negedge reset_n) begin
        if (!reset_n) begin
            count <= 0;
            clk_r <= 1'b0;
        end else if (DIVIDE <= 1) begin
            clk_r <= clk_in;
        end else if (count == DIVIDE-1) begin
            count <= 0;
            clk_r <= ~clk_r;
        end else begin
            count <= count + 1'b1;
        end
    end

    assign clk_out = (DIVIDE <= 1) ? clk_in : clk_r;
    assign reset   = ~reset_n;
endmodule
