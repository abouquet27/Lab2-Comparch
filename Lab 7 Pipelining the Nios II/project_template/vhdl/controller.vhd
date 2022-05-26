library ieee;
use ieee.std_logic_1164.all;

entity controller is
    port(
        op         : in  std_logic_vector(5 downto 0);
        opx        : in  std_logic_vector(5 downto 0);
        imm_signed : out std_logic;
        sel_b      : out std_logic;
        op_alu     : out std_logic_vector(5 downto 0);
        read       : out std_logic;
        write      : out std_logic;
        sel_pc     : out std_logic;
        branch_op  : out std_logic;
        sel_mem    : out std_logic;
        rf_wren    : out std_logic;
        pc_sel_imm : out std_logic;
        pc_sel_a   : out std_logic;
        sel_ra     : out std_logic;
        rf_retaddr : out std_logic_vector(4 downto 0);
        sel_rC     : out std_logic
    );
end controller;

architecture synth of controller is

begin

	-- FETCH 1 : The PC holds the address of the next instruction. The address is
	-- stored in a 16-bit register. The address must always be valid, thus the two least significant bits should
	-- remains at ?0?
	
	-- FETCH 2: the instruction word is read from the input rddata and saved in a register.
	-- The Controller enables the PC, so that it increments the address by 4. 

	-- DECODE: the Controller reads the opcode of the instruction to identify the current
	-- instruction and determines the next Execute state

    comb_proc: process(op, opx) 
    begin
        read       <= '0';
        write      <= '0';
        branch_op  <= '0';
        pc_sel_a   <= '0';
        pc_sel_imm <= '0';
        rf_wren    <= '0';
        imm_signed <= '0';
        sel_b      <= '0';
        sel_mem    <= '0';
        sel_pc     <= '0';
        sel_ra     <= '0';
        sel_rC     <= '0';
        rf_retaddr <= "11111";



        case ("00" & op) is
            when x"3A" =>
                case ("00" & opx) is 
                    -- R_OP
                    when x"31" | x"39" | x"08" | x"10" | x"06" | x"0E" | x"16" |
                            x"1E" | x"13" | x"1B" | x"3B" | x"18" | x"20" | x"28" |
                            x"30" | x"03" | x"0B" =>
                        rf_wren    <= '1';
                        sel_b      <= '1';
                        sel_rC     <= '1';
                    -- CALLR
                    when x"1D" =>
                        rf_wren    <= '1';
                        
                        sel_pc     <= '1';
                        sel_ra     <= '1';
                        pc_sel_a   <= '1';
                    -- JMP
                    when x"05" | x"0D"  =>
                        pc_sel_a   <= '1';
                    -- RI_OP
                    when x"12" | x"1A" | x"3A" | x"02" =>
                        rf_wren    <= '1';
                        sel_rC     <= '1';
                    -- Break
                    when others =>
                        null;
                end case;
            -- IO_P
            when x"04" | x"08" | x"10" | x"18" | x"20" =>
                rf_wren    <= '1';
                imm_signed <= '1';
            -- LOAD1
            when x"17" =>
                imm_signed <= '1';
                sel_mem    <= '1';
                rf_wren    <= '1';
                read       <= '1';
            -- STORE
            when x"15" =>
                write      <= '1';
                imm_signed <= '1';
            -- BRANCH
            when x"06" | x"0E" | x"16" | x"1E" | x"26" | x"2E" | x"36" =>
                branch_op  <= '1';
                sel_b      <= '1';
            -- CALL
            when x"00" =>
                rf_wren    <= '1';
                sel_pc     <= '1';
                sel_ra     <= '1';
                pc_sel_imm <= '1';
            -- JMPI
            when x"01" =>
                pc_sel_imm <= '1';
            -- UI_OP
            when x"0C" | x"14" | x"1C" | x"28" | x"30" =>
                rf_wren    <= '1';
            -- Other
            when others =>
                null;
            
        end case;
    end process;

              -- R_OP type operations
    op_alu <= "110" & opx(5 downto 3) when ("00" & op) = x"3A" and ("00" & opx) = x"34" else -- break
              "000" & opx(5 downto 3) when ("00" & op) = x"3A" and ("00" & opx) = x"31" else -- add   operation
              "001" & opx(5 downto 3) when ("00" & op) = x"3A" and ("00" & opx) = x"39" else -- sub   operation
              "011" & opx(5 downto 3) when ("00" & op) = x"3A" and ("00" & opx) = x"08" else -- cmple  operation
              "011" & opx(5 downto 3) when ("00" & op) = x"3A" and ("00" & opx) = x"10" else -- cmpgt  operation
              "100" & opx(5 downto 3) when ("00" & op) = x"3A" and ("00" & opx) = x"06" else -- nor    operation
              "100" & opx(5 downto 3) when ("00" & op) = x"3A" and ("00" & opx) = x"0E" else -- and    operation
              "100" & opx(5 downto 3) when ("00" & op) = x"3A" and ("00" & opx) = x"16" else -- or     operation
              "100" & opx(5 downto 3) when ("00" & op) = x"3A" and ("00" & opx) = x"1E" else -- xnor   operation
              "110" & opx(5 downto 3) when ("00" & op) = x"3A" and ("00" & opx) = x"13" else -- sll    operation
              "110" & opx(5 downto 3) when ("00" & op) = x"3A" and ("00" & opx) = x"1B" else -- srl    operation
              "110" & opx(5 downto 3) when ("00" & op) = x"3A" and ("00" & opx) = x"3B" else -- sra    operation
              "011" & opx(5 downto 3) when ("00" & op) = x"3A" and ("00" & opx) = x"18" else -- cmpne  operation
              "011" & opx(5 downto 3) when ("00" & op) = x"3A" and ("00" & opx) = x"20" else -- cmpeq  operation
              "011" & opx(5 downto 3) when ("00" & op) = x"3A" and ("00" & opx) = x"28" else -- cmpleu operation
              "011" & opx(5 downto 3) when ("00" & op) = x"3A" and ("00" & opx) = x"30" else -- cmpgtu operation
              "110" & opx(5 downto 3) when ("00" & op) = x"3A" and ("00" & opx) = x"03" else -- rol    operation
              "110" & opx(5 downto 3) when ("00" & op) = x"3A" and ("00" & opx) = x"0B" else -- ror    operation
              -- RI_OP type operations
              "110" & opx(5 downto 3) when ("00" & op) = x"3A" and ("00" & opx) = x"12" else -- slli   operation
              "110" & opx(5 downto 3) when ("00" & op) = x"3A" and ("00" & opx) = x"1A" else -- srli   operation
              "110" & opx(5 downto 3) when ("00" & op) = x"3A" and ("00" & opx) = x"3A" else -- srai   operation
              "110" & opx(5 downto 3) when ("00" & op) = x"3A" and ("00" & opx) = x"02" else -- roli   operation
              -- I_OP type operations
              "000" & op(5 downto 3) when ("00" & op) = x"04" else -- addi    operation
              "000" & op(5 downto 3) when ("00" & op) = x"17" else -- ldw     operation
              "000" & op(5 downto 3) when ("00" & op) = x"15" else -- stw     operation
              "011" & op(5 downto 3) when ("00" & op) = x"06" else -- br      operation
              "011" & op(5 downto 3) when ("00" & op) = x"0E" else -- ble     operation
              "011" & op(5 downto 3) when ("00" & op) = x"16" else -- bgt     operation
              "011" & op(5 downto 3) when ("00" & op) = x"1E" else -- bne     operation
              "011" & op(5 downto 3) when ("00" & op) = x"26" else -- beq     operation
              "011" & op(5 downto 3) when ("00" & op) = x"2E" else -- bleu    operation
              "011" & op(5 downto 3) when ("00" & op) = x"36" else -- bgt     operation
              "011" & op(5 downto 3) when ("00" & op) = x"08" else -- cmplei  operation
              "011" & op(5 downto 3) when ("00" & op) = x"10" else -- cmpgti  operation
              "011" & op(5 downto 3) when ("00" & op) = x"18" else -- cmpnei  operation
              "011" & op(5 downto 3) when ("00" & op) = x"20" else -- cmpeqi  operation
              -- UI_OP type operations
              "011" & op(5 downto 3) when ("00" & op) = x"28" else -- cmpleui operation
              "011" & op(5 downto 3) when ("00" & op) = x"30" else -- cmpgtui operation
              "100" & op(5 downto 3) when ("00" & op) = x"0C" else -- andi    operation
              "100" & op(5 downto 3) when ("00" & op) = x"14" else -- ori     operation
              "100" & op(5 downto 3) when ("00" & op) = x"1C" else -- xnori   operation  
              -- default case
              "000000";

end synth;

