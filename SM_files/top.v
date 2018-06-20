`include "me_consts.vh"

module acc;

  wire [`SMNL-1:0] state;
  wire waiting;

  wire param_even;
  wire q_select;
  wire [`PARAM_LEN-1:0] parameter_number;


  wire [31:0]arm_inst, push_inst, instr;
  wire valid_write;
  wire [`adr_rom_adr_size-1:0] link_list_ptr;


  wire [7:0] iram, oram_fp, oram_iter, jvm_opcode;
  wire iram_ready, oram_ready;

  reg clk;
  reg reset;

  assign waiting = !iram_ready || (!oram_ready && state == `ITERATE);
  //FIXME for now ignore 16bit params
  assign push_inst = !param_even?
    {12'hE34, 4'h0, 4'h0, 4'h0, iram[7:0]}:{32'hE5_2D_00_04};
  assign arm_inst = q_select == `Q_FETCH? push_inst : instr;
  assign fetch = (state == `FETCH_INSTRUCTION) ||
    (!param_even && (|parameter_number) && (state == `FETCH_PARAMS));
  assign valid_write = ((state == `ITERATE) ||
    (state == `FETCH_PARAMS && |parameter_number))&&|jvm_opcode&&!waiting;

  adr_to_arm decoder(.arm_inst(instr), .i(link_list_ptr));

  wire [`ADDRESS_WIDTH - 1: 0] pc_reset_value;
  assign pc_reset_value = 0;

  next_byte_gen n(.next_byte(iram), .ready(iram_ready),
    .pc_reset_value(pc_reset_value),
    .pc_reset(reset),
    .start(fetch),
    .clk(clk));

  state_machine sm(.state(state), .com_adr(link_list_ptr),
    .jvm_opcode(jvm_opcode),
    .q_select(q_select),
    .param_even(param_even),
    .parameter_number,
     .waiting(waiting), .iram_data(iram),
     .clk(clk), .reset(reset));

  count_rom c(.count(parameter_number), .opcode(jvm_opcode));

  write w(.data(arm_inst), .reset(reset), .clk(clk), .ready(oram_ready), .start(valid_write));
  initial begin
    clk = 0;
    reset = 1;
    #3 reset = 0;
    #3 reset = 1;
  end

  always
    #5 clk = !clk;
endmodule
