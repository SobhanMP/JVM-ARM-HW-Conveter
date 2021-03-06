module memory_r #(
		parameter SIZE = 256,
    parameter ADDRESS_WIDTH = 8)
    (
        output wire ready,
				output reg [7:0] data_out,

        input wire clk,
        input wire reset,

        input wire [ADDRESS_WIDTH - 1:0] address,
        input wire start
    );


	reg [7:0] array[SIZE -1:0];
	reg state;
	reg [7:0] ad_t;
	reg [31:0] data_t;
	reg [1:0] counter;

	assign ready=~state;

	integer i;
	initial
		$readmemh("..\\rom_generator\\input", array);
	always @(posedge clk or negedge reset)
		begin
		if(reset == 0) begin
			
			$display("read mem %d %d %d %d\n", array[0], array[1], array[2], array[3]);
	
			ad_t <= 0;
			state <= 1'b0;
			counter <= 0;
		end
		else if(start & ~state) begin
			ad_t <= address[7:0];
			counter <= address[1:0];
			state <= 1;
		end
		//try to create some sort of random delay
		else if(|counter && state)
			counter <= counter-1;
		else	if(state) begin

			data_out <= array[ad_t%SIZE];

			state <= 0;
			end
	end
endmodule
