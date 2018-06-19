// addr_rom, conv_rom addr: starts with opcode of the jvm instruction, follows the n_addr in addr_rom

module addr_rom(output [31:0] n_addr, input [31:0] addr); //used to store next address of the instruction
    reg [31:0] mem [31:0];
    always@* begin

    end
    assign data = mem[addr];
endmodule

module conv_rom(output [31:0] inst_id, input [31:0] addr); // instrs
    reg [31:0] mem [31:0];
    always@* begin

    end
    assign data = mem[addr];
endmodule

module inst_rom(output [31:0] instr, input [31:0] inst_id); // address of instrs
    reg [31:0] mem [31:0];
    always@* begin

    end
    assign data = mem[addr];
endmodule
//the state machine connects all modules and transfers the data
//it works by loading the opcode and pushing any available parameter into the
//stack.
module state_machine(
        input wire clk,
        input wire reset
    );
    wire next_byte;
    wire ready_jvm;
    wire ready_arm;
    reg start_fetch;
    reg start_write;
    reg is_wide;
    reg waiting;
    reg param_no; // number of bytes that we should fetch after jvm opcode - 1 (in this phase 0 or 1)
    reg push_state; // push_state: 0 -> write "mov imm to rf"      push_state: 1 -> write "push to stack"

    reg [2:0] state;
    reg [2:0] next_state;

    always@(negedge reset) begin
        start_fetch <= 1'b1;
        start_fetch <= 1'b0;
        is_wide <= 1'b0;
        start_fetch <= 1'b1;
        waiting <= 1'b1;
        param_no <= 1'b1;
        push_state <= 1'b1;
    end

    parameter FETCH_INSTRUCTION = 0;
    parameter CHECK_WIDE = 1;
    parameter READ_COUNTER = 2;
    parameter FETCH_PARAMS = 3;
    parameter PUSH_TO_STACK = 4; // bytes that come after jvm opcode as index, offset or etc are pushed to stack
    parameter READ_NEXT = 5;
    parameter WRITE_INSTRUCTION = 6;

    next_byte_gen  #(.SIZE(RAM_SIZE), .ADDRESS_WIDTH(ADDRESS_WIDTH))
    nbg
    (
        .next_byte(next_byte),
        .ready(ready_jvm),
        .pc_reset(1'b1),
        .start(start_fetch),
        .clk(clk),
        .instr(final_instr) // modify later
    );

    instruction_ram  #(.SIZE(RAM_SIZE), .ADDRESS_WIDTH(ADDRESS_WIDTH))
    instr_ram
    (

        .ready(ready_arm),
        .pc_reset(1'b1),
        .start(start_write),
        .clk(clk),
        .word(word_to_write)
    );

    wire [4:0] param_bits;
    reg [4:0] counter;
    reg [7:0] opcode;
    reg [7:0] mem_reg;
    reg [15:0] push_reg;
    wire [31:0] next_addr;
    reg [31:0] current_addr;
    wire [31:0] instr_id;
    reg [31:0] instr_id_reg;
    wire [31:0] instr_wire;
    reg [31:0] word_to_write;

    addr_rom next_addr_rom(
        .addr(current_addr),
        .n_addr(next_addr)
    );

    conv_rom converter(
        .inst_id(instr_id),
        .addr(current_addr)
    );

    inst_rom instrs(
        .inst_id(instr_id_reg),
        .instr(instr_wire)
    );

    cnt count_rom(
        .count(param_bits),
        .opcode(opcode)
    );

    always @(posedge clk) begin
        if (reset == 0'b0) begin
        case(state)

            FETCH_INSTRUCTION:
            //fetch instruciton opcode (can wait for memory to be ready)
                case(waiting)
                    1'b0: begin
                        start_fetch <= 1'b1;
                        waiting <= 1'b1;
                        next_state <= FETCH_INSTRUCTION;
                    end
                    1'b1: begin
                        start_fetch <= 1'b0;
                        if(ready_jvm == 1'b1) begin
                            opcode <= next_byte;
                            waiting <= 1'b0;
                            next_state <= CHECK_WIDE;
                        end
                        else begin
                            waiting <= 1'b1;
                            next_state <= FETCH_INSTRUCTION;
                        end
                    end
                endcase

            CHECK_WIDE:
            //handle the wide command and set appropriate bits to for handling
            //next command

                if(opcode == 8'b1100_0100) begin
                    is_wide <= 1'b1;
                    next_state <= FETCH_INSTRUCTION;
                end
                else begin
                   next_state = READ_COUNTER;
                end
            READ_COUNTER:
                //check if we have to read any parameter
                if (param_bits == 4'b000)
                    next_state <= WRITE_INSTRUCTION;
                else begin
                    counter <= param_bits;
                    next_state <= FETCH_PARAMS;
                end
            FETCH_PARAMS:
                //start fetching parameters
                //support a ready flag
                case(waiting)
                    1'b0: begin
                        start_fetch <= 1'b1;
                        waiting <= 1'b1;
                        next_state <= FETCH_PARAMS;
                    end
                    1'b1: begin
                        start_fetch <= 1'b0;
                        if(ready_jvm == 1'b1) begin
                            mem_reg <= next_byte;
                            counter <= counter - 1;
                            waiting <= 1'b0;
                            if (is_wide == 0'b0) begin
                                push_reg <= next_byte;
                                next_state <= PUSH_TO_STACK;
                            end
                            else if (param_no == 0'b0) begin
                                push_reg <= next_byte << 8;
                                param_no <= 0'b1;
                                next_state <= FETCH_PARAMS;
                            end
                            else if (param_no == 0'b1) begin
                                push_reg <= next_byte | push_reg;
                                param_no <= 0'b0;
                                next_state <= PUSH_TO_STACK;
                            end
                        end
                        else begin
                            waiting <= 1'b1;
                            next_state <= FETCH_PARAMS;
                        end
                    end
                endcase
                //push the data into the stack
            PUSH_TO_STACK: begin
                if (push_state == 0'b0) begin
                    word_to_write <= {12'hE34, push_reg[15:12], 4'h0, push_reg[11:0]};
                    push_state <= 0'b1;
                    next_state <= WRITE_INSTRUCTION;
                end
                else if (push_state == 0'b1) begin
                    word_to_write <= 31'hE5_2D_00_04;
                    push_state <= 0'b0;
                    next_state <= WRITE_INSTRUCTION;
                end
            end
            READ_NEXT: begin
                instr_id_reg <= instr_id;
                current_addr <= next_addr;
                word_to_write <= instr_wire;
            end

            WRITE_INSTRUCTION: begin
                case(waiting)
                    1'b0: begin
                        start_write <= 1'b1;
                        waiting <= 1'b1;
                        next_state <= WRITE_INSTRUCTION;
                    end
                    1'b1: begin
                        start_write <= 1'b0;
                        if(ready_arm == 1'b1) begin
                            waiting <= 1'b0;

                            if (next_addr == 0)
                                next_state <= FETCH_INSTRUCTION;
                            else if (push_state == 0'b0)
                                next_state <= PUSH_TO_STACK;
                            else
                                next_state <= READ_NEXT;
                        end
                        else begin
                            waiting <= 1'b1;
                            next_state <= WRITE_INSTRUCTION;
                        end
                    end
                endcase
            end
        endcase
        end
    end

endmodule
