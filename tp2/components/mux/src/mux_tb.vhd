library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity mux_tb is
end;

architecture mux_tb_arch of mux_tb is
    component mux is
        generic(N :integer:= 32);
        port (
            -- Input lines
            X0    : in std_logic_vector(N-1 downto 0);
            X1    : in std_logic_vector(N-1 downto 0);
            X2    : in std_logic_vector(N-1 downto 0);
            X3    : in std_logic_vector(N-1 downto 0);
            -- Selection line
            sel   : in std_logic_vector(1 downto 0);
            -- Output line
            Y     : out std_logic_vector(N-1 downto 0));
    end component;

	signal X0_tb  : std_logic_vector(3 downto 0) := "0001";
	signal X1_tb  : std_logic_vector(3 downto 0) := "0010";
	signal X2_tb  : std_logic_vector(3 downto 0) := "0100";
	signal X3_tb  : std_logic_vector(3 downto 0) := "1000";
	signal sel_tb : std_logic_vector(1 downto 0) := "00";
	signal Y_tb   : std_logic_vector(3 downto 0);

begin

	sel_tb <= "01" after 50 fs, "10" after 100 fs, "11" after 150 fs, "00" after 200 fs;

	DUT: mux
        generic map(4)
		port map(
			X0  => X0_tb,	
			X1  => X1_tb,	
			X2  => X2_tb,	
			X3  => X3_tb,	
            sel => sel_tb,
			Y   => Y_tb);
end;
