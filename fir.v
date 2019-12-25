
`timescale 1ns/10ps
`define N 5

module fir(data_out, out_enable, data_in, sample_enable, coef_enable, error, clk, reset);

	/* States of the FIR filter. */
	parameter s_reset 	= 2'b00;
	parameter s_coeff 	= 2'b01;
	parameter s_filter 	= 2'b10;
	parameter s_error 	= 2'b11;
	/* Ouput data in 16 bit unsigned integer representation. */
	output [15:0] data_out;
	/* data_out is valid when out_enable is high.*/
	output out_enable;

	/* If the coef_enable signal not valid for 'N' consecutive clock
	* cycles, the error signal is asserted till the filter is reseted. */
	output error;
	/* Input data or coefficient in 8 bits unsigned integer representation. */
	input [7:0] data_in;
	/* A new data sample is on the data_in port when sample_enable is high. 
	 */
	input sample_enable;
	/* A new coef is on the data_in port when coef_enable is high. 
	 */
	input coef_enable;
	/* Clock */
	input clk;
	/* Reset */
	input reset;
        wire read_coef,read_samp,complete;
	Control_Unit M0(read_coef,read_samp,error,out_enable,sample_enable,coef_enable,clk,reset,complete,out_valid);
        Datapath_Unit M1(data_out,out_valid,complete,data_in,clk,reset,read_coef,read_samp);	
endmodule

module Datapath_Unit(
       output reg [15:0] data_out,
       output reg out_valid,complete,
       input [7:0] data_in,
       input clk,reset,read_coef,read_samp
);
reg[7:0] h[0:4];/*coefficient registers*/
reg[15:0] sample_his[0:3];/*sampling history registers*/
reg[2:0] i,j;


/*read the latest input and generate data out*/
always@(*)
  data_out=sample_his[3]*h[4]+sample_his[2]*h[3]+sample_his[1]*h[2]+sample_his[0]*h[1]+h[0]*data_in;
/*The sample_his stores previous data. For instance sample_his[3]=x[n-4] */



always@(posedge clk or negedge reset)
if(~reset) begin/*reset the sampling history and coefficient registers*/
h[0]<=0;
h[1]<=0;
h[2]<=0;
h[3]<=0;
h[4]<=0;
sample_his[0]<=0;
sample_his[1]<=0;
sample_his[2]<=0;
sample_his[3]<=0;
i<=0;
j<=0;

end
/*read the coefficients and store in regesters.complete=1 when all five numbers are stored */
else begin
  if(read_coef) begin
      complete<=0;
      h[i]<=data_in;
      if(i<4) i<=i+1;
      else begin i<=0;complete<=1;end
  end

/*read the current input and calculate the sum of products*/

  if(read_samp) begin
      sample_his[0]<=data_in;
      sample_his[1]<=sample_his[0];
      sample_his[2]<=sample_his[1];
      sample_his[3]<=sample_his[2];

      end
  
end

endmodule 


module Control_Unit (
output reg read_coef,read_samp,error,out_enable,
input sample_enable,coef_enable,clk,reset,complete,out_valid
);
parameter s_reset 	= 2'b00;
parameter s_coeff 	= 2'b01;
parameter s_filter 	= 2'b10;
parameter s_error 	= 2'b11;

reg[1:0] state,nextstate;
always@(posedge clk or negedge reset)
 if(~reset) state<=s_reset; else state<=nextstate;

always@(reset,sample_enable,coef_enable,state,out_valid,clk)begin
read_coef=0;
read_samp=0;
error=0;
nextstate=s_reset;
out_enable=0;
/**/


case(state)
   s_reset: begin
            if(coef_enable&&(!sample_enable))begin nextstate=s_coeff; read_coef=1;end
            else if(sample_enable) begin nextstate=s_error;error=1;end
            end

   s_coeff: begin
              if(coef_enable&&sample_enable) begin nextstate=s_error;error=1; end
              else if(coef_enable) begin nextstate=s_coeff;read_coef=1;end
              else if(!coef_enable&&complete) begin nextstate=s_filter;
                           if(sample_enable) begin read_samp=1;out_enable=1;end
                       end
              else if(!coef_enable&&(!complete)) begin error=1;nextstate=s_error;end
            end

   s_filter:begin
            out_enable=1;
            if(sample_enable&&(!coef_enable)) begin read_samp=1;nextstate=s_filter;end
            else if(sample_enable&&coef_enable) begin nextstate=s_error;error=1;end
            else if(!sample_enable&&!coef_enable) nextstate=s_filter;
            else if((!sample_enable)&&coef_enable) begin nextstate=s_coeff;read_coef=1;end
            end

   s_error: begin
            nextstate<=s_error;
            error=1;
            end
endcase
end
endmodule
