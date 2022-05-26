library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity pipeline_reg_FD is
    port(
        clk           : in  std_logic;
        reset_n       : in  std_logic;
        I_rddata_in   : in  std_logic_vector(31 downto 0);
        next_addr_in  : in  std_logic_vector(15 downto 0);
        I_rddata_out  : out std_logic_vector(31 downto 0);
        next_addr_out : out std_logic_vector(15 downto 0)
    );
end pipeline_reg_FD;

architecture synth of pipeline_reg_FD is
    signal reg1 :  std_logic_vector(15 downto 0);
    signal reg2 :  std_logic_vector(31 downto 0); 

begin
   dff : process(clk, reset_n) is
    begin
        if(reset_n = '0') then 
            reg2 <= x"00000000";
            reg1 <= x"0000";
        elsif(rising_edge(clk)) then
            reg2 <= I_rddata_in;
            reg1 <= next_addr_in;
        end if;
       
   end process ; -- identifier

   I_rddata_out <= reg2;
   next_addr_out <= reg1;
end synth;
