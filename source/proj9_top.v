`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
// 
// top module
// 
// 
//////////////////////////////////////////////////////////////////////////////////

module proj9_top(
	input wire  SCLK,
	input wire  MOSI,
	input wire  CSN,
	input wire  rst_n,
	output wire MISO,
	output wire MISO_enable		     
);

   // internal signals
   wire [15:0]			   reg_read_data;   
   wire [7:0]			   reg_addr;   
   wire [15:0]			   reg_write_data;
   wire				       reg_write_enable;
   wire				       reg_read_enable;
   wire                    rst_n_syn;
	       

   spi_interface cmd_interface(			       
		.SCLK(SCLK),
		.MOSI(MOSI),
		.CSN(CSN),
		.rst_n(rst_n_syn),
		.reg_read_data(reg_read_data),
		.MISO(MISO),
		.MISO_enable(MISO_enable),
		.reg_addr(reg_addr),
		.reg_write_data(reg_write_data),
		.reg_write_enable(reg_write_enable),
		.reg_read_enable(reg_read_enable)
	);

   // insert register array module here
   
   register_array regi_modu(
		.clk(SCLK),
		.rst_n(rst_n_syn),
		.reg_addr(reg_addr),
		.reg_write_data(reg_write_data),
		.reg_write_enable(reg_write_enable),
		.reg_read_enable(reg_read_enable),
		.reg_read_data(reg_read_data)
   );

   rst_syn reset_s(
		.clk(SCLK),
		.rst_n(rst_n),
		.rst_n_syn(rst_n_syn)
   );
   

endmodule // proj9_top

	
	     
	     
	     
	     
	
        
	
   
   

   
