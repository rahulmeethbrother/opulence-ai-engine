FROM jrottenberg/ffmpeg:9-nvidia

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    VIDEO_CODEC=h264_nvenc

RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 python3-pip fonts-noto-cjk \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY requirements.txt .
RUN python3 -m pip install --upgrade pip && python3 -m pip install -r requirements.txt

COPY . .
RUN python3 -m playwright install --with-deps chromium

RUN mkdir -p /app/downloads
EXPOSE 8000
ENTRYPOINT []
CMD ["python3", "app.py"]
