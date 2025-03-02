# This script is a helpful utility for making offical builds only - for personal builds, we recommend using a different tag to avoid confusion.

docker build -t retcon85/toolchain-sms:$(cat version) --platform=linux/amd64,linux/arm64 .
docker tag retcon85/toolchain-sms:$(cat version) retcon85/toolchain-sms:latest
