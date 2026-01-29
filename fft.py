import h5py
import numpy as np
import matplotlib.pyplot as plt

# กำหนดชื่อไฟล์
file_path = 'Velocity.mat'

# อ่านไฟล์ .mat (รองรับ format v7.3)
with h5py.File(file_path, 'r') as f:
    # อ้างอิงตามโครงสร้างไฟล์ที่วิเคราะห์ได้: ข้อมูลหลักอยู่ที่ #refs#/y
    y_data = f['#refs#/y'][()]
    signal = y_data.flatten()

# กำหนดพารามิเตอร์
fs = 1000  # Sampling Frequency = 1 KHz
N = len(signal)
time = np.arange(N) / fs

# คำนวณ FFT
fft_spectrum = np.fft.fft(signal)
L = N

# คำนวณ Single-Sided Spectrum
P2 = np.abs(fft_spectrum / L)
P1 = P2[:L//2+1]
P1[1:-1] = 2 * P1[1:-1]
f_freq = fs * np.arange(L//2+1) / L

# การพล็อตกราฟ
plt.figure(figsize=(12, 10))

# 1. กราฟสัญญาณในโดเมนเวลา (Time Domain)
plt.subplot(3, 1, 1)
plt.plot(time, signal)
plt.title('Time Domain Signal: Motor Angular Velocity')
plt.xlabel('Time (s)')
plt.ylabel('Velocity')
plt.grid(True)

# 2. กราฟสเปกตรัมความถี่แบบเต็ม (รวมค่า DC)
plt.subplot(3, 1, 2)
plt.plot(f_freq, P1)
plt.title('Single-Sided Amplitude Spectrum (Including DC)')
plt.xlabel('Frequency (Hz)')
plt.ylabel('|P1(f)|')
plt.grid(True)

# 3. กราฟสเปกตรัมความถี่แบบซูม (ตัดค่า DC ที่ 0 Hz ออกเพื่อให้เห็นความถี่อื่นชัดขึ้น)
plt.subplot(3, 1, 3)
plt.plot(f_freq[1:], P1[1:]) # เริ่ม plot จาก index ที่ 1 เพื่อข้าม DC component
plt.title('Single-Sided Amplitude Spectrum (DC Component Removed)')
plt.xlabel('Frequency (Hz)')
plt.ylabel('|P1(f)|')
plt.grid(True)

plt.tight_layout()
plt.show()