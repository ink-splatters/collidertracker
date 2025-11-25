(
// Configure for ALSA output
"Configuring server...".postln;
s.options.sampleRate = 48000;
s.options.memSize = 8192;
s.options.numOutputBusChannels = 2;
s.options.numInputBusChannels = 0;
s.options.blockSize = 512;
s.options.verbosity = 1;
"Booting server...".postln;
s.boot;
s.waitForBoot {
    "Server booted successfully!".postln;
    Routine({
        loop {
            {
                var freq = 60.midicps * [1, 1.25, 1.5, 2].choose;
                var sig = SinOsc.ar(freq, 0, 0.2) + Saw.ar(freq * 0.5, 0.15);
                sig = LPF.ar(sig, LFNoise1.kr(0.5).range(300,1200));
                sig = sig * EnvGen.kr(Env.perc(0.01,1), doneAction:2);
                Out.ar(0, sig!2);
            }.play;
            0.4.wait;
        }
    }).play;
};
)
