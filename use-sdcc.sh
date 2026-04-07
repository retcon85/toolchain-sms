# call base to switch SDCC version
use-sdcc-base $1

# switches symlinked devkitsms version to match
if [ "$1" = "4.3" ] || [ "$1" = "4.4" ] || [ "$1" = "4.5" ]; then
  rm -f /opt/devkitsms
  ln -s /opt/devkitsms-$1 /opt/devkitsms
else
  echo "Version '$1' not supported. Specify one of 4.3, 4.4, 4.5"
  exit 1
fi
