y8asm: y8.lex.c y8.tab.c instruction_nodes.c instruction_nodes.h 
	/usr/local/Cellar/gcc/13.2.0/bin/gcc-13 -o y8asm y8.lex.c y8.tab.c instruction_nodes.c 
        
y8.lex.c: y8asm.l y8.tab.c
	flex -o y8.lex.c y8asm.l
             
y8.tab.c: y8asm.y
	/usr/local/Cellar/bison/3.8.2/bin/bison -o y8.tab.c -vd y8asm.y

clean: 
	rm y8.lex.c y8.tab.c y8.tab.h y8.output

test:
	./y8asm < tb/all.y8 | sed -e '/^\(0x\)/!d; s/^\([0-9A-Fx:]*\t[0-9xA-F ]*\t*\)\{0,1\}\(.*\)/\2/;' > res.txt
