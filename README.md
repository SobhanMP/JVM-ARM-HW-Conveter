# JVM to ARM-7 Processor Project
## State Machine

### Instructions

| Mnemonic | Opcode (in hex) |Opcode (in binary) |Other byte[count]: [operand labels] | Stack [before]→[after] |Description |
|:---------|:------------------|:---------------------------------------|:---------------------------------------|:-----------------------------------------------------------------------------------------|:----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
|d2f       |90                 |1001 0000                               |                                      |value → result                                                                            |convert a double to a float                                                                                                                                                              |
|d2i       |8e                 |1000 1110                               |                                       |value → result                                                                            |convert a double to an int                                                                                                                                                               |
|d2l       |8f                 |1000 1111                               |                                       |value → result                                                                            |convert a double to a long                                                                                                                                                               |
|dadd      |63                 |0110 0011                               |                                       |value1, value2 → result                                                                   |add two doubles                                                                                                                                                                          |
|daload    |31                 |0011 0001                               |                                       |arrayref, index → value                                                                   |load a double from an array                                                                                                                                                              |
|dastore   |52                 |0101 0010                               |                                       |arrayref, index, value →                                                                  |store a double into an array                                                                                                                                                             |
|dcmpg     |98                 |1001 1000                               |                                       |value1, value2 → result                                                                   |compare two doubles                                                                                                                                                                      |
|dcmpl     |97                 |1001 0111                               |                                       |value1, value2 → result                                                                   |compare two doubles                                                                                                                                                                      |
|dconst_0  |0e                 |0000 1110                               |                                       |→ 0.0                                                                                     |push the constant 0.0 (a double) onto the stack                                                                                                                                          |
|dconst_1  |0f                 |0000 1111                               |                                       |→ 1.0                                                                                     |push the constant 1.0 (a double) onto the stack                                                                                                                                          |
|dup       |59                 |0101 1001                               |                                       |value → value, value                                                                      |duplicate the value on top of the stack                                                                                                                                                  |
|dup_x1    |5a                 |0101 1010                               |                                       |value2, value1 → value1, value2, value1                                                   |insert a copy of the top value into the stack two values from the top. value1 and value2 must not be of the type double or long.                                                         |
|dup_x2    |5b                 |0101 1011                               |                                       |value3, value2, value1 → value1, value3, value2, value1                                   |insert a copy of the top value into the stack two (if value2 is double or long it takes up the entry of value3, too) or three values (if value2 is neither double nor long) from the top |
|dup2      |5c                 |0101 1100                               |                                       |{value2, value1} → {value2, value1}, {value2, value1}                                     |duplicate top two stack words (two values, if value1 is not double nor long; a single value, if value1 is double or long)                                                                |
|dup2_x1   |5d                 |0101 1101                               |                                       |value3, {value2, value1} → {value2, value1}, value3, {value2, value1}                     |duplicate two words and insert beneath third word (see expla tion above)                                                                                                                |
|dup2_x2   |5e                 |0101 1110                               |                                       |{value4, value3}, {value2, value1} → {value2, value1}, {value4, value3}, {value2, value1} |duplicate two words and insert beneath fourth word                                                                                                                                       |
|f2d       |8d                 |1000 1101                               |                                       |value → result                                                                            |convert a float to a double                                                                                                                                                              |
|f2i       |8b                 |1000 1011                               |                                       |value → result                                                                            |convert a float to an int                                                                                                                                                                |
|f2l       |8c                 |1000 1100                               |                                       |value → result                                                                            |convert a float to a long                                                                                                                                                                |
|fadd      |62                 |0110 0010                               |                                       |value1, value2 → result                                                                   |add two floats                                                                                                                                                                           |
|faload    |30                 |0011 0000                               |                                       |arrayref, index → value                                                                   |load a float from an array                                                                                                                                                               |
|fastore   |51                 |0101 0001                               |                                       |arrayref, index, value →                                                                  |store a float in an array                                                                                                                                                                |
|fcmpg     |96                 |1001 0110                               |                                       |value1, value2 → result                                                                   |compare two floats                                                                                                                                                                       |
|fcmpl     |95                 |1001 0101                               |                                       |value1, value2 → result                                                                   |compare two floats                                                                                                                                                                       |
|fconst_0  |0b                 |0000 1011                               |                                       |→ 0.0f                                                                                    |push 0.0f on the stack                                                                                                                                                                   |
|fconst_1  |0c                 |0000 1100                               |                                       |→ 1.0f                                                                                    |push 1.0f on the stack                                                                                                                                                                   |
|fconst_2  |0d                 |0000 1101                               |                                       |→ 2.0f                                                                                    |push 2.0f on the stack                                                                                                                                                                   |
|fdiv      |6e                 |0110 1110                               |                                       |value1, value2 → result                                                                   |divide two floats                                                                                                                                                                        |
|fload     |17                 |0001 0111                               |1: index                                |→ value                                                                                   |load a float value from a local variable #index                                                                                                                                          |
|fload_0   |22                 |0010 0010                               |                                       |→ value                                                                                   |load a float value from local variable 0                                                                                                                                                 |
|fload_1   |23                 |0010 0011                               |                                       |→ value                                                                                   |load a float value from local variable 1                                                                                                                                                 |
|fload_2   |24                 |0010 0100                               |                                       |→ value                                                                                   |load a float value from local variable 2                                                                                                                                                 |
|fload_3   |25                 |0010 0101                               |                                       |→ value                                                                                   |load a float value from local variable 3                                                                                                                                                 |
|fmul      |6a                 |0110 1010                               |                                       |value1, value2 → result                                                                   |multiply two floats                                                                                                                                                                      |
|fneg      |76                 |0111 0110                               |                                       |value → result                                                                            |negate a float                                                                                                                                                                           |
|frem      |72                 |0111 0010                               |                                       |value1, value2 → result                                                                   |get the remainder from a division between two floats                                                                                                                                     |
|nop       |00                 |0000 0000                               |                                       |[No change]                                                                               |perform no operation                                                                                                                                                                     |
|pop       |57                 |0101 0111                               |                                       |value →                                                                                   |discard the top value on the stack                                                                                                                                                       |
|pop2      |58                 |0101 1000                               |                                       |{value2, value1} →                                                                        |discard the top two values on the stack (or one value, if it is a double or long)                                                                                                        |
|swap      |5f                 |0101 1111                               |                                       |value2, value1 → value1, value2                                                           |swaps two top words on the stack (note that value1 and value2 must not be double or long)                                                                                                |

### Structure

#### ROMS

* A rom for next instruction addresses in asscociate with a rom which holds the instruction id associated with current address.
* A rom to hold unique instructions.
* A rom to hold the instruction of pushing a word into stack.

#### Argument Passing

* We deal with instruction like functions and we use stack to store passed arguments.