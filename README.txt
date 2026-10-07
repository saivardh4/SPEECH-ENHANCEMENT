HEARING AID FPGA - VERILOG STARTER PACKAGE
===========================================

Architecture
------------
WM8731 ADC -> I2S RX -> FIR -> LMS -> AGC -> VAD -> I2S TX -> WM8731 DAC

Included
--------
01_clock/clock_gen.v
02_codec/wm8731_i2c_config.v
02_codec/i2s_rx.v
02_codec/i2s_tx.v
03_dsp/fir_filter.v
03_dsp/lms_filter.v
03_dsp/agc.v
03_dsp/vad.v
04_control/hearing_aid_top.v
05_simulation/hearing_aid_tb.v

Important
---------
This package is a complete MODULE SET / starting architecture for the
academic project, but it is NOT yet a guaranteed DE2-115 hardware image.

The DE2-115 WM8731 hardware requires exact:
1. FPGA pin assignments
2. WM8731 I2C register configuration
3. audio clock generation
4. I2S BCLK/LRCLK timing and polarity
5. reset/power-up sequencing

Those board-specific values must be verified from the DE2-115 manual/schematic
before connecting the codec modules to physical pins.

DSP notes
---------
FIR uses the supplied 49 coefficients converted with round(b*32768).
LMS is a 32-tap adaptive implementation using Q15-style arithmetic.
The supplied LMS coefficients are final coefficients from the MATLAB/Octave
work; the RTL LMS starts from zero to match the learning procedure.
Therefore, RTL coefficients will not automatically equal the supplied final
list unless the fixed-point arithmetic and adaptation parameters are tuned
and verified against the reference model.

AGC and VAD are simple educational implementations and require simulation
and threshold tuning for the project recordings.

Recommended ModelSim order
---------------------------
1. Compile every .v file.
2. Simulate hearing_aid_tb.
3. Add audio_in, fir_out, lms_out, agc_out, audio_out and speech_active
   to the waveform (internal DUT signals can be expanded).
4. Check that valid pulses propagate through the chain.
5. Compare RTL output against the MATLAB/Octave reference.
6. Only after simulation is stable, integrate I2S and I2C.
7. Then create the Quartus top-level pin assignments for the DE2-115.

This package is for an academic speech-enhancement demonstration and is not
a medical/clinical hearing-aid design.
