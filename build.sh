# This script is a helpful utility for making offical builds only - for personal builds, we recommend using a different tag to avoid confusion.

PLATFORM=linux/arm64,linux/amd64
# PLATFORM=linux/arm64

# full debian builds -> ghcr.io
docker build -t ghcr.io/retcon85/toolchain-sms:$(cat version)-bookworm --build-arg BASE_VARIANT="bookworm" --platform=$PLATFORM .
docker tag ghcr.io/retcon85/toolchain-sms:$(cat version)-bookworm ghcr.io/retcon85/toolchain-sms:bookworm
docker tag ghcr.io/retcon85/toolchain-sms:$(cat version)-bookworm ghcr.io/retcon85/toolchain-sms:$(cat version)
docker tag ghcr.io/retcon85/toolchain-sms:$(cat version) ghcr.io/retcon85/toolchain-sms:latest

# slim debian builds -> ghcr.io
docker build -t ghcr.io/retcon85/toolchain-sms:$(cat version)-slim-bookworm --build-arg BASE_VARIANT="slim-bookworm" --platform=$PLATFORM .
docker tag ghcr.io/retcon85/toolchain-sms:$(cat version)-slim-bookworm ghcr.io/retcon85/toolchain-sms:$(cat version)-slim
docker tag ghcr.io/retcon85/toolchain-sms:$(cat version)-slim-bookworm ghcr.io/retcon85/toolchain-sms:slim
