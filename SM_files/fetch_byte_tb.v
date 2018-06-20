`include "me_consts.vh"

module fetch_byte_tb;

  reg [`SMNL-1:0] state;
  wire fetch;
  reg param_even;
  reg [7:0] parameter_number;
  fetch_byte f(.fetch(fetch), .param_even(param_even),
    .parameter_number(parameter_number), .state(state));


  initial begin
    state = 0;
    param_even = 0;
    parameter_number = 0;
  end

  always #32 param_even = !param_even;
  always #4 state = state + 1;
  always #32 parameter_number = parameter_number + 1;




endmodule
