# This script is a helpful utility for making offical builds only - for personal builds, we recommend using a different tag to avoid confusion.

PLATFORM=linux/arm64,linux/amd64

docker build -t retcon85/toolchain-sms:$(cat version)-bookworm --build-arg BASE_VARIANT="bookworm" --platform=$PLATFORM .
docker tag retcon85/toolchain-sms:$(cat version)-bookworm retcon85/toolchain-sms:bookworm
docker tag retcon85/toolchain-sms:$(cat version)-bookworm retcon85/toolchain-sms:$(cat version)
docker tag retcon85/toolchain-sms:$(cat version) retcon85/toolchain-sms:latest

docker build -t retcon85/toolchain-sms:$(cat version)-slim-bookworm --build-arg BASE_VARIANT="slim-bookworm" --platform=$PLATFORM .
docker tag retcon85/toolchain-sms:$(cat version)-slim-bookworm retcon85/toolchain-sms:$(cat version)-slim
docker tag retcon85/toolchain-sms:$(cat version)-slim-bookworm retcon85/toolchain-sms:slim
