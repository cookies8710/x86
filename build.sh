gcc -o boot.o -c boot.S && ld -o boot.bin --oformat binary --Ttext 0x7c00 boot.o
