library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity PC is
    port(
        clk       : in  std_logic;
        reset_n   : in  std_logic;
        sel_a     : in  std_logic;
        sel_imm   : in  std_logic;
        branch    : in  std_logic;
        a         : in  std_logic_vector(15 downto 0);
        d_imm     : in  std_logic_vector(15 downto 0);
        e_imm     : in  std_logic_vector(15 downto 0);
        pc_addr   : in  std_logic_vector(15 downto 0);
        addr      : out std_logic_vector(15 downto 0);
        next_addr : out std_logic_vector(15 downto 0)
    );
end PC;

architecture synth of PC is

    signal s_current_addr : std_logic_vector(15 downto 0) := (OTHERS => '0');
    signal s_next_addr    : std_logic_vector(15 downto 0);

    signal s_add1, s_add2 : std_logic_vector(15 downto 0) := (OTHERS => '0');

begin

    s_add1 <= s_current_addr when branch = '0' else pc_addr;
    s_add2 <= std_logic_vector(to_unsigned(4, 16)) when branch = '0' else std_logic_vector(unsigned(e_imm) + to_unsigned(4, 16));


    s_next_addr <= std_logic_vector(unsigned(s_add1) + unsigned(s_add2))    when sel_imm = '0' and sel_a = '0' else -- BRANCH           : PC <= PC + signed(imm)
                   std_logic_vector(unsigned(a) + to_unsigned(4, 16))       when sel_imm = '0' and sel_a = '1' else -- CALL | JMPI      : PC <= imm << 2
                   d_imm(13 downto 0) & "00"                                when sel_imm = '1' and sel_a = '0' else -- CALLR | JMP | RET: PC <= a
                   (OTHERS => 'Z');                         -- Other states     : PC <= PC + 4

    addr <= s_next_addr;

    dff_pc: process(clk, reset_n)
    begin
        if (reset_n = '0') then
            s_current_addr <= (others => '0');
        else
            if (rising_edge(clk)) then
                s_current_addr <= s_next_addr;
            end if;
        end if;
    end process;

    next_addr <= s_current_addr(15 downto 2) & "00";
    

end synth;
