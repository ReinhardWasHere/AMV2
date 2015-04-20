typedef enum bit [5:0]
	{
		Nop=6'b000000,
		Loadi=6'b000010,
		Jump=6'b001000,
		Jumpc=6'b001010,
		Jumpz=6'b001011,
		Move=6'b001100,
		And=6'b010000,
		Or=6'b010001,
		Xor=6'b010010,
		Not=6'b010011,
		Add=6'b010100,
		Addc=6'b010101,
		Sub=6'b010110,
		Subc=6'b010111,
		Comp=6'b011000,
		Inc=6'b011010,
		Dec=6'b011011,
		Shl=6'b011100,
		Shr=6'b011101,
		Shlc=6'b011110,
		Shrc=6'b011111
		//Invalid=6'b111111
	} Prol16Command;
