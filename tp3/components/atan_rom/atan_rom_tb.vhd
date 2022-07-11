library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity atan_rom_tb is
end;

architecture atan_rom_arch of atan_rom_tb is
    component atan_rom is
    generic(
        ADDR_W  : natural:= 4;
        DATA_W : natural:= 9
    );
    port(
        addr_i : in std_logic_vector(ADDR_W-1 downto 0);
        data_o : out std_logic_vector(DATA_W-1 downto 0)
    );
    end component;

	constant ADDR_W : integer := 4;
	constant DATA_W  : integer := 17;

    signal clk_tb : std_logic := '0';
    signal addr_i_tb : std_logic_vector(ADDR_W-1 downto 0) := "0000";
    signal data_o_tb : std_logic_vector(DATA_W-1 downto 0);

begin

    clk_tb <= not clk_tb after 10 ns;
    addr_i_tb <= "0001" after 20 ns,
                 "0010" after 30 ns,
                 "0011" after 40 ns,
                 "0100" after 50 ns,
                 "0101" after 60 ns,
                 "0110" after 70 ns,
                 "0111" after 80 ns,
                 "1000" after 90 ns,
                 "1001" after 100 ns,
                 "1010" after 110 ns,
                 "1011" after 120 ns,
                 "1100" after 130 ns,
                 "1101" after 140 ns,
                 "1110" after 150 ns;

	DUT: atan_rom
		generic map(ADDR_W, DATA_W)
		port map(
            addr_i    => addr_i_tb,
            data_o    => data_o_tb);
end;