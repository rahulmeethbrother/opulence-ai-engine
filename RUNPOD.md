# RunPod deployment

This repository can run as a RunPod GPU Pod using the included `Dockerfile`.
The image includes CUDA runtime libraries, FFmpeg, Python dependencies, Chromium,
and Playwright. GPU acceleration is available to dependencies that support CUDA;
MoviePy/FFmpeg rendering remains primarily CPU-bound unless explicitly configured
with an FFmpeg CUDA filter or encoder.

## Build and run

```bash
docker build -t vuza:latest .
docker run --gpus all --rm -p 8000:8000 vuza:latest
```

In RunPod, deploy the image as a GPU Pod, expose HTTP port `8000`, and open the
Pod's HTTP proxy URL. Set any API credentials through the RunPod environment or
secret mechanism. Do not commit `backend_secrets.json`, `.env`, or keys in image
layers.

The application writes generated media to `downloads/`. Attach persistent storage
if outputs must survive Pod replacement.

## Parallel jobs

`POST /api/scrape` returns a `job_id`. Poll `GET /api/status?job_id=<job_id>`.
The server accepts at most four active jobs and returns HTTP `429` when all four
slots are occupied. Existing clients may continue polling `/api/status`, which
returns the newest job.

This is an in-process limit. Run exactly one Uvicorn worker per Pod; multiple
workers each have their own job table and can exceed the four-job limit. For
multi-Pod or durable queues, use an external queue and persistent object storage.

## Health and operational limits

There is no authentication layer, durable queue, cancellation endpoint, or upload
API in this repository. Put the Pod behind an authenticated proxy before exposing
it publicly. Pinterest/stock providers, TTS, and configured AI APIs remain subject
to their own rate limits. Four simultaneous video jobs may exceed GPU/CPU/RAM or
disk capacity, so start with one or two and measure before using all four.
