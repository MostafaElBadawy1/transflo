#!/usr/bin/env python3
"""Synthesizes placeholder Russian Roulette sounds into Transflo/Resources.

Replace any of them with a recorded sound under the same name: 16-bit PCM WAV, mono,
44.1 kHz, peak around -3 dBFS, no leading silence.

    cylinder_click.wav  30-60 ms   one ratchet step of the cylinder
    cylinder_lock.wav   80-150 ms  the heavier click as a chamber locks in the firing position
    empty_click.wav     100-200 ms a dry fire on an empty chamber
    gunshot.wav         300-600 ms a cartoonish shot with a short tail

The noise is seeded, so reruns produce identical files.
"""

import math
import random
import struct
import sys
import wave
from pathlib import Path

RATE = 44_100
PEAK = 10 ** (-3 / 20)


def envelope(t, attack, decay):
    return min(t / attack, 1.0) * math.exp(-t / decay) if attack > 0 else math.exp(-t / decay)


def click(rng, length, tone, decay, noise=0.6, attack=0.0005):
    samples = []
    for n in range(int(RATE * length)):
        t = n / RATE
        body = math.sin(2 * math.pi * tone * t) + 0.5 * math.sin(2 * math.pi * tone * 2.7 * t)
        samples.append(envelope(t, attack, decay) * ((1 - noise) * body + noise * rng.uniform(-1, 1)))
    return samples


def mix(*layers):
    length = max(len(layer) for _, layer in layers)
    out = [0.0] * length
    for offset, layer in layers:
        for n, value in enumerate(layer):
            if offset + n < length:
                out[offset + n] += value
    return out


def low_pass(samples, amount):
    out, last = [], 0.0
    for value in samples:
        last += amount * (value - last)
        out.append(last)
    return out


def normalize(samples):
    peak = max(abs(value) for value in samples) or 1
    return [value / peak * PEAK for value in samples]


def write(path, samples):
    with wave.open(str(path), "wb") as file:
        file.setnchannels(1)
        file.setsampwidth(2)
        file.setframerate(RATE)
        file.writeframes(b"".join(struct.pack("<h", int(value * 32_767)) for value in normalize(samples)))


def main():
    default = Path(__file__).resolve().parent.parent / "Transflo/Resources"
    resources = Path(sys.argv[1]) if len(sys.argv) > 1 else default
    rng = random.Random(1873)
    ms = RATE // 1000
    sounds = {
        "cylinder_click": click(rng, 0.045, 3_400, 0.006),
        "cylinder_lock": mix((0, click(rng, 0.12, 1_600, 0.018, noise=0.45)),
                             (12 * ms, click(rng, 0.06, 4_200, 0.008))),
        "empty_click": mix((0, click(rng, 0.05, 2_600, 0.007)),
                           (55 * ms, click(rng, 0.12, 1_200, 0.02, noise=0.5))),
        "gunshot": mix((0, low_pass(click(rng, 0.45, 70, 0.11, noise=0.85, attack=0.001), 0.25)),
                       (0, click(rng, 0.04, 900, 0.01, noise=0.9))),
    }
    for name, samples in sounds.items():
        write(resources / f"{name}.wav", samples)
        print(f"{name}.wav  {len(samples) / RATE * 1000:.0f} ms")


if __name__ == "__main__":
    main()
