"""Reproducible original synth cues; Python standard library, no source recordings."""
from pathlib import Path
import math, random, struct, wave
DEST = Path(__file__).resolve().parents[1] / 'runtime/audio/sfx'
RATE = 44100

def synth(kind, variant):
    rng = random.Random(2300 + variant)
    duration = {'bow_release': .16, 'arrow_hit': .13, 'enemy_defeat': .29}[kind]
    samples, phase, low_noise = [], 0.0, 0.0
    for i in range(int(RATE * duration)):
        t = i / RATE
        noise = rng.uniform(-1, 1)
        low_noise = .75 * low_noise + .25 * noise
        if kind == 'bow_release':
            freq = (430 + variant * 32) * math.exp(-t * 4)
            phase += 2 * math.pi * freq / RATE
            value = (math.sin(phase) + .28 * math.sin(phase * 2.01)) * math.exp(-t * 28)
            value += noise * .22 * math.exp(-t * 85)
        elif kind == 'arrow_hit':
            freq = (220 + variant * 18) * math.exp(-t * 12)
            phase += 2 * math.pi * freq / RATE
            value = .65 * math.sin(phase) * math.exp(-t * 36) + low_noise * 1.8 * math.exp(-t * 48)
        else:
            freq = 360 + variant * 25 - 230 * t / duration + 25 * math.sin(t * 65)
            phase += 2 * math.pi * freq / RATE
            value = .65 * math.sin(phase) * math.exp(-t * 11) + low_noise * .8 * math.exp(-t * 22)
        fade = min(1, t / .002, (duration - t) / .012)
        samples.append(value * max(0, fade))
    peak = max(abs(x) for x in samples)
    return [int(x / peak * .55 * 32767) for x in samples]

if __name__ == '__main__':
    DEST.mkdir(parents=True, exist_ok=True)
    for kind in ['bow_release', 'arrow_hit', 'enemy_defeat']:
        for variant in range(1, 4):
            path = DEST / f'{kind}_{variant:02}.wav'
            with wave.open(str(path), 'wb') as f:
                f.setparams((1, 2, RATE, 0, 'NONE', 'not compressed'))
                samples = synth(kind, variant)
                f.writeframes(struct.pack('<' + 'h' * len(samples), *samples))
            print(path.name)
