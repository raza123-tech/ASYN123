**Testbench & Verification**
The testbench (test.sv) uses a task-based approach to verify the asynchronous FIFO's functionality across various corner cases. It supports dynamic test selection using the +TESTNAME plusarg.


**Configuration**
Data Width: 8 bits (WIDTH=8)
FIFO Depth: 4 locations (DEPTH=4)
Write Clock (wclk): 100MHz (10ns period)
Read Clock (rclk): 50MHz (20ns period)

**Verification Scenarios**
Testcase	          Description
reset   	          Verifies that asserting rst clears pointers and asserts the empty flag.
write	              Writes a single data element and checks if empty de-asserts (accounting for synchronization delay).
read	              Writes data, waits for synchronization, reads it back, and compares the value.
afull	              Fills the FIFO to its maximum capacity and verifies the full flag.
aempty	            Fills then drains the FIFO completely to verify the empty flag.
overflow 	          Attempts to write to a full FIFO and ensures pointers do not increment incorrectly.
underflow	          Attempts to read from an empty FIFO and ensures the empty state is maintained.
wrap	              Verifies pointer wrapping (circular behavior) by filling, reading one, writing one, and draining.
sw (Simultaneous)	  Performs simultaneous write and read operations in different clock domains.


