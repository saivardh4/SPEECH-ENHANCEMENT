`timescale 1ns/1ps

module hearing_aid_tb;
    reg clk;
    reg reset_n;
    reg signed [15:0] audio_in;
    reg signed [15:0] noise_reference;
    reg audio_valid;

    wire signed [15:0] audio_out;
    wire audio_valid_out;
    wire speech_active;

    hearing_aid_top dut (
        .clk(clk),
        .reset_n(reset_n),
        .audio_in(audio_in),
        .audio_valid(audio_valid),
        .noise_reference(noise_reference),
        .audio_out(audio_out),
        .audio_valid_out(audio_valid_out),
        .speech_active(speech_active)
    );

    always #5 clk = ~clk;

    integer k;
    initial begin
        clk = 0;
        reset_n = 0;
        audio_in = 0;
        noise_reference = 0;
        audio_valid = 0;

        #100;
        reset_n = 1;

        // Simple synthetic samples for initial waveform checking.
        for (k = 0; k < 300; k = k + 1) begin
            @(posedge clk);
            audio_valid <= 1'b1;
            audio_in <= (k % 40 < 20) ? 16'sd5000 : -16'sd5000;
            noise_reference <= (k % 10 < 5) ? 16'sd800 : -16'sd800;
        end

        @(posedge clk);
        audio_valid <= 0;
        #500;
        $stop;
    end

    always @(posedge clk) begin
        if (audio_valid_out)
            $display("t=%0t in=%0d out=%0d speech=%b",
                     $time, audio_in, audio_out, speech_active);
    end
endmodule
