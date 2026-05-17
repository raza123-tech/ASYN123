module async_fifo_16x8 (

    input  wire        wclk,
    input  wire        rclk,
    input  wire        rst,

    input  wire        wen,
    input  wire        ren,

    input  wire [7:0] data_in,

    output reg  [7:0] data_out,

    output wire       full,
    output wire       empty
);

    
    // MEMORY

    reg [7:0] mem [0:15];

    
    // POINTERS
    

    reg [4:0] wptr_bin;
    reg [4:0] rptr_bin;

    reg [4:0] wptr_gray;
    reg [4:0] rptr_gray;

    
    // SYNCHRONIZER POINTERS
    

    reg [4:0] wptr_gray_sync1;
    reg [4:0] wptr_gray_sync2;

    reg [4:0] rptr_gray_sync1;
    reg [4:0] rptr_gray_sync2;

    
    // WRITE LOGIC
  

    always @(posedge wclk or posedge rst) begin

        if (rst) begin

            wptr_bin  <= 5'b0;
            wptr_gray <= 5'b0;

        end

        else begin

            if (wen && !full) begin

                mem[wptr_bin[3:0]] <= data_in;

                wptr_bin <= wptr_bin + 1'b1;

                wptr_gray <= ((wptr_bin + 1'b1) >> 1)
                             ^ (wptr_bin + 1'b1);

            end
        end
    end

    
    // READ LOGIC
    

    always @(posedge rclk or posedge rst) begin

        if (rst) begin

            rptr_bin  <= 5'b0;
            rptr_gray <= 5'b0;

            data_out  <= 8'b0;

        end

        else begin

            if (ren && !empty) begin

                data_out <= mem[rptr_bin[3:0]];

                rptr_bin <= rptr_bin + 1'b1;

                rptr_gray <= ((rptr_bin + 1'b1) >> 1)
                             ^ (rptr_bin + 1'b1);

            end
        end
    end

  
    // SYNCHRONIZE WRITE POINTER INTO READ DOMAIN
  

    always @(posedge rclk or posedge rst) begin

        if (rst) begin

            wptr_gray_sync1 <= 5'b0;
            wptr_gray_sync2 <= 5'b0;

        end

        else begin

            wptr_gray_sync1 <= wptr_gray;
            wptr_gray_sync2 <= wptr_gray_sync1;

        end
    end

    
    // SYNCHRONIZE READ POINTER INTO WRITE DOMAIN
    

    always @(posedge wclk or posedge rst) begin

        if (rst) begin

            rptr_gray_sync1 <= 5'b0;
            rptr_gray_sync2 <= 5'b0;

        end

        else begin

            rptr_gray_sync1 <= rptr_gray;
            rptr_gray_sync2 <= rptr_gray_sync1;

        end
    end

    //----------------------------------------------------------
    // EMPTY CONDITION
    //----------------------------------------------------------

    assign empty = (wptr_gray_sync2 == rptr_gray);

    //----------------------------------------------------------
    // FULL CONDITION
    //----------------------------------------------------------

    assign full =
      ((((wptr_bin + 1'b1) >> 1)
      ^  (wptr_bin + 1'b1))
      ==
      {~rptr_gray_sync2[4:3],
        rptr_gray_sync2[2:0]});

endmodule
