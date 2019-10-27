import numpy as np
import scipy as sp
import pydub

def read_mp3(f, normalized=False, format="mp3"):
    """MP3 to numpy array"""
    a = pydub.AudioSegment.from_file(f, format)
    y = np.array(a.get_array_of_samples())
    if a.channels == 2:
        y = y.reshape((-1, 2))
    if normalized:
        return a.frame_rate, np.float32(y) / 2**15
    else:
        return a.frame_rate, y

def write(f, sr, x, normalized=False, format="mp3"):
    """numpy array to MP3"""
    channels = 2 if (x.ndim == 2 and x.shape[1] == 2) else 1
    if normalized:  # normalized array - each item should be a float in [-1, 1)
        y = np.int16(x * 2 ** 15)
    else:
        y = np.int16(x)
    song = pydub.AudioSegment(y.tobytes(), frame_rate=sr, sample_width=2, channels=channels)
    song.export(f, format=format, bitrate="320k")

def process(mp3_1, mp3_2, ratio=0.5, format="mp3"):
	assert(ratio >= 0)
	assert(ratio <= 1)
	rate1, sound1 = read(mp3_1, True, format)
	if sound1.ndim == 2:
		sound1 = sound1[:, 0]
	rate2, sound2 = read(mp3_2, True, format)
	if sound2.ndim == 2:
		sound2 = sound1[:, 0]
	assert(rate1 == rate2)
	rate = rate1
	
	if sound1.shape[0] < sound2.shape[0]:
		sound1, sound2 = sound2, sound1
	
	limit_freq = 8000
	
	filter = sp.signal.firwin(400, limit_freq, fs=rate)
	sound1 = sp.signal.convolve(sound1, filter)
	sound2 = sp.signal.convolve(sound2, filter)
	
	corr = sp.signal.convolve(sound1, sound2[::-1])
	location = np.argmax(corr)
	
	
	
	result = ratio * aligned1 + (1 - ratio) * aligned2
	with open("output.mp3", "wb") as f:
		write(f, rate, result, True, format)