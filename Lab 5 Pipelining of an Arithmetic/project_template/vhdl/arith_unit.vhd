library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity arith_unit is
    port(
        clk     : in  std_logic;
        reset_n : in  std_logic;
        start   : in  std_logic;
        sel     : in  std_logic;
        A, B, C : in  unsigned(7 downto 0);
        D       : out unsigned(31 downto 0);
        done    : out std_logic
    );
end arith_unit;

-- =============================================================================
-- =============================== COMBINATORIAL ===============================
-- =============================================================================

architecture combinatorial of arith_unit is
	signal s_bc, s_a_square, s_to_square : unsigned(15 downto 0);
	signal s_square : unsigned(31 downto 0);
	signal s_add1, s_add2, s_mult : unsigned(15 downto 0);
	signal s_mult_result: unsigned(31 downto 0);
	
    component multiplier
        port(
            A, B : in  unsigned(7 downto 0);
            P    : out unsigned(15 downto 0)
        );
    end component;

    component multiplier16
        port(
            A, B : in  unsigned(15 downto 0);
            P    : out unsigned(31 downto 0)
        );
    end component;

begin
	mult1: multiplier
	PORT MAP(A => B,
	B => C,
	P => s_bc);
	

	mult2: multiplier
	PORT MAP(A => A,
	B => A,
	P => s_a_square);
	
	s_to_square <= s_a_square when sel = '1' else s_bc;


	s_add1 <= x"00" & A when sel = '0' else "0000000" & A & "0";
	s_add2 <= s_add1 + B;

	s_mult <= s_bc when sel = '0' else s_add2;

	
	mult3: multiplier16
	PORT MAP(A => s_to_square,
	B => s_to_square,
	P => s_square);
	
	mult4: multiplier16
	PORT MAP(A => s_add2,
	B => s_mult,
	P => s_mult_result);

	D <= s_mult_result + s_square;
	done <= start;

	
	

	

	
	
	
	
end combinatorial;

-- =============================================================================
-- ============================= 1 STAGE PIPELINE ==============================
-- =============================================================================

architecture one_stage_pipeline of arith_unit is
signal s_bc, s_a_square, s_to_square : unsigned(15 downto 0);
	signal s_square : unsigned(31 downto 0);
	signal s_add1, s_add2, s_mult : unsigned(15 downto 0);
	signal s_to_square_bis, s_mult_bis : unsigned(15 downto 0);
	signal s_mult_result: unsigned(31 downto 0);
	
    component multiplier
        port(
            A, B : in  unsigned(7 downto 0);
            P    : out unsigned(15 downto 0)
        );
    end component;

    component multiplier16
        port(
            A, B : in  unsigned(15 downto 0);
            P    : out unsigned(31 downto 0)
        );
    end component;

begin
	mult1: multiplier
	PORT MAP(A => B,
	B => C,
	P => s_bc);


	mult2: multiplier
	PORT MAP(A => A,
	B => A,
	P => s_a_square);
	
	s_to_square <= s_a_square when sel = '1' else s_bc;


	s_add1 <= x"00" & A when sel = '0' else "0000000" & A & "0";
	s_add2 <= s_add1 + B;

	s_mult <= s_bc when sel = '0' else s_add2;

	dff: process(clk, reset_n)is 
	begin
		if (rising_edge(clk)) then 
			s_mult_bis <= s_mult;
			s_to_square_bis <= s_to_square;
		elsif(reset_n = '0') then
			s_mult_bis <= x"0000";
			s_to_square_bis <= x"0000";
		end if;
			
	end process;
		
	
	

	mult3: multiplier16
	PORT MAP(A => s_to_square_bis ,
	B => s_to_square_bis,
	P => s_square);
	
	
	mult4: multiplier16
	PORT MAP(A => s_add2,
	B => s_mult,
	P => s_mult_result);

	D <= s_mult_result + s_square;
	done <= start;
	
	
end one_stage_pipeline;

-- =============================================================================
-- ============================ 2 STAGE PIPELINE I =============================
-- =============================================================================

architecture two_stage_pipeline_1 of arith_unit is
    component multiplier
        port(
            A, B : in  unsigned(7 downto 0);
            P    : out unsigned(15 downto 0)
        );
    end component;

    component multiplier16
        port(
            A, B : in  unsigned(15 downto 0);
            P    : out unsigned(31 downto 0)
        );
    end component;

begin
end two_stage_pipeline_1;

-- =============================================================================
-- ============================ 2 STAGE PIPELINE II ============================
-- =============================================================================

architecture two_stage_pipeline_2 of arith_unit is
    component multiplier
        port(
            A, B : in  unsigned(7 downto 0);
            P    : out unsigned(15 downto 0)
        );
    end component;

    component multiplier16_pipeline
        port(
            clk     : in  std_logic;
            reset_n : in  std_logic;
            A, B    : in  unsigned(15 downto 0);
            P       : out unsigned(31 downto 0)
        );
    end component;

begin
end two_stage_pipeline_2;
