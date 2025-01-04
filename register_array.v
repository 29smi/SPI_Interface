
`timescale 1ns / 1ps

////////////////////////////////////
//
// Name - Siem Mihreteab
// Course - ECE 6213
// Project 9 - Register array
//
/////////////////////////////////// 



module register_array(
    input wire clk,
    input wire rst_n,
    input wire [7:0] reg_addr,
    input wire [15:0] reg_write_data,
    input wire reg_write_enable,
    input wire reg_read_enable,
    output reg [15:0] reg_read_data
);

// internal combinatorial variable
reg [15:0] reg_read_data_next;
reg [15:0] reg_array_next[0:255];

// Internal sequential variables
reg [15:0] reg_array[0:255];

// integer
integer i;
integer j;


// clock in
always @(posedge clk or negedge rst_n)
begin
    if(rst_n == 1'b0) begin
        for(i = 0; i < 256; i = i + 1) begin
            reg_array[i] <= 16'b0;
        end
        reg_read_data <= 16'b0;

    end else begin
        for(i = 0; i < 256; i = i+1) begin
            reg_array[i] <= reg_array_next[i];
        end
        reg_read_data <= reg_read_data_next;
    end
end


always @(*) 
begin

    reg_read_data_next = reg_read_data;

    // default values
    for(j = 0; j < 256; j = j+1) begin
        reg_array_next[j] = reg_array[j];
    end

    if(reg_write_enable) begin
        reg_array_next[reg_addr] = reg_write_data;
    end
    if(reg_read_enable) begin
        reg_read_data_next = reg_array_next[reg_addr];
    end
end

endmodule