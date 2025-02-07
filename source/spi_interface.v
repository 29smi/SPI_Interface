`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//
// ECE6213
// Siem Mihreteab 
// SPI Interface
// 
// 
//////////////////////////////////////////////////////////////////////////////////

module spi_interface(
	input wire	       SCLK,
	input wire	       MOSI,
	input wire	       CSN,
	input wire	       rst_n,
	input wire [15:0]  reg_read_data,
	output reg	       MISO,
	output reg	       MISO_enable,
	output reg [7:0]   reg_addr,
	output reg [15:0]  reg_write_data,
	output reg	       reg_write_enable,
	output reg         reg_read_enable
);

	// internal registers
	reg [15:0]			   spi_shift_reg_current;
	reg [2:0]			   state_current;
	reg [5:0]			   bit_count_current;
	reg				       reg_rw_current;  // read/write bit, 0=read, 1=write
	reg				       MISO_pos_edge;
	reg				       MISO_enable_pos_edge;
	reg [3:0]              counter;
	
	// internal combinational variables
	reg [15:0]			   spi_shift_reg_next;			       
	reg [2:0]			   state_next;
	reg [5:0]			   bit_count_next;
	reg				       reg_rw_next;
	reg [7:0]			   reg_addr_next;
	reg [15:0]			   reg_write_data_next;
	reg				       reg_write_enable_next;
	reg				       reg_read_enable_next;
	reg				       MISO_next;
	reg				       MISO_enable_next;
	reg [3:0]              counter_next;
   
	// decalare stat names
	parameter [2:0] S0_IDLE          = 3'd0;
	parameter [2:0] S1_RW            = 3'd1;
	parameter [2:0] S2_8_REG_ADDR    = 3'd2;
	parameter [2:0] S3_DUMMY_STATE   = 3'd3; // dummy state to wait in while SPI message finished, students whould remove this state and add necessary states to make FSM fully receive message
    parameter [2:0] S4_READ          = 3'd4;
	parameter [2:0] S5_REG_DATA      = 3'd5;
	parameter [2:0] S6_DUMMY_STATE   = 3'd6;
	
	


   // clock in registers, asynch active-low reset
    always @(posedge SCLK or negedge rst_n)
    begin
		if (rst_n == 1'b0) begin
			state_current         <= S0_IDLE;
			spi_shift_reg_current <= 15'h0000;
			bit_count_current     <= 6'd33;
			reg_rw_current        <= 1'b0;
			reg_addr              <= 8'h00;
			MISO_pos_edge         <= 1'b0;
			MISO_enable_pos_edge  <= 1'b0;
			reg_write_data        <= 16'h0000;
			reg_write_enable      <= 1'b0;
			reg_read_enable       <= 1'b0;
			counter               <= 4'b0;
		end else begin
			state_current         <= state_next;
			spi_shift_reg_current <= spi_shift_reg_next;
			bit_count_current     <= bit_count_next;
			reg_rw_current        <= reg_rw_next;
			reg_addr              <= reg_addr_next;
			MISO_pos_edge         <= MISO_next;
			MISO_enable_pos_edge  <= MISO_enable_next;
			reg_write_data        <= reg_write_data_next;
			reg_write_enable      <= reg_write_enable_next;
			reg_read_enable       <= reg_read_enable_next;
			counter               <= counter_next;
		end
    end // always @ (posedge clk or negedge rst_n)

   // clock out MISO and MISO_enable on clock falling edge
    always @(negedge SCLK or negedge rst_n)
    begin
		if (rst_n == 1'b0) begin
			MISO                  <= 1'b0;
			MISO_enable           <= 1'b0;
		end else begin
			MISO                  <= MISO_pos_edge;
			MISO_enable           <= MISO_enable_pos_edge;
		end
    end // always @ (negedge clk or negedge rst_n)

   // combinational logic for MOSI shift register
    always @(*)
    begin
		// shift in data on MOSI
		spi_shift_reg_next = {spi_shift_reg_current[14:0], MOSI};
    end

   // combinational logic for state machine
    always @(*)
    begin
		// assign default value for all combinational signals
		state_next            = state_current;
		bit_count_next        = bit_count_current;
		reg_rw_next           = reg_rw_current;
		reg_addr_next         = reg_addr;
		MISO_next             = 1'b0;
		MISO_enable_next      = 1'b0;
		reg_write_data_next   = reg_write_data;
		reg_write_enable_next = 1'b0;
		reg_read_enable_next  = 1'b0;
		counter_next          = counter;
		

		case(state_current)
			S0_IDLE: 
			begin
				if (CSN == 1'b0) begin
					state_next     = S1_RW;
					bit_count_next = bit_count_current - 1'b1;
				end
			end
			S1_RW:
			begin
				reg_rw_next    = spi_shift_reg_current[0];
				state_next     = S2_8_REG_ADDR;
				bit_count_next = bit_count_current - 1'b1;
			end
			S2_8_REG_ADDR: 
			begin
				bit_count_next = bit_count_current - 1'b1;
				if(bit_count_current == 6'd24) begin
					reg_addr_next = spi_shift_reg_current[7:0];
					state_next = S3_DUMMY_STATE;
				end
			end
			S3_DUMMY_STATE:
			begin
				bit_count_next = bit_count_current - 1'b1;
				counter_next = 4'd15;
				if(reg_rw_current == 1'b1) begin
					reg_write_enable_next = 1'b1;
					if(bit_count_current == 6'd19) begin
						state_next = S5_REG_DATA;
					end
				end
				if(reg_rw_current == 1'b0) begin
					reg_read_enable_next = 1'b1;
					if(bit_count_current == 6'd21) begin
						state_next = S4_READ;
					end
				end
			end
			S4_READ:
			begin
				reg_read_enable_next = 1'b1;
				MISO_enable_next = 1'b1;
				counter_next = counter - 1;
				MISO_next = reg_read_data[counter];
				bit_count_next = bit_count_current - 1'b1;

				if (counter == 4'd0) begin
					state_next = S6_DUMMY_STATE;
				end
			end
			S5_REG_DATA: 
			begin
				reg_write_enable_next = 1'b1;
				bit_count_next = bit_count_current - 1'b1;
				if (bit_count_current == 6'd3) begin
					state_next = S6_DUMMY_STATE;   // made a dummy state for FSM to go into for the remainder of the message, you will need to change this to actually read in reg data and make read/write decision
					reg_write_data_next = spi_shift_reg_current[15:0];
				end
			end
			S6_DUMMY_STATE : begin
				bit_count_next = bit_count_current - 1'b1;
				if(bit_count_current == 6'd0) begin
					state_next = S0_IDLE;
					bit_count_next = 6'd33;
				end
			end
		endcase // case (state_current)
    end // always @ (*)
   
endmodule // spi_interface

	
	     
	     
	     
	     
	
        
	
   
   

   
