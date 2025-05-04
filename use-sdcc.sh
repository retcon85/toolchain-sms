# switches symlinked SDCC version
if [ "$1" = "4.3" ] || [ "$1" = "4.4" ] || [ "$1" = "4.5" ]; then
  rm -f /opt/sdcc
  ln -s /opt/sdcc-$1 /opt/sdcc
else
  echo "Version '$1' not supported. Specify one of 4.3, 4.4, 4.5"
  exit 1
fi
