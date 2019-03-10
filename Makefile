stringDecoder: stringDecoder.asm
	nasm -f elf32 -o stringDecoder.o $<
	gcc -m32 -o $@ stringDecoder.o

clean:
	rm -f stringDecoder stringDecoder.o
