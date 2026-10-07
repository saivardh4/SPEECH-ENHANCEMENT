// 32-tap LMS-style adaptive noise canceller.
// Coefficients use Q15. mu_q15 is the fixed-point adaptation step.
// This is a hardware-oriented starter; verify convergence against MATLAB/Octave.
module lms_filter #(
    parameter integer SAMPLE_WIDTH = 16,
    parameter integer TAPS = 32,
    parameter integer MU_Q15 = 33,
    parameter integer ADAPT_ENABLE = 1
)(
    input  wire clk,
    input  wire reset_n,
    input  wire signed [SAMPLE_WIDTH-1:0] desired_in,
    input  wire signed [SAMPLE_WIDTH-1:0] reference_in,
    input  wire sample_valid,
    output reg signed [SAMPLE_WIDTH-1:0] sample_out,
    output reg out_valid
);
    reg signed [SAMPLE_WIDTH-1:0] x [0:TAPS-1];
    reg signed [15:0] w [0:TAPS-1];
    reg signed [31:0] y_acc;
    reg signed [31:0] err;
    reg signed [47:0] update_acc;
    integer i;

    initial begin
        // Start from zero to match the supplied Octave LMS algorithm.
        for (i=0; i<TAPS; i=i+1) w[i] = 0;
    end

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            sample_out <= 0;
            out_valid <= 0;
            for (i=0; i<TAPS; i=i+1) begin
                x[i] <= 0;
                w[i] <= 0;
            end
        end else begin
            out_valid <= 1'b0;
            if (sample_valid) begin
                for (i=TAPS-1; i>0; i=i-1)
                    x[i] <= x[i-1];
                x[0] <= reference_in;

                y_acc = 0;
                for (i=0; i<TAPS; i=i+1)
                    y_acc = y_acc + ((x[i] * w[i]) >>> 15);

                err = desired_in - y_acc;

                // Output is the error signal, i.e. enhanced/noise-reduced signal.
                sample_out <= err[SAMPLE_WIDTH-1:0];
                out_valid <= 1'b1;

                if (ADAPT_ENABLE) begin
                    for (i=0; i<TAPS; i=i+1) begin
                        update_acc = w[i] + ((MU_Q15 * err * x[i]) >>> 30);
                        if (update_acc > 32767)
                            w[i] <= 16'sd32767;
                        else if (update_acc < -32768)
                            w[i] <= -16'sd32768;
                        else
                            w[i] <= update_acc[15:0];
                    end
                end
            end
        end
    end
endmodule
