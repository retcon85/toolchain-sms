# switches symlinked wla-dx version
if [ "$1" = "10.5" ] || [ "$1" = "10.6" ]; then
  rm -f /opt/wla-dx
  ln -s /opt/wla-dx-$1 /opt/wla-dx
else
  echo "Version '$1' not supported. Specify one of 10.5, 10.6"
  exit 1
fi
