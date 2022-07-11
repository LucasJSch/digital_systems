import os
import math
import csv
import numpy as np

MAX_ANGLE = math.pi / 2.0
MIN_ANGLE = - math.pi / 2.0
N_SAMPLES = 1000
# 1 for sign, 1 for overflow.
# Thus 2**(N_BITS_ANGLE-2) is equivalent to 45 degrees.
N_BITS_ANGLE = 17
VECTOR_LENGTH = 4096.0
CORDIC_GAIN = 1.647

cwd = os.getcwd()

with open(cwd + '/testdata.txt', 'w', encoding='UTF8') as f:
    writer = csv.writer(f, delimiter=' ')
    writer.writerow(['x_i', 'y_i', 'beta', 'x_o', 'y_o'])

    for i in np.linspace(start=MIN_ANGLE, stop=MAX_ANGLE, num=N_SAMPLES):
        x = int(CORDIC_GAIN * VECTOR_LENGTH * math.cos(i))
        y = int(CORDIC_GAIN * VECTOR_LENGTH * math.sin(i))
        beta = (180.0 * i / math.pi) * (2**(N_BITS_ANGLE-2)) / 45.0
        writer.writerow([4096, 0, int(beta), x, y])