module bitrev (
	input  sck,
	input  ss,
	input  mosi,
	output miso
);
	// parameter	Idle=5'b00000,
	// 			Inp0=5'b00001,
	// 			Inp1=5'b00010,
	// 			Inp2=5'b00011,
	// 			Inp3=5'b00100,
	// 			Inp4=5'b00101,
	// 			Inp5=5'b00110,
	// 			Inp6=5'b00111,
	// 			I7O0=5'b01000,//两个上升沿会打架，就同时收发，直接双工
	// 			Out1=5'b01001,
	// 			Out2=5'b01010,
	// 			Out3=5'b01011,
	// 			Out4=5'b01100,
	// 			Out5=5'b01101,
	// 			Out6=5'b01110,
	// 			Out7=5'b01111,
	// 			Done=5'b10000;
	typedef enum logic [4:0] {Idle,Inp0,Inp1,Inp2,Inp3,Inp4,Inp5,Inp6,I7O0,Out1,Out2,Out3,Out4,Out5,Out6,Out7,Done} bitrevEnum;
	logic [6:0] data;
	bitrevEnum state;
	logic out;
	always @(posedge sck or posedge ss)begin//异步复位
		if(ss | (state==Done)) state<=Idle;
		else state<=(state>=Done)?Done:bitrevEnum'(state+5'b1);
	end
	always @(posedge sck)begin
		if(state == (Inp0-1)) data[0] <= mosi;
		if(state == (Inp1-1)) data[1] <= mosi;
		if(state == (Inp2-1)) data[2] <= mosi;
		if(state == (Inp3-1)) data[3] <= mosi;
		if(state == (Inp4-1)) data[4] <= mosi;
		if(state == (Inp5-1)) data[5] <= mosi;
		if(state == (Inp6-1)) data[6] <= mosi;
	end
	assign miso = out;
	always @(*) case(state)
		I7O0	:out=mosi;
		Out1	:out=data[6];
		Out2	:out=data[5];
		Out3	:out=data[4];
		Out4	:out=data[3];
		Out5	:out=data[2];
		Out6	:out=data[1];
		Out7	:out=data[0];
		default	:out=1;
	endcase
endmodule
