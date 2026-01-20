module test ;
  parameter DEPTH=8;
  parameter WIDTH=4;
  reg wclk;
reg rclk;
reg wen;
reg ren;
reg rst;
  reg [DEPTH-1:0]data;
  wire [DEPTH-1:0]out; 
  wire full;
wire empty;
  reg [4:0]c;
  reg[10*8-1:0]char;
  
  integer i;
afifo dut (
wclk,
rclk,
wen,
ren,
rst,
data,
out, 
full,
empty
);
  initial begin
  wclk=0;
  rclk=0;
    wen=0;
    ren=0;
    data=0;
    c=0;
    rst=1;
    if(!$value$plusargs("char=%s",char))begin
           char="reset";
    end

  end 
  
  initial begin 
    $dumpfile("out.vcd");
    $dumpvars(0,test);
  end
  
 /* initial begin
        $monitor("Time: %0t | Rst: %b | Wen: %b | Empty: %b | Out: %h", $time, rst, wen, empty, out);
    end*/
  
  always #5 wclk=~wclk;
  always #10 rclk=~rclk;
  
  initial 
    begin 
      rst=1;
      @(posedge wclk);
      @(posedge rclk);
      rst=0;
      @(posedge rclk);
      case(char)
        "reset":reset();
        "afull":begin afull();  end
        "aempty":begin aempty();  end
        "write":begin write(); end
        "read":begin read(); end
        "overflow":begin overflow(); end
        "underflow":begin underflow();end
        "wrap":begin wrap(); end
        "sw":begin sw(); end
          default: begin $display("INPUT THE VALID TESTCASE");
                   c=c+1;
                     end
        
      endcase
     #10
      if(c==0)
        $display("success");
      else
        $display ("Fail");
    $finish;
    end
 
 
  
  task write;
    begin
      fork  
      begin
        @(negedge wclk);
        wen<=1;
        data<=12;
        @(negedge wclk);
        wen<=0;
      end 
        
       begin
         repeat(3)  @(posedge rclk);
       end
      join 
     // $display("%0d",empty);
      if(empty==1)
        c<=c+1;
      else
      c<=c;
    end
  endtask


task read;
    begin
      fork  
      begin
        @(negedge wclk);
        wen<=1;
        data<=12;
        @(negedge wclk);
        wen<=0;
      end 
        
       begin
         repeat(3)  @(posedge rclk);
       end
      join 
      @(negedge rclk);
        ren<=1;
      @(negedge rclk);
        ren<=0;
      
      if(out==12)
        c<=c;
      else
      c<=c+1;
    end
  
  endtask
  
  
  task afull;
    begin 
   
      for(i=0;i<WIDTH+1;i++)begin 
        @(negedge wclk);
        wen=1;
      data=$random;
        //@(posedge wclk);
        //wen=0;
        
        //$display("%0d,%0d",full,dut.mem[i]); 
      end
      // @(posedge wclk);
   wen=0;
   //     @(posedge wclk);
   $display("%0d",full);
      if(full==0)
        c=c+1;
      else
        c=c;
    end 
  endtask 
  
  task reset;
    begin
    
      @(negedge wclk);
    rst=0;
      wen=1;
      data=1;
      @(negedge wclk);
      wen=0;
      repeat(2)    @(posedge rclk);
      @(negedge wclk);
      rst=1;
      @(negedge wclk);
    rst=0;
      
      if(empty==1)
         c<=c;
      else
        c<=c+1;
    end
           
  endtask
  
  
  task aempty;
    begin
    afull();
        
       // $display("%0d,%0d",full,dut.mem[i]); 
     
      @(posedge rclk);
      i=0;
      for(i=0;i<WIDTH+1;i++)begin 
        @(negedge rclk);
        ren=1;
        end 
//  @(negedge rclk);
        ren=0;

      
      if(empty==1)
        c=c;
      else
        c=c+1;
    end
  endtask
  
  task overflow;
    begin
    afull();
  @(negedge wclk);
    wen=1;
  @(negedge wclk);
    wen=0;
    
  if( dut.wptr==3'b100 &&full!=0)
    c=c;
  else
    c=c+1;
      end
      endtask
  
  
  task underflow;
  begin
    aempty();
  @(negedge rclk);
    ren=1;
  @(negedge rclk);
    ren=0;
    #10
  if(empty==1)
    c=c;
  else
    c=c+1;
      end
      endtask
  
  
  task sw;
    begin 
      @(negedge wclk);
        wen=1;
        data=12;
      //$display("%0d",data);
      @(negedge wclk);
        wen=0;
      repeat(3) @(posedge rclk);
      
      fork
        begin 
          @(negedge wclk);
        wen=1;
        data=13;
          //$display("%0d",data);
          @(negedge wclk);
        wen=0;
       end
        
        begin 
          @(negedge rclk);
        ren=1;
          @(negedge rclk);
        ren=0; 
         // $display("%0d",out);
        end
      
      join
      @(negedge rclk);
        ren=1;
      @(negedge rclk);
        ren=0; 
      //    $display("%0d",out);
      
   #10      
      if(out==4'hd)
        c=c;
      else
        c=c+1;
    end
  endtask
  
  task wrap;
    begin
      afull();
     @(negedge rclk);
        ren=1;
      @(negedge rclk);
        ren=0; 
      @(negedge wclk);
    wen=1;
    data=2;
      @(negedge wclk);
    wen=0;
      for(i=0;i<WIDTH+1;i++)begin 
        @(negedge rclk);
        ren=1;
        @(negedge rclk);
        ren=0;
       end
       $display("%0d   %0d",c,out);
      if(out == 2)
        c=c;
      else
        c=c+1;
    end
  endtask
endmodule
