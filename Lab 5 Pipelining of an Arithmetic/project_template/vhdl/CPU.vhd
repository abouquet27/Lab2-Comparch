-- Copyright (C) 1991-2016 Altera Corporation. All rights reserved.
-- Your use of Altera Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Altera Program License 
-- Subscription Agreement, the Altera Quartus Prime License Agreement,
-- the Altera MegaCore Function License Agreement, or other 
-- applicable license agreement, including, without limitation, 
-- that your use is for the sole purpose of programming logic 
-- devices manufactured by Altera and sold by Altera or its 
-- authorized distributors.  Please refer to the applicable 
-- agreement for further details.

-- PROGRAM		"Quartus Prime"
-- VERSION		"Version 16.0.0 Build 211 04/27/2016 SJ Lite Edition"
-- CREATED		"Fri May 27 11:49:24 2022"

LIBRARY ieee;
USE ieee.std_logic_1164.all; 

LIBRARY work;

ENTITY CPU IS 
	PORT
	(
		reset_n :  IN  STD_LOGIC;
		clk :  IN  STD_LOGIC;
		D_rddata :  IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
		I_rddata :  IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
		D_read :  OUT  STD_LOGIC;
		D_write :  OUT  STD_LOGIC;
		D_addr :  OUT  STD_LOGIC_VECTOR(15 DOWNTO 0);
		D_wrdata :  OUT  STD_LOGIC_VECTOR(31 DOWNTO 0);
		I_addr :  OUT  STD_LOGIC_VECTOR(15 DOWNTO 0)
	);
END CPU;

ARCHITECTURE bdf_type OF CPU IS 

