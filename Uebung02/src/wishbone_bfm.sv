class wishbone_bfm #(parameter int gDataWidth = 32, parameter int gAddrWidth = 8);
	virtual wishbone_if.master sigs;

	function new(virtual wishbone_if.master _sigs);
		sigs = _sigs;

		sigs.cb.adr <= 0;
		sigs.cb.datM <= 0;
		sigs.cb.we <= 0;
		sigs.cb.sel <= '0;
		sigs.cb.cyc <= 0;
		sigs.cb.stb <= 0;
	endfunction

	// ------------------------------------------------------------------------

	virtual task singleRead(input logic [gAddrWidth-1:0] addr, output logic [gDataWidth-1:0] data);
		$display("singleRead @%0tns", $time);
		sigs.cb.adr <= addr;
		sigs.cb.we <= 0;
		sigs.cb.sel <= '1;
		sigs.cb.cyc <= 1;
		sigs.cb.stb <= 1;
		
		@(posedge sigs.cb.ack)
		data = sigs.cb.datS;
		sigs.cb.stb = 0;
		sigs.cb.cyc = 0;		
	endtask

	// ------------------------------------------------------------------------

	virtual task singleWrite(input logic [gAddrWidth-1:0] addr, logic [gDataWidth-1:0] data);
		$display("singleWrite @%0tns", $time);
		sigs.cb.adr <= addr;
		sigs.cb.datM <= data;
		sigs.cb.we <= 1;
		sigs.cb.sel <= '1;
		sigs.cb.cyc <= 1;
		sigs.cb.stb <= 1;
		
		@(posedge sigs.cb.ack)
		sigs.cb.stb = 0;
		sigs.cb.cyc = 0;	
	endtask

	// ------------------------------------------------------------------------

	virtual task blockRead(input logic [gAddrWidth-1:0] addr, ref logic [gDataWidth-1:0] data[]);
		$display("blockRead @%0tns", $time);
		for (int i = 0; i < $size(data); i = i + 1) begin
			sigs.cb.adr <= addr;
			sigs.cb.we <= 0;
			sigs.cb.sel <= '1;
			sigs.cb.cyc <= 1;
			sigs.cb.stb <= 1;
			
			@(posedge sigs.cb.ack)
			data = sigs.cb.datS;
		end
		sigs.cb.stb = 0;
		sigs.cb.cyc = 0;
	endtask

	// ------------------------------------------------------------------------

	virtual task blockWrite(input logic [gAddrWidth-1:0] addr, const ref logic [gDataWidth-1:0] data[]);
		$display("blockWrite @%0tns", $time);
		for (int i = 0; i < $size(data); i = i + 1) begin
			sigs.cb.adr <= addr;
			sigs.cb.datM <= data;
			sigs.cb.we <= 1;
			sigs.cb.sel <= '1;
			sigs.cb.cyc <= 1;
			sigs.cb.stb <= 1;
			@(posedge sigs.cb.ack);
		end
		sigs.cb.stb = 0;
		sigs.cb.cyc = 0;
	endtask

	// ------------------------------------------------------------------------

	virtual task idle();
		$display("idle @%0tns", $time);

		@sigs.cb;
	endtask
endclass

module top;
	logic clk = 0, rst;
	wishbone_if wb(clk);
	
	// clk generator
	always #10 clk = ~clk;

	// RAM instantiation
	RAM TheRam(wb.clk, rst, wb.adr, wb.datM, wb.sel, wb.cyc, wb.stb, wb.we, wb.datS, wb.ack);
	// test program instantiation
	test TheTest(wb.master, rst);
endmodule

program test #(parameter int gDataWidth = 32, parameter int gAddrWidth = 8)(wishbone_if.master wb, output logic rst);
	initial begin : stimuli
		wishbone_bfm#(gDataWidth, gAddrWidth) bfm = new(wb);
		
		
		logic [gAddrWidth-1:0] addr = '1;
		logic [gDataWidth-1:0] data = '0;	

		// generate reset -----------------------------------------------------
		rst = 0;
		#10 rst = 1;
		#20 rst = 0;

		// stimuli ------------------------------------------------------------
		singleWrite(addr, '1);
		singleRead(addr, data);
		$display("data: %b", data);
		
	end : stimuli
endprogram

interface wishbone_if # (
    parameter int gDataWidth = 32,
    parameter int gAddrWidth = 8
  )(
    input bit clk
  );

  logic [gAddrWidth-1:0] adr;
  logic [gDataWidth-1:0] datM; // data coming from master
  logic [gDataWidth-1:0] datS; // data coming from slave
  logic [gDataWidth/8-1:0] sel;
  logic cyc, stb, we, ack;

  clocking cb @(posedge clk);
    input ack, datS;
    output stb, cyc, we, datM, adr, sel;
  endclocking
  
  modport master ( // the interface as seen from the master
    clocking cb
  );
  modport slave ( // the interface as seen from the slave
    output ack, datS,
    input stb, cyc, we, datM, adr, sel
  );
endinterface