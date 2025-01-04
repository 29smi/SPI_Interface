`timescale 1ns / 1ps

///////////////////////////////////////
// 
// SPI interface testbench
//
///////////////////////////////////////

module proj9_top_syn_tb(
    );

   // SPI interface_signals   
   reg	      SCLK   = 1'b0;
   reg	      CSN    = 1'b1;
   reg	      MOSI   = 1'b0;
   reg	      rst_n  = 1'b0;	    
   wire	      MISO;  
   wire	      MISO_enable;

   // signal for SPI data output 
   reg [15:0] SPI_data_out;

   // signals for simulation control
   reg             tb_clk = 1'b0; 	      
   reg [8*39:0]    testcase;

   // signal to save generated data in
   reg [15:0]	   spi_data[0:255];

   //loop variables
   integer	   i;
   

   // instantiate DUT
   proj9_top DUT(
		     .SCLK(SCLK),
		     .MOSI(MOSI),
		     .CSN(CSN),
		     .rst_n(rst_n),
		     .MISO(MISO),
		     .MISO_enable(MISO_enable)
		     );
   

    // 100 kHz clk = 10,000ns period
    always #5000 tb_clk = ~tb_clk;

	// initial block for SDF back annotation
   initial begin
      $sdf_annotate("../../synthesis/netlists/proj9_top_syn.sdf",proj9_top_syn_tb.DUT, ,"back_annotate.log");
   end
 
    
    initial begin
       testcase = "Initializing";

       // generate spi data to write and read back
       for(i = 0; i <=255; i = i+1) begin
	  		spi_data[i] = $random;
       end

       // release reset 
       repeat(10)
	 @(posedge tb_clk);
       rst_n = 1'b1;

       repeat(10)
	 @(posedge tb_clk);

       // send 10 clock pulses for rest synch
       repeat(10) begin
	  @(posedge tb_clk)
	    SCLK = 1'b1;
	  @(negedge tb_clk)
	    SCLK = 1'b0;    	 
       end

       repeat(10)
	 @(posedge tb_clk);
       
       // write to all 256 registers
       testcase = "SPI_WRITE";
       for(i = 0; i <=255; i = i+1) begin
	  SPI_CMD(1'b1,i,spi_data[i],SPI_data_out);
       end

       repeat(10)
	 @(posedge tb_clk);

       // read all 256 registers
       testcase = "SPI_READ";
       for(i = 0; i <=255; i = i+1) begin
	  SPI_CMD(1'b0,i,spi_data[i],SPI_data_out);
	  // insert code here to compare spi_data[i] to SPI_data_out and keep an error count
	  //   see lecture 5, slide 11 for an example
       end

       repeat(20)
	 @(posedge tb_clk);
       
       $finish;
    end


   
   task SPI_CMD (input	       SPI_read_write, 
                 input  [7:0]  SPI_addr,
		 input  [15:0] SPI_data_in,
                 output [15:0] SPI_data_out); 	 
      integer		       i;
      begin
	 
	 // active-low CSN active at clock negative edge, send read/write bit
	 @(negedge tb_clk)
           CSN = 1'b0;
	 
	 MOSI = SPI_read_write;
	 @(posedge tb_clk)
	   SCLK = 1'b1;
	 
	 // 8-bit address shifted on clock negedge, send SCLK aligned with tb_clk
	 for(i=7; i>=0; i=i-1) begin
	    @(negedge tb_clk)
	      SCLK = 1'b0;
	    MOSI = SPI_addr[i];	
            @(posedge tb_clk)
	      SCLK = 1'b1; 
	 end

	 // 5-bit dead time for data retrieval
	 for(i=4; i>=0; i=i-1) begin
	    @(negedge tb_clk)
	      SCLK = 1'b0;
	    MOSI = 1'b0;
            @(posedge tb_clk)
	      SCLK = 1'b1;	 
	 end
   
	 // 16-bit data shifted on clock negedge, send SCLK aligned with tb_clk
	 for(i=15; i>=0; i=i-1) begin
	    @(negedge tb_clk)
	      SCLK = 1'b0;
	    if ( SPI_read_write == 1'b1) begin
	       MOSI = SPI_data_in[i];
	    end else begin
	       MOSI = 1'b0;
	    end
	    
            @(posedge tb_clk)
	      SCLK = 1'b1;
	    // clock in data on MISO if MISO_enable = 1, else clock in that it is high-z
	    if (MISO_enable == 1'b1) begin
	      SPI_data_out[i] = MISO;
	    end else begin
	      SPI_data_out[i] = 1'bz;
	    end
	 end
	      
	 // 4-bit dead time for data write
	 for(i=4; i>=0; i=i-1) begin
	    @(negedge tb_clk)
	      SCLK = 1'b0;
	    MOSI = 1'b0;
            @(posedge tb_clk)
	      SCLK = 1'b1;	 
	 end

	 // end message and CSN goes inactive
	   SCLK = 1'b0;
	   CSN = 1'b1;

      end     
   endtask // SPI_CMD
   
   
endmodule
