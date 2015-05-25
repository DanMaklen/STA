`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:54:27 05/13/2014 
// Design Name: 
// Module Name:    PmodI2S_FSM 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module PmodI2S_FSM(
	 input start,
	 input i2s_en,
	 input clk_sclk,
	 input rst,
	 output cntr_ncs,
	 output cntr_load
    );
	 
	 reg[1:0] state, nextstate;
	 reg[3:0] cnt;
	 parameter[1:0] IDLE = 2'b00, SHIFT = 2'b01, DONE = 2'b10, X = 2'b11;
	 
	 assign cntr_ncs = state != SHIFT;
	 assign cntr_load = state == IDLE;
	 
	 always@(negedge clk_sclk) begin
		if(state == IDLE) cnt <= 4'b1111;
		else cnt <= cnt - 1'b1;
	 end
	 
	 always@(*) begin
		case(state)
			IDLE: nextstate = (start&&i2s_en?SHIFT:state);
			SHIFT: nextstate = (!cnt?DONE:state);
			DONE: nextstate = (start?state:IDLE);
			default: nextstate = X;
		endcase
	 end
	 
	 always@(negedge clk_sclk or posedge rst) begin
		if(rst) state <= IDLE;
		else state <= nextstate;
	 end
	 
endmodule
