import numpy as np
import numpy.fft as fft
import scipy.signal as signal
import pydub
import matplotlib.pyplot as plt

def read(f, normalized=False, fmt="mp3"):
    """MP3 to numpy array"""
    a = pydub.AudioSegment.from_file(f, fmt)
    y = np.array(a.get_array_of_samples())
    if a.channels == 2:
        y = y.reshape((-1, 2))
    if normalized:
        return a.frame_rate, np.float32(y) / 2**15
    else:
        return a.frame_rate, y

def write(f, sr, x, normalized=False):
    """numpy array to MP3"""
    channels = 2 if (x.ndim == 2 and x.shape[1] == 2) else 1
    if normalized:  # normalized array - each item should be a float in [-1, 1)
        y = np.int16(x * 2 ** 15)
    else:
        y = np.int16(x)
    song = pydub.AudioSegment(y.tobytes(), frame_rate=sr, sample_width=2, channels=channels)
    song.export(f)
    #song.export(f, bitrate="320k")

def round_up_div(dividend, divisor):
    return (dividend + divisor - 1) // dividend

def process(mp3_1, mp3_2, ratio=0.5, fmt="mp3"):
    assert(ratio >= 0)
    assert(ratio <= 1)
    rate1, sound1 = read(mp3_1, True, fmt)
    if sound1.ndim == 2:
        sound1 = sound1[:, 0]
    rate2, sound2 = read(mp3_2, True, fmt)
    if sound2.ndim == 2:
        sound2 = sound2[:, 0]
    assert(rate1 == rate2)
    rate = rate1
    
    if sound1.shape[0] < sound2.shape[0]:
        sound1, sound2 = sound2, sound1
    
    limit_freq = 8000
    
    filter = signal.firwin(400, limit_freq, fs=rate)
    sound1 = signal.convolve(sound1, filter)
    sound2 = signal.convolve(sound2, filter)
    
    corr = np.abs(signal.convolve(sound1, sound2[::-1], mode='full'))
    location = (np.argmax(corr) - sound2.shape[0])

    plt.figure()
    plt.plot(corr)
    
    print(location, sound1.shape[0], sound2.shape[0])
    if location >= 0:
        aligned1 = sound1[location:]
        if aligned1.shape[0] > sound2.shape[0]:
            aligned1 = aligned1[:sound2.shape[0]]
            aligned2 = sound2
        else:
            aligned2 = sound2[:aligned1.shape[0]]
    else:
        aligned2 = sound2[-location:]
        aligned1 = sound1[:aligned2.shape[0]]
    
    result = ratio * aligned1 + (1 - ratio) * aligned2
    '''
    fftsize = 1024
    np.pad(result, (0, round_up_div(result.shape[0], fftsize)*fftsize), "constant")
    avg_spectrum = np.zeros(fftsize, dtype='complex128')
    energies = []
    threshold = 500
    magnitudes = []
    for i in range(result.shape[0] // fftsize):
        fftseg = fft.fft(result[i * fftsize:(i+1)*fftsize])
        energy = np.sum(np.square(np.abs(fftseg)))
        magnitudes.append(np.angle(fftseg))
        if energy < threshold:
            avg_spectrum += fftseg
    avg_spectrum /= result.shape[0] // fftsize
    plt.figure()
    plt.plot(np.abs(fft.fftshift(avg_spectrum)))

    noise = np.abs(avg_spectrum)

    for i in range(result.shape[0] // fftsize):
        fftseg = fft.fft(result[i * fftsize:(i+1)*fftsize])
        angle = np.angle(fftseg)
        cleaned = fft.ifft(np.clip(np.abs(fftseg) - noise, 0, None)*np.exp(1j*angle))
        result[i * fftsize:(i+1)*fftsize] = np.real(cleaned)
    '''
    result = signal.wiener(result)
    result_avg = np.mean(result)
    desired_avg = np.max((np.mean(aligned1), np.mean(aligned2)))
    result *= desired_avg / result_avg
    
    with open("output.wav", "wb") as f:
        write(f, rate, result, True)
    plt.show()

with open("file3.wav", "rb") as f1:
    with open("file4.wav", "rb") as f2:
        process(f1, f2, fmt="wav")
