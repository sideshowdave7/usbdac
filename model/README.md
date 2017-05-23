# Usage

from sigma_delta_filter import SigmaDeltaModulator

s = SigmaDeltaModulator()

s.run() # 100 clock cycles of 500 Hz sine wave

s.plot_bitstream()
