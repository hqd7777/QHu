module PEA(result,error,read_control,read_data,write,control_in,data_in,
       clk,data_in_empty,control_in_empty,data_out_full);
output [31:0] result;
output error;
/*
   0 error;
   1 reset;
   2 compute;
   4 valid result;
   3 done;
*/
output read_control,read_data,write;

input [20:0]control_in;
input [15:0] data_in;
input clk;
input data_in_empty,control_in_empty,data_out_full;

reg [20:0] instruction;
/*control_in[20:19] op code;
  control_in[18:16] A;
  control_in[15:0] x,b,N;
*/

wire upload;
always@(upload)
instruction=control_in;

wire[1:0] ex_code=instruction[20:19];
wire[2:0] ex_A=instruction[18:16];
wire[15:0] ex_Dst=instruction[15:0];
wire[1:0] op_code=control_in[20:19];
wire[2:0] A= control_in[18:16];
wire[15:0] Dst=control_in[15:0];
wire done;
wire rst,stp,evp,evb;

datapath_unit M0(result,done,error,ex_A,data_in,ex_Dst,clk,evp,evb,stp,rst,value,S40,S44,write);
control_unit M1(clk,reset,done,status,control_in_empty,data_in_empty,op_code,data_out_full,
     rst,stp,evp,evb,read_control,read_data,upload);

endmodule




module datapath_unit(result,done,error,Ex_A,data_in,Ex_Dst,clk,evp,evb,stp,rst,value,S40,S44,write);
output reg signed[31:0] result;
output reg done,write,error;

input [2:0] Ex_A;
input [15:0] data_in,Ex_Dst;
input clk,evp,evb,stp,rst;
output reg[15:0] S40,S44;
output reg[3:0]value;
reg[3:0] j,n,size1,size2,size3,size4,size5,size6,size7,size0;
reg signed[15:0] S0[0:10];
reg signed[15:0] S1[0:10];
reg signed[15:0] S2[0:10];
reg signed[15:0] S3[0:10];
reg signed[15:0] S4[0:10];
reg signed[15:0] S5[0:10];
reg signed[15:0] S6[0:10];
reg signed[15:0] S7[0:10];

reg signed[31:0] temp_r;
wire temp_in;
assign temp_in=$signed(data_in);

initial begin
temp_r=0;
end





always@(posedge clk)begin
write<=0;
 S40=S4[0];
 S44=S4[4];

if(rst) begin
size0<=0;
size1<=0;
size2<=0;
size3<=0;
size4<=0;
size5<=0;
size6<=0;
size7<=0;
done<=1;
value<=0;
n<=0;
end

else if (stp)begin
done<=0;
if(data_in)begin
case (Ex_A)
  0: begin
     size0<=Ex_Dst;
     S0[value]<=$signed(data_in);
    end
  1: begin
     size1<=Ex_Dst;
     S1[value]<=$signed(data_in);
    end
  2: begin
     S2[value]<=$signed(data_in);
     size2<=Ex_Dst;
    end
  3: begin
     S3[value]<=$signed(data_in);
     size3<=Ex_Dst;
    end
  4: begin
     S4[value]<=$signed(data_in);
     size4<=Ex_Dst;
    end
  5: begin
     S5[value]<=$signed(data_in);
     size5<=Ex_Dst;
    end
  6: begin
     S6[value]<=$signed(data_in);
     size6<=Ex_Dst;
    end
  7: begin
     S7[value]<=$signed(data_in);
     size7<=Ex_Dst;
    end
 endcase
end
 if(data_in) value<=value+1;
 if(value==Ex_Dst+1) begin value<=0; done<=1;end
end

else if (evp) begin
done=0;
case (Ex_A)
   0: begin
        if(size0)begin
        for(j=0;j<size0+1;j=j+1)begin
        temp_r=$signed(Ex_Dst)*temp_r+S0[size0-j];
        end
        result<=temp_r;       error<=1;
        temp_r<=0;end
        else begin result<=0;error<=0;end
      end
   1: begin
