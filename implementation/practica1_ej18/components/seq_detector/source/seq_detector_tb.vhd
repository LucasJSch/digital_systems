library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity seq_detector_tb is
end;

architecture seq_detector_tb_arq of seq_detector_tb is
	component seq_detector is
		generic(N : natural := 8);
		port(
			clk     : in std_logic;
			-- Sequence to detect.
			seq_i   : in std_logic_vector(N-1 downto 0);
			d_i     : in std_logic;
			rst_i   : in std_logic;
			-- Bit indicating if sequence has been found.
			q_o     : out std_logic
		);
	end component;

	signal N_tb       : integer := 6;
	signal seq_i_tb   : std_logic_vector(N_tb-1 downto 0) := "110010";
	signal clk_tb     : std_logic := '0';
	signal d_i_tb     : std_logic := '0';
	signal rst_i_tb   : std_logic := '0';
	signal q_o_tb     : std_logic;

begin
	clk_tb   <= not clk_tb after 15 ns;
	d_i_tb   <= '1' after 30 ns, '0' after 60 ns, '1' after 90 ns, '0' after 150 ns, '1' after 210 ns, '0' after 240 ns, '1' after 300 ns, '0' after 370 ns, '1' after 420 ns; 
	rst_i_tb <= '1' after 360 ns;
	seq_i_tb <= "000000" after 400 ns;

	DUT: seq_detector
		generic map(N => N_tb)
		port map(
			clk     => clk_tb,
			seq_i   => seq_i_tb,
			d_i     => d_i_tb,
			rst_i   => rst_i_tb,
			q_o     => q_o_tb
		);
end;
