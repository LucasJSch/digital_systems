library IEEE;
use IEEE.std_logic_1164.all;

entity fsm_tb is
end;

architecture fsm_tb_arq of fsm_tb is
	component fsm is
		port(
			clk        : in std_logic;
			rst_i      : in std_logic;
			red_1_o    : out std_logic;
			yellow_1_o : out std_logic;
			green_1_o  : out std_logic;
			red_2_o    : out std_logic;
			yellow_2_o : out std_logic;
			green_2_o  : out std_logic
		);
	end component;

	signal clk_tb        : std_logic := '0';
	signal red_1_o_tb    : std_logic;
	signal yellow_1_o_tb : std_logic;
	signal green_1_o_tb  : std_logic;
	signal red_2_o_tb    : std_logic;
	signal yellow_2_o_tb : std_logic;
	signal green_2_o_tb  : std_logic;

begin

	clk_tb <= not clk_tb after 15 ps;

	DUT: fsm
		port map(
			clk => clk_tb,	
			rst_i => '0',
			red_1_o => red_1_o_tb,
			yellow_1_o => yellow_1_o_tb,
			green_1_o => green_1_o_tb,
			red_2_o => red_2_o_tb,
			yellow_2_o => yellow_2_o_tb,
			green_2_o => green_2_o_tb
		);
end;