if(size1)begin
        for(j=0;j<size1+1;j=j+1)begin
        temp_r=$signed(Ex_Dst)*temp_r+S1[size1-j];
        end
        result<=temp_r;       error<=1;
        temp_r<=0;end
        else begin result<=0;error<=0;end
      end
   2: begin
        if(size2)begin
        for(j=0;j<size2+1;j=j+1)begin
        temp_r=$signed(Ex_Dst)*temp_r+S2[size2-j];
        end
        result<=temp_r;       error<=1;
        temp_r<=0;end
        else begin result<=0;error<=0;end
      end
   3: begin
        if(size3)begin
        for(j=0;j<size3+1;j=j+1)begin
        temp_r=$signed(Ex_Dst)*temp_r+S3[size3-j];
        end
        result<=temp_r;       error<=1;
        temp_r<=0;end
        else begin result<=0;error<=0;end
      end
   4: begin
        if(size4)begin
        for(j=0;j<size4+1;j=j+1)begin
        temp_r=$signed(Ex_Dst)*$signed(temp_r)+$signed(S4[size4-j]);
        end
        result<=temp_r;
        error<=1;
        temp_r<=0;end
        else begin result<=0;error<=0;end
      end
   5: begin
        if(size5)begin
        for(j=0;j<size5+1;j=j+1)begin
        temp_r=$signed(Ex_Dst)*temp_r+S5[size5-j];
        end
        result<=temp_r;       error<=1;
        temp_r<=0;end
        else begin result<=0;error<=0;end
      end
   6: begin
        if(size6)begin
        for(j=0;j<size6+1;j=j+1)begin
        temp_r=$signed(Ex_Dst)*temp_r+S6[size6-j];
        end
        result<=temp_r;       error<=1;
        temp_r<=0;end
        else begin result<=0;error<=0;end
      end
   7: begin
        if(size0)begin
        for(j=0;j<size7+1;j=j+1)begin
        temp_r=$signed(Ex_Dst)*temp_r+S7[size7-j];
        end
        result<=temp_r;       error<=1;
        temp_r<=0;end
        else begin result<=0;error<=0;end
      end
endcase
done<=1;write<=1;
end


else if (evb) begin
done=0;
if(Ex_Dst<32)begin
if(data_in)begin
case (Ex_A)
   0: begin
        if(size0)begin
        for(j=0;j<size0+1;j=j+1)begin
        temp_r=data_in*temp_r+S0[size0-j];
        end
        result<=temp_r;       error<=1;
        temp_r<=0;end
        else begin result<=0;error<=0;end
      end
   1: begin
        if(size1)begin
        for(j=0;j<size1+1;j=j+1)begin
        temp_r=data_in*temp_r+S1[size1-j];
        end
        result<=temp_r;       error<=1;
        temp_r<=0;end
        else begin result<=0;error<=0;end
      end
   2: begin
        if(size2)begin
        for(j=0;j<size2+1;j=j+1)begin
        temp_r=data_in*temp_r+S2[size2-j];
        end
        result<=temp_r;       error<=1;
        temp_r<=0;end
        else begin result<=0;error<=0;end
      end
   3: begin
        if(size3)begin
        for(j=0;j<size3+1;j=j+1)begin
        temp_r=data_in*temp_r+S3[size3-j];
        end
        result<=temp_r;       error<=1;
        temp_r<=0;end
        else begin result<=0;error<=0;end
      end
   4: begin
        if(size4)begin
        for(j=0;j<size4+1;j=j+1)begin
        temp_r=$signed(data_in)*$signed(temp_r)+$signed(S4[size4-j]);
        end
        result<=temp_r;       error<=1;
        temp_r<=0;end
        else begin result<=0;error<=0;end
      end
   5: begin
        if(size5)begin
        for(j=0;j<size5+1;j=j+1)begin
        temp_r=data_in*temp_r+S5[size5-j];
        end
        result<=temp_r;       error<=1;
        temp_r<=0;end
        else begin result<=0;error<=0;end
      end
   6: begin
        if(size6)begin
        for(j=0;j<size6+1;j=j+1)begin
        temp_r=data_in*temp_r+S6[size6-j];
        end
        result<=temp_r;       error<=1;
        temp_r<=0;end
        else begin result<=0;error<=0;end
      end
   7: begin
        if(size7)begin
        for(j=0;j<size7+1;j=j+1)begin
        temp_r=data_in*temp_r+S7[size7-j];
        end
        result<=temp_r;       error<=1;
        temp_r<=0;end
        else begin result<=0;error<=0;end
      end
