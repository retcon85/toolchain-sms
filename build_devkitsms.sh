mkdir -p /tmp/devkitsms-${1}/bin
mkdir -p /tmp/devkitsms-${1}/lib
mkdir -p /tmp/devkitsms-${1}/include
cd ihx2sms
rm -rf build
mkdir build
gcc -o build/ihx2sms src/ihx2sms.c
cp build/ihx2sms /tmp/devkitsms-${1}/bin
cd ../makesms
rm -rf build
mkdir build
gcc -o build/makesms src/makesms.c
cp build/makesms /tmp/devkitsms-${1}/bin
cd ../folder2c
rm -rf build
mkdir build
gcc -o build/folder2c src/folder2c.c
cp build/folder2c /tmp/devkitsms-${1}/bin
cd ..
cp assets2banks/src/assets2banks.py /tmp/devkitsms-${1}/bin/assets2banks
chmod +x /tmp/devkitsms-${1}/bin/assets2banks
mkdir -p /tmp/devkitsms-${1}/lib
mkdir -p /tmp/devkitsms-${1}/include
cd crt0
rm *.rel
cd src
make clean
make
cd ../..
cp crt0/src/*.rel /tmp/devkitsms-${1}/lib
cd SMSlib
rm *.lib
cd src
make clean
make
cd ../..
cp SMSlib/src/*.lib /tmp/devkitsms-${1}/lib
cp SMSlib/src/*.h /tmp/devkitsms-${1}/include
cp SMSlib/src/peep-rules.txt /tmp/devkitsms-${1}/lib
cd SGlib
rm *.lib
cd src
make clean
make
cd ../..
cp SGlib/src/*.lib /tmp/devkitsms-${1}/lib
cp SGlib/src/*.h /tmp/devkitsms-${1}/include
cd PSGlib
rm *.lib
cd src
make clean
make
cd ../..
cp PSGlib/src/*.lib /tmp/devkitsms-${1}/lib
cp PSGlib/src/*.h /tmp/devkitsms-${1}/include
