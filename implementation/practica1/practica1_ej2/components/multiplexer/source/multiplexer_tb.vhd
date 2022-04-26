library IEEE;
use IEEE.std_logic_1164.all;

entity multiplexer_tb is
end;

architecture multiplexer_tb_arq of multiplexer_tb is

    component multiplexer is
        port (
                -- Clock line
                clk: in std_logic;
                -- Input lines
                x1_i: in std_logic;
                x2_i: in std_logic;
                x3_i: in std_logic;
                x4_i: in std_logic;
                -- Selection lines
                s1_i: in std_logic;
                s2_i: in std_logic;
                -- Output
                y_o: out std_logic
            );
    end component;
    
	signal clk_tb: std_logic  := '0';
	signal x1_i_tb: std_logic := '0';
	signal x2_i_tb: std_logic := '1';
	signal x3_i_tb: std_logic := '0';
	signal x4_i_tb: std_logic := '1';
	signal s1_i_tb: std_logic := '0';
	signal s2_i_tb: std_logic := '0';
	signal y_o_tb: std_logic;
begin

    clk_tb <= not clk_tb after 50 ns;
	s1_i_tb <= not s1_i_tb after 100 ns;
	s2_i_tb <= not s2_i_tb after 200 ns;

	x1_i_tb <= not x1_i_tb after 400 ns;
	x2_i_tb <= not x2_i_tb after 400 ns;
	x3_i_tb <= not x3_i_tb after 400 ns;
	x4_i_tb <= not x4_i_tb after 400 ns;

	DUT: multiplexer
		port map(
			clk => clk_tb,
			x1_i => x1_i_tb,
			x2_i => x2_i_tb,
			x3_i => x3_i_tb,
			x4_i => x4_i_tb,
			s1_i => s1_i_tb,
			s2_i => s2_i_tb,
			y_o => y_o_tb
		);

end;