COMPONENT alu
	PORT(a : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 b : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 op : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
		 s : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT extend
	PORT(signed : IN STD_LOGIC;
		 imm16 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 imm32 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT pipeline_reg_mw
	PORT(clk : IN STD_LOGIC;
		 reset_n : IN STD_LOGIC;
		 rf_wren_in : IN STD_LOGIC;
		 mux_1_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 mux_2_in : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 rf_wren_out : OUT STD_LOGIC;
		 mux_1_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		 mux_2_out : OUT STD_LOGIC_VECTOR(4 DOWNTO 0)
	);
END COMPONENT;

COMPONENT pipeline_reg_fd
	PORT(clk : IN STD_LOGIC;
		 reset_n : IN STD_LOGIC;
		 I_rddata_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 next_addr_in : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 I_rddata_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		 next_addr_out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
	);
END COMPONENT;

COMPONENT pipeline_reg_em
	PORT(clk : IN STD_LOGIC;
		 reset_n : IN STD_LOGIC;
		 sel_mem_in : IN STD_LOGIC;
		 rf_wren_in : IN STD_LOGIC;
		 mux_1_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 mux_2_in : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 sel_mem_out : OUT STD_LOGIC;
		 rf_wren_out : OUT STD_LOGIC;
		 mux_1_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		 mux_2_out : OUT STD_LOGIC_VECTOR(4 DOWNTO 0)
	);
END COMPONENT;

COMPONENT pipeline_reg_de
	PORT(clk : IN STD_LOGIC;
		 reset_n : IN STD_LOGIC;
		 sel_b_in : IN STD_LOGIC;
		 read_in : IN STD_LOGIC;
		 write_in : IN STD_LOGIC;
		 sel_pc_in : IN STD_LOGIC;
		 branch_op_in : IN STD_LOGIC;
		 sel_mem_in : IN STD_LOGIC;
		 rf_wren_in : IN STD_LOGIC;
		 a_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 b_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 d_imm_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 mux_in : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 next_addr_in : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 op_alu_in : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
		 sel_b_out : OUT STD_LOGIC;
		 read_out : OUT STD_LOGIC;
		 write_out : OUT STD_LOGIC;
		 sel_pc_out : OUT STD_LOGIC;
		 branch_op_out : OUT STD_LOGIC;
		 sel_mem_out : OUT STD_LOGIC;
		 rf_wren_out : OUT STD_LOGIC;
		 a_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		 b_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		 d_imm_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		 mux_out : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
		 next_addr_out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		 op_alu_out : OUT STD_LOGIC_VECTOR(5 DOWNTO 0)
	);
END COMPONENT;

COMPONENT pc
	PORT(clk : IN STD_LOGIC;
		 reset_n : IN STD_LOGIC;
		 sel_a : IN STD_LOGIC;
		 sel_imm : IN STD_LOGIC;
		 branch : IN STD_LOGIC;
		 a : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 d_imm : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 e_imm : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 pc_addr : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 addr : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		 next_addr : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
	);
END COMPONENT;

COMPONENT controller
	PORT(op : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
		 opx : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
		 imm_signed : OUT STD_LOGIC;
		 sel_b : OUT STD_LOGIC;
		 read : OUT STD_LOGIC;
		 write : OUT STD_LOGIC;
		 sel_pc : OUT STD_LOGIC;
		 branch_op : OUT STD_LOGIC;
		 sel_mem : OUT STD_LOGIC;
		 rf_wren : OUT STD_LOGIC;
		 pc_sel_imm : OUT STD_LOGIC;
		 pc_sel_a : OUT STD_LOGIC;
		 sel_ra : OUT STD_LOGIC;
		 sel_rC : OUT STD_LOGIC;
		 op_alu : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
		 rf_retaddr : OUT STD_LOGIC_VECTOR(4 DOWNTO 0)
	);
END COMPONENT;

COMPONENT mux2x5
	PORT(sel : IN STD_LOGIC;
		 i0 : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 i1 : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 o : OUT STD_LOGIC_VECTOR(4 DOWNTO 0)
	);
END COMPONENT;

COMPONENT mux2x32
	PORT(sel : IN STD_LOGIC;
		 i0 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 i1 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 o : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT register_file
	PORT(clk : IN STD_LOGIC;
		 wren : IN STD_LOGIC;
		 aa : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 ab : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 aw : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 wrdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 a : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		 b : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

SIGNAL	a :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	aa :  STD_LOGIC_VECTOR(31 DOWNTO 27);
SIGNAL	ab :  STD_LOGIC_VECTOR(26 DOWNTO 22);
SIGNAL	alu_res :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	aw :  STD_LOGIC;
SIGNAL	aw0 :  STD_LOGIC;
SIGNAL	aw1 :  STD_LOGIC;
SIGNAL	aw122 :  STD_LOGIC;
SIGNAL	aw123 :  STD_LOGIC;
SIGNAL	aw124 :  STD_LOGIC;
SIGNAL	aw125 :  STD_LOGIC;
SIGNAL	aw126 :  STD_LOGIC;
SIGNAL	aw2 :  STD_LOGIC;
SIGNAL	aw217 :  STD_LOGIC;
SIGNAL	aw218 :  STD_LOGIC;
SIGNAL	aw219 :  STD_LOGIC;
SIGNAL	aw220 :  STD_LOGIC;
SIGNAL	aw221 :  STD_LOGIC;
SIGNAL	aw3 :  STD_LOGIC;
SIGNAL	aw4 :  STD_LOGIC;
SIGNAL	b :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	d_imm :  STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL	e_imm :  STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL	imm16 :  STD_LOGIC_VECTOR(21 DOWNTO 6);
SIGNAL	Instr :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	op :  STD_LOGIC_VECTOR(5 DOWNTO 0);
SIGNAL	opx :  STD_LOGIC_VECTOR(16 DOWNTO 11);
SIGNAL	pc_addr :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	sel_a :  STD_LOGIC;
SIGNAL	sel_branch :  STD_LOGIC;
SIGNAL	sel_imm :  STD_LOGIC;
SIGNAL	wrdata :  STD_LOGIC;
SIGNAL	wrdata0 :  STD_LOGIC;
SIGNAL	wrdata1 :  STD_LOGIC;
SIGNAL	wrdata10 :  STD_LOGIC;
SIGNAL	wrdata11 :  STD_LOGIC;
SIGNAL	wrdata12 :  STD_LOGIC;
SIGNAL	wrdata13 :  STD_LOGIC;
SIGNAL	wrdata14 :  STD_LOGIC;
SIGNAL	wrdata15 :  STD_LOGIC;
SIGNAL	wrdata16 :  STD_LOGIC;
SIGNAL	wrdata17 :  STD_LOGIC;
SIGNAL	wrdata18 :  STD_LOGIC;
SIGNAL	wrdata19 :  STD_LOGIC;
SIGNAL	wrdata2 :  STD_LOGIC;
SIGNAL	wrdata20 :  STD_LOGIC;
SIGNAL	wrdata21 :  STD_LOGIC;
SIGNAL	wrdata22 :  STD_LOGIC;
SIGNAL	wrdata23 :  STD_LOGIC;
SIGNAL	wrdata24 :  STD_LOGIC;
SIGNAL	wrdata25 :  STD_LOGIC;
SIGNAL	wrdata26 :  STD_LOGIC;
SIGNAL	wrdata27 :  STD_LOGIC;
SIGNAL	wrdata28 :  STD_LOGIC;
SIGNAL	wrdata29 :  STD_LOGIC;
SIGNAL	wrdata3 :  STD_LOGIC;
SIGNAL	wrdata30 :  STD_LOGIC;
SIGNAL	wrdata31 :  STD_LOGIC;
SIGNAL	wrdata4 :  STD_LOGIC;
SIGNAL	wrdata5 :  STD_LOGIC;
SIGNAL	wrdata6 :  STD_LOGIC;
SIGNAL	wrdata7 :  STD_LOGIC;
SIGNAL	wrdata8 :  STD_LOGIC;
SIGNAL	wrdata9 :  STD_LOGIC;
SIGNAL	wren :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_0 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_1 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_2 :  STD_LOGIC_VECTOR(5 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_3 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_4 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_5 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_6 :  STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_7 :  STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_8 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_9 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_10 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_11 :  STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_12 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_13 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_14 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_15 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_16 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_17 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_18 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_19 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_20 :  STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_21 :  STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_22 :  STD_LOGIC_VECTOR(5 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_23 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_24 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_25 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_26 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_27 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_28 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_29 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_30 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_31 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_32 :  STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_33 :  STD_LOGIC_VECTOR(4 DOWNTO 0);

SIGNAL	GDFX_TEMP_SIGNAL_0 :  STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL	GDFX_TEMP_SIGNAL_2 :  STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL	GDFX_TEMP_SIGNAL_3 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	GDFX_TEMP_SIGNAL_1 :  STD_LOGIC_VECTOR(4 DOWNTO 0);

BEGIN 
D_wrdata <= SYNTHESIZED_WIRE_27;

GDFX_TEMP_SIGNAL_0 <= (aw126 & aw125 & aw124 & aw123 & aw122);
GDFX_TEMP_SIGNAL_2 <= (aw4 & aw3 & aw2 & aw1 & aw0);
GDFX_TEMP_SIGNAL_3 <= (wrdata31 & wrdata30 & wrdata29 & wrdata28 & wrdata27 & wrdata26 & wrdata25 & wrdata24 & wrdata23 & wrdata22 & wrdata21 & wrdata20 & wrdata19 & wrdata18 & wrdata17 & wrdata16 & wrdata15 & wrdata14 & wrdata13 & wrdata12 & wrdata11 & wrdata10 & wrdata9 & wrdata8 & wrdata7 & wrdata6 & wrdata5 & wrdata4 & wrdata3 & wrdata2 & wrdata1 & wrdata0);
GDFX_TEMP_SIGNAL_1 <= (aw221 & aw220 & aw219 & aw218 & aw217);


b2v_alu_0 : alu
PORT MAP(a => SYNTHESIZED_WIRE_0,
		 b => SYNTHESIZED_WIRE_1,
		 op => SYNTHESIZED_WIRE_2,
		 s => alu_res);



b2v_inst1 : extend
PORT MAP(signed => SYNTHESIZED_WIRE_3,
		 imm16 => imm16,
		 imm32 => SYNTHESIZED_WIRE_19);


b2v_inst2 : pipeline_reg_mw
PORT MAP(clk => clk,
		 reset_n => reset_n,
		 rf_wren_in => SYNTHESIZED_WIRE_4,
		 mux_1_in => SYNTHESIZED_WIRE_5,
		 mux_2_in => SYNTHESIZED_WIRE_6,
		 rf_wren_out => wren);


b2v_inst3 : pipeline_reg_fd
PORT MAP(clk => clk,
		 reset_n => reset_n,
		 I_rddata_in => I_rddata,
		 next_addr_in => SYNTHESIZED_WIRE_7,
		 next_addr_out => SYNTHESIZED_WIRE_21);


b2v_inst4 : pipeline_reg_em
PORT MAP(clk => clk,
		 reset_n => reset_n,
		 sel_mem_in => SYNTHESIZED_WIRE_8,
		 rf_wren_in => SYNTHESIZED_WIRE_9,
		 mux_1_in => SYNTHESIZED_WIRE_10,
		 mux_2_in => SYNTHESIZED_WIRE_11,
		 sel_mem_out => SYNTHESIZED_WIRE_29,
		 rf_wren_out => SYNTHESIZED_WIRE_4,
		 mux_1_out => SYNTHESIZED_WIRE_30,
		 mux_2_out => SYNTHESIZED_WIRE_6);


b2v_inst5 : pipeline_reg_de
PORT MAP(clk => clk,
		 reset_n => reset_n,
		 sel_b_in => SYNTHESIZED_WIRE_12,
		 read_in => SYNTHESIZED_WIRE_13,
		 write_in => SYNTHESIZED_WIRE_14,
		 sel_pc_in => SYNTHESIZED_WIRE_15,
		 branch_op_in => SYNTHESIZED_WIRE_16,
		 sel_mem_in => SYNTHESIZED_WIRE_17,
		 rf_wren_in => SYNTHESIZED_WIRE_18,
		 a_in => a,
		 b_in => b,
		 d_imm_in => SYNTHESIZED_WIRE_19,
		 mux_in => SYNTHESIZED_WIRE_20,
		 next_addr_in => SYNTHESIZED_WIRE_21,
		 op_alu_in => SYNTHESIZED_WIRE_22,
		 sel_b_out => SYNTHESIZED_WIRE_25,
		 read_out => D_read,
		 write_out => D_write,
		 sel_pc_out => SYNTHESIZED_WIRE_28,
		 branch_op_out => SYNTHESIZED_WIRE_23,
		 sel_mem_out => SYNTHESIZED_WIRE_8,
		 rf_wren_out => SYNTHESIZED_WIRE_9,
		 a_out => SYNTHESIZED_WIRE_0,
		 b_out => SYNTHESIZED_WIRE_27,
		 d_imm_out => SYNTHESIZED_WIRE_26,
		 mux_out => SYNTHESIZED_WIRE_11,
		 next_addr_out => pc_addr(15 DOWNTO 0),
		 op_alu_out => SYNTHESIZED_WIRE_2);


b2v_inst6 : pc
PORT MAP(clk => clk,
		 reset_n => reset_n,
		 sel_a => sel_a,
		 sel_imm => sel_imm,
		 branch => sel_branch,
		 a => a(15 DOWNTO 0),
		 d_imm => d_imm,
		 e_imm => e_imm,
		 pc_addr => pc_addr(15 DOWNTO 0),
		 addr => I_addr,
		 next_addr => SYNTHESIZED_WIRE_7);


b2v_inst7 : controller
PORT MAP(op => op,
		 opx => opx,
		 imm_signed => SYNTHESIZED_WIRE_3,
		 sel_b => SYNTHESIZED_WIRE_12,
		 read => SYNTHESIZED_WIRE_13,
		 write => SYNTHESIZED_WIRE_14,
		 sel_pc => SYNTHESIZED_WIRE_15,
		 branch_op => SYNTHESIZED_WIRE_16,
		 sel_mem => SYNTHESIZED_WIRE_17,
		 rf_wren => SYNTHESIZED_WIRE_18,
		 pc_sel_imm => sel_imm,
		 pc_sel_a => sel_a,
		 sel_ra => SYNTHESIZED_WIRE_31,
		 sel_rC => SYNTHESIZED_WIRE_24,
		 op_alu => SYNTHESIZED_WIRE_22,
		 rf_retaddr => SYNTHESIZED_WIRE_33);


sel_branch <= alu_res(0) AND SYNTHESIZED_WIRE_23;




b2v_mux_aw : mux2x5
PORT MAP(sel => SYNTHESIZED_WIRE_24,
		 i0 => GDFX_TEMP_SIGNAL_0,
		 i1 => GDFX_TEMP_SIGNAL_1,
		 o => SYNTHESIZED_WIRE_32);


b2v_mux_b : mux2x32
PORT MAP(sel => SYNTHESIZED_WIRE_25,
		 i0 => SYNTHESIZED_WIRE_26,
		 i1 => SYNTHESIZED_WIRE_27,
		 o => SYNTHESIZED_WIRE_1);


b2v_mux_data : mux2x32
PORT MAP(sel => SYNTHESIZED_WIRE_28,
		 i0 => alu_res,
		 i1 => pc_addr,
		 o => SYNTHESIZED_WIRE_10);


b2v_mux_mem : mux2x32
PORT MAP(sel => SYNTHESIZED_WIRE_29,
		 i0 => SYNTHESIZED_WIRE_30,
		 i1 => D_rddata,
		 o => SYNTHESIZED_WIRE_5);


b2v_mux_ra : mux2x5
PORT MAP(sel => SYNTHESIZED_WIRE_31,
		 i0 => SYNTHESIZED_WIRE_32,
		 i1 => SYNTHESIZED_WIRE_33,
		 o => SYNTHESIZED_WIRE_20);


b2v_register_file_0 : register_file
PORT MAP(clk => clk,
		 wren => wren,
		 aa => aa,
		 ab => ab,
		 aw => GDFX_TEMP_SIGNAL_2,
		 wrdata => GDFX_TEMP_SIGNAL_3,
		 a => a,
		 b => b);

D_addr(15 DOWNTO 0) <= alu_res(15 DOWNTO 0);

END bdf_type;