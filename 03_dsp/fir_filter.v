// 49-tap FIR using the supplied fixed-point coefficients.
// Coefficient scale: Q15 (32768 = 1.0).
module fir_filter #(
    parameter integer SAMPLE_WIDTH = 16,
    parameter integer COEFF_WIDTH  = 16,
    parameter integer TAPS = 49
)(
    input  wire clk,
    input  wire reset_n,
    input  wire signed [SAMPLE_WIDTH-1:0] sample_in,
    input  wire sample_valid,
    output reg signed [SAMPLE_WIDTH-1:0] sample_out,
    output reg out_valid
);
    reg signed [SAMPLE_WIDTH-1:0] delay [0:TAPS-1];
    reg signed [COEFF_WIDTH-1:0] coeff [0:TAPS-1];
    reg signed [47:0] acc;
    integer i;

    initial begin
        coeff[0]  = -16'sd58;   coeff[1]  = -16'sd69;  coeff[2]  = -16'sd77;
        coeff[3]  = -16'sd79;   coeff[4]  = -16'sd68;  coeff[5]  = -16'sd40;
        coeff[6]  =  16'sd4;    coeff[7]  =  16'sd52;  coeff[8]  =  16'sd80;
        coeff[9]  =  16'sd62;   coeff[10] = -16'sd28;  coeff[11] = -16'sd201;
        coeff[12] = -16'sd446;  coeff[13] = -16'sd720; coeff[14] = -16'sd956;
        coeff[15] = -16'sd1067; coeff[16] = -16'sd973; coeff[17] = -16'sd615;
        coeff[18] =  16'sd23;   coeff[19] =  16'sd899; coeff[20] = 16'sd1920;
        coeff[21] =  16'sd2948; coeff[22] =  16'sd3830; coeff[23] = 16'sd4425;
        coeff[24] =  16'sd4635; coeff[25] =  16'sd4425; coeff[26] = 16'sd3830;
        coeff[27] =  16'sd2948; coeff[28] =  16'sd1920; coeff[29] = 16'sd899;
        coeff[30] =  16'sd23;   coeff[31] = -16'sd615; coeff[32] = -16'sd973;
        coeff[33] = -16'sd1067; coeff[34] = -16'sd956; coeff[35] = -16'sd720;
        coeff[36] = -16'sd446;  coeff[37] = -16'sd201; coeff[38] = -16'sd28;
        coeff[39] =  16'sd62;   coeff[40] =  16'sd80;   coeff[41] = 16'sd52;
        coeff[42] =  16'sd4;    coeff[43] = -16'sd40;   coeff[44] = -16'sd68;
        coeff[45] = -16'sd79;   coeff[46] = -16'sd77;   coeff[47] = -16'sd69;
        coeff[48] = -16'sd58;
    end

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            sample_out <= 0;
            out_valid <= 0;
            for (i=0; i<TAPS; i=i+1) delay[i] <= 0;
        end else begin
            out_valid <= 1'b0;
            if (sample_valid) begin
                for (i=TAPS-1; i>0; i=i-1)
                    delay[i] <= delay[i-1];
                delay[0] <= sample_in;

                acc = 0;
                for (i=0; i<TAPS; i=i+1)
                    acc = acc + delay[i] * coeff[i];

                // Q15 coefficient scaling.
                sample_out <= acc >>> 15;
                out_valid <= 1'b1;
            end
        end
    end
endmodule
