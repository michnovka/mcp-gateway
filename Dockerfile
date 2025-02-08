FROM node:23-alpine

# Copy uv files
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

# Install system dependencies
RUN apk add --no-cache \
    docker-cli \
    python3 \
    py3-pip \
    openssl \
    libffi \
    ca-certificates \
    curl \
    ffmpeg \
    tini \
    coreutils

# Install yt-dlp
RUN curl -Lo /usr/local/bin/yt-dlp https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp \
    && chmod a+rx /usr/local/bin/yt-dlp \
    && mkdir -p /downloads /.cache \
    && chmod 777 /.cache \
    && chmod a+rw /downloads

VOLUME ["/downloads"]
WORKDIR /app

# Install dependencies first to cache them
COPY package*.json ./
RUN npm ci

# Copy source code
COPY tsconfig.json ./
COPY src/ ./src/

USER node
EXPOSE 3000

ENTRYPOINT ["tini", "--"]
CMD ["npm", "start"]
