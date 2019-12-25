module count_ones_max_string#(parameter word_size = 32, counter_size = 6) (
  output [counter_size-1: 0] bit_count, // The maximum number of consecutive ones in your input.
  output				busy, done ,//busy means still working, or done with the maximum string
  input [word_size-1: 0] 		data, // The input word (To be read in one clock cycle following the start signal)  
  input 				start,clk, reset // Start: Load a new word.
);

wire shift,clear;
wire temp_gt_1,load_temp;
Control_Unit M0(busy,load_temp,shift,clear,done,start,temp_gt_1,clk,reset);
Datapath_Unit M1(bit_count,temp_gt_1,data,load_temp,shift,clear,clk,reset);
endmodule



module Datapath_Unit#(parameter word_size = 32, counter_size = 6) (
	output reg[counter_size-1:0] bit_count,
        output temp_gt_1,
        input [word_size-1:0] data,
        input load_temp,shift,clear,clk,reset/* Interface to the data unit.*/
);
reg [word_size-1:0] temp;
assign temp_gt_1=(temp>1);
wire temp_0=temp[0];
reg [counter_size-1:0] count,res;
initial res=5'd31;//remaining bits
initial count=5'd0;//consecutive ones

always@(posedge clk)
 if(reset)
   temp<=0;
 else begin
    if(load_temp) temp<=data;
    if(shift) temp<=temp>>1;
 end

always@(posedge clk)
    if(reset==1'b1||clear==1'b1) bit_count<=0;
    else begin
    if(temp_0==1||res>bit_count) begin/*if 1s is still continious or remain bits is larger than bit_count*/
     case(temp_0) 
        1: begin count<=count+1;res<=res-1;end
        0: begin count<=0;res<=res-1;end
        default: count<=0;
     endcase
    end
    else begin/*early termination if remaining bits are smaller than bit_count and 1s is discrete*/
       temp<=0;end
    if(count>=bit_count) bit_count<=count;
   end

/* Datapath implemenation. */

endmodule


module Control_Unit (
	output reg busy,load_temp,shift,clear,done,
        input start,temp_gt_1,clk,reset/* Interface to the contrl unit.*/
);

parameter state_size=2'd2;
parameter idle=2'd0;
parameter counting=2'd1;
parameter waiting=2'd2;
reg bit_count;
reg [state_size-1:0] state,nextstate;

always@(posedge clk)
 if(reset) state<=idle; else state<=nextstate;

always@(state,start,temp_gt_1)begin
load_temp=0;
shift=0;
clear=0;
done=0;
busy=0;
nextstate=idle;

case(state)
  idle:if(start) begin nextstate=counting;load_temp=1;clear=1;end
  counting:begin
           busy=1;
           shift=1;
           if(temp_gt_1) 
                 nextstate=counting;
           else  
                 nextstate=waiting;
 end 
  waiting:begin
          done=1;
          if(start) begin nextstate=counting;load_temp=1;clear=1;end
          else nextstate=waiting;
          end
  default: begin clear=1;nextstate=idle;end
endcase
end
/* Implement your control unit as a Mealy FSM. */
endmodule