endcase
end
 if(data_in) n<=n+1;
 if(n==Ex_Dst) begin n<=0; done<=1;write<=1;end
end
else begin result<=0; error<=0; write<=0;end
end

end
endmodule


module control_unit(clk,reset,done,status,control_in_empty,data_in_empty,op_code,data_out_full,
     rst,stp,evp,evb,read_control,read_data,upload);
parameter s_halt=4'b0000;
parameter s_decode=4'b0001;
parameter s_rst=4'b0010;
parameter s_stp=4'b0011;
parameter s_evp=4'b0100;
parameter s_evb=4'b0101;
parameter stp_stl=4'b0110;
parameter evb_stl=4'b0111;
parameter evp_fll=4'b1000;
parameter evb_fll=4'b1001;

input clk,reset,done,control_in_empty,data_in_empty,data_out_full;
output reg [2:0] status;
input [1:0] op_code;
output reg rst,stp,evp,evb,read_control,read_data,upload;
reg flag;
reg [2:0] state,n_state;

initial flag=1;

always@(posedge clk or reset)
if(~reset) state<=s_halt;
else state<=n_state;


always@(state,clk,done,control_in_empty,data_in_empty,reset) begin
read_control=0;
read_data=0;
rst=0;
stp=0;
evp=0;
evb=0;
upload=0;

case (state)
 s_halt:begin

        if(flag)begin
        if(~control_in_empty) begin
        read_control=1;
        n_state=s_decode;
        upload=1;end
        end
        end
 s_decode: begin
        case (op_code)
        0: begin n_state=s_rst;rst=1;end
        1: begin n_state=s_stp; stp=1;end
        2: begin n_state=s_evp; evp=1;end
        3: begin n_state=s_evb; evb=1;end
        default: begin n_state=s_halt;end
        endcase
        end

 s_rst: begin 
        if(done) n_state=s_halt;
        end

 s_stp: begin 
        read_data=1;
        stp=1;
        if(done) n_state=s_halt;  
        else if(data_in_empty) begin n_state=stp_stl;read_data=0;stp=1;end      
        end

 s_evp: begin
        if(done) n_state=s_halt; 
        else if(data_out_full) n_state=evp_fll;     
        end

 s_evb: begin
        read_data=1;
        evb=1;
        
        if(done) n_state=s_halt;  
        else if(data_in_empty) begin n_state=evb_stl;read_data=0;end
        else if(data_out_full) begin n_state=evb_fll;read_data=0;end      
        end

 stp_stl: begin
        stp=1;
        if(done) n_state=s_halt;
        else if(~data_in_empty) n_state=s_stp;stp=1;
        end

 evb_stl: begin
        evb=1;
        if(done) n_state=s_halt;
        else if(~data_in_empty) begin n_state=s_evb;evb=1;end
        end

 evp_fll: begin
        if(~data_out_full) begin n_state=s_evp;evp=1;end
        end

 evb_fll: begin
        evb=1;
        if(~data_out_full) begin n_state=s_evb;evb=1;end
        end
  default: n_state=s_halt;
endcase

end
endmodule



