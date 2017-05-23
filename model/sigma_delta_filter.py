import math

import numpy as np
import matplotlib.pyplot as plt


class SigmaDeltaModulator(object):
    def __init__(self, *args, **kwargs):

        self.sample_rate = 44100.0
        self.cycle = 0

        self.oversample = 256

        self.right = []
        self.left = []

        # Modulated bitstream
        self.right_modulated = []
        self.left_modulated = []

        self.MSB = 16
        self.MSBI = self.MSB - 1

        self.func_gen = self.sine_gen_binary

        # Modulator registers
        self.DeltaAdder = None
        self.SigmaAdder = None

        # Initial sigma value
        self.SigmaLatch = '10'
        for i in range(self.MSB):
            self.SigmaLatch += '0'

        self.DeltaB = '11'
        for i in range(self.MSB):
            self.DeltaB += '0'

    def run(self, clock_cycles=100, freq=500):
        # Run the modulator for n clock_cycles with a sine signal generator
        # at frequency freq
        for i in range(clock_cycles):
            self.step(freq)

    @property
    def time(self):
        return float(self.cycle)/float(self.sample_rate)

    def step(self, freq, sample=None):
        if sample:
            self.right.append(sample)
            self.left.append(sample)
        else:
            self.right.append(self.func_gen(self.cycle, freq))
            # self.left.append(self.func_gen(self.cycle, freq))

        # Invert sign bit
        DAC_in = self.right[-1]
        DAC_in = '1' if DAC_in[0] == '0' else '0'
        for i in range(self.MSB-1):
            DAC_in += self.right[-1][i+1]

        for i in range(self.oversample):
            self.right_modulated.append(self.modulate(DAC_in))

        self.cycle += 1

    def modulate(self, DAC_in):
        # Modulate the value, which is 2s complement bitstring format of
        # length MSB .e.g. '0000000000000001' == 1

        SigmaLatch = self.SigmaLatch

        self.DeltaB = '{}{}'.format(SigmaLatch[0], SigmaLatch[0])
        for i in range(self.MSB):
            self.DeltaB += '0'

        self.DeltaAdder = self.int_to_binary(
            int(DAC_in, 2) + int(self.DeltaB, 2),
            width=self.MSB+2)

        self.SigmaAdder = self.int_to_binary(
            int(self.DeltaAdder, 2) + int(SigmaLatch, 2),
            width=self.MSB+2)

        self.SigmaLatch = self.SigmaAdder

        return int(self.SigmaLatch[0])

    def sine_gen(self, t, freq):

        float_value = math.sin(((float(t)/float(self.sample_rate))*float(freq))*(2*math.pi))

        return float_value

    def sine_gen_binary(self, t, freq):

        float_value = math.sin(((float(t)/float(self.sample_rate))*float(freq))*(2*math.pi))

        # Normalize from -2^MSBI to 2^MSBI
        val = int(float_value*math.pow(2, self.MSBI))

        return self.int_to_binary(val)

    def binary_to_float(self, binary):
        val = int(binary, 2)

        if val >= math.pow(2, self.MSBI):
            val = val - math.pow(2, self.MSB)

        return float(val/math.pow(2, self.MSBI))

    def int_to_binary(self, num, width=None):
        if not width:
            width = self.MSB

        if num < 0:
            num = int(math.pow(2, width) + num)

        format_str = '0{}b'.format(width)
        return format(num, format_str)[-width:]

    def plot(self, values=None):
        if not values:
            values = self.right

        Fs = self.sample_rate
        Ts = 1.0/Fs  # sampling interval
        t = np.arange(0, 1, Ts)  # time vector

        t = np.array(t[0:len(values)])
        y = np.array(values)

        n = len(y)  # length of the signal
        k = np.arange(n)
        T = n/Fs
        frq = k/T  # two sides frequency range
        frq = frq[range(n/2)]  # one side frequency range

        Y = np.fft.fft(y)/n  # fft computing and normalization
        Y = Y[range(n/2)]

        fig, ax = plt.subplots(2, 1)
        ax[0].plot(t, y)
        ax[0].set_xlabel('Time')
        ax[0].set_ylabel('Amplitude')
        ax[1].plot(frq, abs(Y), 'r')  # plotting the spectrum
        ax[1].set_xlabel('Freq (Hz)')
        ax[1].set_ylabel('|Y(freq)|')

        plt.show()

    def plot_bitstream(self, values=None):
        if not values:
            values = self.right_modulated

        Fs = self.sample_rate
        sample_time = float(len(values))/(Fs * self.oversample)
        Ts = 1.0/(Fs * self.oversample)  # sampling interval
        t = np.arange(0, sample_time, Ts)  # time vector

        t = np.array(t[0:len(values)])
        y = np.array(values)

        n = len(y)  # length of the signal
        k = np.arange(n)
        T = n/Fs
        frq = k/T  # two sides frequency range
        frq = frq[range(n/2)]  # one side frequency range

        Y = np.fft.fft(y)/n  # fft computing and normalization
        Y = Y[range(n/2)]

        fig, ax = plt.subplots(2, 1)
        ax[0].plot(t, y)
        ax[0].set_xlabel('Time')
        ax[0].set_ylabel('Amplitude')
        ax[1].plot(frq, abs(Y), 'r')  # plotting the spectrum
        ax[1].set_xlabel('Freq (Hz)')
        ax[1].set_ylabel('|Y(freq)|')

        plt.show()
