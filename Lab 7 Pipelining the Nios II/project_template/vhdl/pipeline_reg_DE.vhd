library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity pipeline_reg_DE is
    port(
        clk           : in  std_logic;
        reset_n       : in  std_logic;
        a_in          : in  std_logic_vector(31 downto 0);
        b_in          : in  std_logic_vector(31 downto 0);
        d_imm_in      : in  std_logic_vector(31 downto 0);
        sel_b_in      : in  std_logic;
        op_alu_in     : in  std_logic_vector(5 downto 0);
        read_in       : in  std_logic;
        write_in      : in  std_logic;
        sel_pc_in     : in  std_logic;
        branch_op_in  : in  std_logic;
        sel_mem_in    : in  std_logic;
        rf_wren_in    : in  std_logic;
        mux_in        : in  std_logic_vector(4 downto 0);
        next_addr_in  : in  std_logic_vector(15 downto 0);
        -- out
        a_out         : out std_logic_vector(31 downto 0);
        b_out         : out std_logic_vector(31 downto 0);
        d_imm_out     : out std_logic_vector(31 downto 0);
        sel_b_out     : out std_logic;
        op_alu_out    : out std_logic_vector(5 downto 0);
        read_out      : out std_logic;
        write_out     : out std_logic;
        sel_pc_out    : out std_logic;
        branch_op_out : out std_logic;
        sel_mem_out   : out std_logic;
        rf_wren_out   : out std_logic;
        mux_out       : out std_logic_vector(4 downto 0);
        next_addr_out : out std_logic_vector(15 downto 0)
    );
end pipeline_reg_DE;

architecture synth of pipeline_reg_DE is
   signal a_in_reg, b_in_reg, d_imm_in_reg : std_logic_vector(31 downto 0);
   signal sel_b_in_reg, read_in_reg, write_in_reg, sel_pc_in_reg, branch_op_in_reg, sel_mem_in_reg,rf_wren_in_reg : std_logic;
   signal mux_in_reg : std_logic_vector(4 downto 0);
   signal next_addr_in_reg : std_logic_vector(15 downto 0);


begin
    dff : process(clk, reset_n) is 
    begin
        if (reset_n = '0') then 
            a_out <= (others => '0');
            b_out <= (others => '0');
            d_imm_out <= (others => '0');
            sel_b_out <= '0'; 
            read_out <= '0';
            write_out <= '0'; 
            sel_pc_out <= '0';
            branch_op_out <= '0';
            sel_mem_out <= '0';
            rf_wren_out <= '0';
            op_alu_out <= (others => '0');
            mux_out <= (others => '0');
            next_addr_out <= (others => '0');

        elsif (rising_edge(clk)) then 
            a_out <= a_in;
            b_out <= b_in;
            d_imm_out <= d_imm_in;
            sel_b_out <= sel_b_in; 
            read_out <= read_in;
            write_out <= write_in; 
            sel_pc_out <= sel_pc_in;
            branch_op_out <= branch_op_in;
            sel_mem_out <= sel_mem_in;
            rf_wren_out <= rf_wren_in;
            mux_out <= mux_in;
            op_alu_out <= op_alu_in;
            next_addr_out <= next_addr_in;
        end if;
    end process ; -- identifier

end synth;
