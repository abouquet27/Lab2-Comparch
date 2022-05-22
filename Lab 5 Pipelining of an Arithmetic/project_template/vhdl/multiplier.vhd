-- =============================================================================
-- ================================= multiplier ================================
-- =============================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity multiplier is
    port(
        A, B : in  unsigned(7 downto 0);
        P    : out unsigned(15 downto 0)
    );
end multiplier;

architecture combinatorial of multiplier is
	signal v1,v2,v3,v4: unsigned(15 downto 0);
	signal v1Prime,v2Prime,v3Prime,v4Prime: unsigned(15 downto 0);
	signal v5, v6: unsigned(19 downto 0);
	signal v7 : unsigned(23 downto 0);

begin
	v1Prime <= x"00" & ((7 downto 0 => A(0)) and B);
	v1 <= v1Prime + (((7 downto 0 => A(1)) and B) & b"0");

	v2Prime <= x"00" & ((7 downto 0 => A(2)) and B);
	v2 <= v2Prime + (((7 downto 0 => A(3)) and B) & b"0");

	v3Prime <= x"00" & ((7 downto 0 => A(4)) and B);
	v3 <= v3Prime + (((7 downto 0 => A(5)) and B) & b"0");

	v4Prime <= x"00" & ((7 downto 0 => A(6)) and B);
	v4 <= v4Prime + (((7 downto 0 => A(7)) and B) & b"0");

	v5 <= "00" & (v1 + (v2 & "00"));
	v6 <= "00" & (v3 + (v4 & "00"));
	
	v7 <= v5 + (v6 & "0000");
	P <= v7(15 downto 0);

	

end combinatorial;

-- =============================================================================
-- =============================== multiplier16 ================================
-- =============================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity multiplier16 is
    port(
        A, B : in  unsigned(15 downto 0);
        P    : out unsigned(31 downto 0)
    );
end multiplier16;

architecture combinatorial of multiplier16 is
	signal a1_b1, a2_b1, a1_b2, a2_b2 : unsigned(15 downto 0);
	signal s_out1, s_out2, s_out3: unsigned(31 downto 0);
    -- 8-bit multiplier component declaration
    component multiplier
        port(
            A, B : in  unsigned(7 downto 0);
            P    : out unsigned(15 downto 0)
        );
    end component;
 

begin
	mult1: multiplier
	PORT MAP(A => A(7 downto 0),
		B => B(7 downto 0),
		P => a1_b1);
	
	mult2: multiplier
	PORT MAP(A => A(15 downto 8),
		B => B(7 downto 0),
		P => a2_b1);
	mult3: multiplier
	PORT MAP(A => A(7 downto 0),
		B => B(15 downto 8),
		P => a1_b2);
	mult4: multiplier
	PORT MAP(A => A(15 downto 8),
		B => B(15 downto 8),
		P => a2_b2);
	
	s_out1 <= x"0000" & a1_b1;
	s_out2 <= s_out1 + ((a1_b2 + a2_b1) & x"00");
	s_out3 <= s_out2 + (a2_b2 & x"0000");
	P <= s_out3;
	

	

end combinatorial;

-- =============================================================================
-- =========================== multiplier16_pipeline ===========================
-- =============================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity multiplier16_pipeline is
    port(
        clk     : in  std_logic;
        reset_n : in  std_logic;
        A, B    : in  unsigned(15 downto 0);
        P       : out unsigned(31 downto 0)
    );
end multiplier16_pipeline;

architecture pipeline of multiplier16_pipeline is
	signal a1_b1, a2_b1, a1_b2, a2_b2 : unsigned(15 downto 0);
	signal a1_b1_copy, a2_b1_copy, a1_b2_copy, a2_b2_copy : unsigned(15 downto 0);
	signal s_out1, s_out2, s_out3: unsigned(31 downto 0);
    -- 8-bit multiplier component declaration
    component multiplier
        port(
            A, B : in  unsigned(7 downto 0);
            P    : out unsigned(15 downto 0)
        );
    end component;


begin
	mult1: multiplier
	PORT MAP(A => A(7 downto 0),
		B => B(7 downto 0),
		P => a1_b1);
	
	mult2: multiplier
	PORT MAP(A => A(15 downto 8),
		B => B(7 downto 0),
		P => a2_b1);
	mult3: multiplier
	PORT MAP(A => A(7 downto 0),
		B => B(15 downto 8),
		P => a1_b2);
	mult4: multiplier
	PORT MAP(A => A(15 downto 8),
		B => B(15 downto 8),
		P => a2_b2);
	
	dff : process(clk, reset_n) is
		begin
			if(reset_n = '0') then
				a1_b1_copy <= x"0000";
				a1_b2_copy <= x"0000";
				a2_b1_copy <= x"0000";
				a2_b2_copy <= x"0000";
			elsif(rising_edge(clk)) then
				a1_b1_copy <= a1_b1;
				a1_b2_copy <= a1_b2;
				a2_b1_copy <= a2_b1;
				a2_b2_copy <= a2_b2;

		end if;				
	end process;
	s_out1 <= x"0000" & a1_b1_copy;
	s_out2 <= s_out1 + ((a1_b2_copy + a2_b1_copy) & x"00");
	s_out3 <= s_out2 + (a2_b2_copy & x"0000");
	P <= s_out3;
end pipeline;
