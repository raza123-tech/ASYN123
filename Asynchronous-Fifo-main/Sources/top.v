module afifo#(parameter DEPTH =8 ,parameter WIDTH=4)(
input wclk,
input rclk,
input wen,
input ren,
input rst,
input [DEPTH-1:0]data,
  output reg [DEPTH-1:0]out, 
output    full,
output   empty
);
  
  integer i;
  
  reg [DEPTH-1:0]mem[0:WIDTH-1];
  reg [$clog2(WIDTH):0]wptr;
  reg [$clog2(WIDTH):0]rptr;
  reg [$clog2(WIDTH):0]wptr1;
  reg [$clog2(WIDTH):0]rptr1;
  reg [$clog2(WIDTH):0]wptr2;
  reg [$clog2(WIDTH):0]rptr2;
  reg [$clog2(WIDTH):0]f1;
  reg [$clog2(WIDTH):0]f2;
  reg [$clog2(WIDTH):0]bin;
  reg [$clog2(WIDTH):0]wbin;
  
  
  always@(posedge wclk)
    begin
    if(rst)begin 
    out<=0;
      wptr<=0;
      rptr<=0;
      wptr1<=0;
       rptr1<=0;
      wptr2<=0;
       rptr2<=0;
      f1<=0;
      f2<=0;
    end
  else
    begin
      if(wen && !full)begin
        mem[wptr[$clog2(WIDTH)-1:0]]<=data;
      wptr<=wptr+1;
        wptr1<=((wptr+1)>>1)^(wptr+1); 
      end
   
    end
    end
 
  always@(posedge rclk)
    begin
    if(rst)begin 
    out<=0;
      wptr<=0;
       rptr<=0;
       wptr1<=0;
       rptr1<=0;
      wptr2<=0;
       rptr2<=0;
      f1<=0;
      f2<=0;
    end
  else
    begin
      if(ren && !empty)
        begin
          out<=mem[rptr[$clog2(WIDTH)-1:0]];
         rptr<=rptr+1;
          rptr1<=((rptr+1)>>1)^(rptr+1);
        end
          end
    end
  
 always @(posedge rclk )
    begin
  f1<=wptr1;
  wptr2<=f1; 
 
end
    
  
always@(posedge wclk )begin
  f2<=rptr1;
  rptr2<=f2; 
end
  
 always @(*)
    begin
  bin[$clog2(WIDTH)] = rptr2[$clog2(WIDTH)]; 
        for (i = $clog2(WIDTH)-1; i >= 0; i = i - 1) begin
          bin[i] = rptr2[i] ^ bin[i+1];
        end
 end
  
  always @(*)
    begin
      wbin[$clog2(WIDTH)] = wptr2[$clog2(WIDTH)]; 
        for (i = $clog2(WIDTH)-1; i >= 0; i = i - 1) begin
          wbin[i] = wptr2[i] ^ wbin[i+1];
        end
 end
  
  assign full= ({~wptr[$clog2(WIDTH)], wptr[$clog2(WIDTH)-1:0]} == bin)?1:0;
  
  assign  empty=(wbin==rptr)?1:0;
  
endmodule 
