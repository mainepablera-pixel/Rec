# voice-enhance

Turns raw phone voice clips into polished voice-over clips using GitHub Actions.
You click one button. You do not install anything or write any code.

## Run it
1. Create a **private** GitHub repo (keeps your voice clips private).
2. Upload everything from this folder. `enhance.yml` must stay at `.github/workflows/enhance.yml`.
3. Open the **Actions** tab, choose **Enhance voice clips**, tap **Run workflow**.
4. When it finishes, open the run and download the **enhanced-clips** artifact.

## What you get
Four versions of every clip, all leveled to the same loudness (-16 LUFS, peaks under -1.5 dB).
Compare them by ear and keep the best one per clip:

| Label | What it is |
|---|---|
| `D_original_finish` | Your original + voice-over finishing EQ/compression only (no AI) |
| `A_enhance` | AI denoise + enhance, leveled only |
| `B_denoise_finish` | AI denoise only + finishing chain |
| `C_enhance_finish` | AI denoise + enhance + finishing chain (usually the best bet) |

The finishing chain targets the "mouth too close to the phone mic" sound: it reduces
proximity-effect boom, boxy tone, harsh phone-mic frequencies, and sibilance, then
adds clarity and smooth compression. Silence and clip length are never changed.

## Notes
- Runs on GitHub's CPU servers, so it can take a while.
- Only the ffmpeg parts were tested. The AI step (Resemble Enhance) was not run
  during development. If a step fails, open it in the run log and send the error to Claude.
- Studio-grade results also depend on the recording. A hand-span from the mic, slightly
  off to the side, in a soft quiet room, makes the biggest difference.
