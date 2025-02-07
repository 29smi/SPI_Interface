
`timescale 1 ns / 1 ps 


////////////////////////////////////
//
// Name - Siem Mihreteab
// Course - ECE6213
// Project 9 - reset synchronization
//
///////////////////////////////////


module rst_syn(
    input wire clk,
    input wire rst_n,
    output reg rst_n_syn
);

reg out1;


always @(posedge clk or negedge rst_n)
begin
    if(rst_n == 0) begin
        out1 <= 1'b0;
        rst_n_syn <= 1'b0;
    end else begin
        out1 <= 1'b1;
        rst_n_syn <= out1;
    end
end

endmodule