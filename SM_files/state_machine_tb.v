`include "me_consts.vh"
module state_machine_tb ();

   wire [`SMNL - 1: 0] state;
   wire [`adr_rom_adr_size - 1: 0] com_adr;
   wire [7:0] jvm_opcode;
   wire q_select;
   wire param_even;

   wire push_wide;
   wire is_wide;

   reg [7:0] iram_data;
   reg [`PARAM_LEN - 1:0] parameter_number;
   reg clk;
   reg reset;
   reg waiting;

   state_machine sm(
     .state(state),
     .com_adr(com_adr),
     .jvm_opcode(jvm_opcode),
     .q_select(q_select),
     .param_even(param_even),
     .push_wide(push_wide),
     .is_wide(is_wide),

     .waiting(waiting),
     .iram_data(iram_data),
     .parameter_number(parameter_number),
     .clk(clk),
     .reset(reset));


  initial begin
  //fill stuff with random data
    waiting = 0;
    clk = 0;
    reset = 0;
    parameter_number = 2;
    iram_data = 11;

    #2 reset = 1;
    #2 reset = 0;
    #2 reset = 1;


  end

  always begin
    #2 clk = !clk;
    iram_data <= iram_data + 1;
  end

endmodule
