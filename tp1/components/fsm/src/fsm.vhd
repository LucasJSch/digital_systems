library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity fsm is
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
end entity;

architecture fsm_arq of fsm is

	-- TODO: Verificar que integer no me lo sintetize como 32 bits.
	-- TODO: Simular los cambios nuevos.
	constant CLK_FREQ          : integer := 1*(10**0);  -- 50 MHz
	constant SECONDS_IN_RED    : integer := 30;          -- 30 seconds
	constant SECONDS_IN_YELLOW : integer := 3;           -- 3  seconds
	constant SECONDS_IN_GREEN  : integer := 30;          -- 30 seconds
	constant CYCLES_IN_RED     : integer := SECONDS_IN_RED * CLK_FREQ;
	constant CYCLES_IN_YELLOW  : integer := SECONDS_IN_YELLOW * CLK_FREQ;
	constant CYCLES_IN_GREEN   : integer := SECONDS_IN_GREEN * CLK_FREQ;

	-- R = Rojo
	-- A = Amarillo
	-- V = Verde
	-- RA = Rojo y amarillo (cuando se va de Rojo a Amarillo, aparecen juntos. De Verde a Rojo no.)
	type state_t is (R1_V2, R1_A2, RA1_R2, V1_R2, A1_R2, R1_RA2);
	signal current_state : state_t;
	signal clk_cycles_passed : std_logic_vector(27 downto 0) := (others => '0');

begin
	process(clk, rst_i)
	begin
		if rst_i='1' then
			clk_cycles_passed <= (others => '0');
			current_state <= R1_V2;
			red_1_o    <= '1';
			yellow_1_o <= '0';
			green_1_o  <= '0';
			red_2_o    <= '0';
			yellow_2_o <= '0';
			green_2_o  <= '1';
        elsif rising_edge(clk) then
			clk_cycles_passed <= std_logic_vector(unsigned(clk_cycles_passed) + 1);
			case current_state is
				when R1_V2  =>
					red_1_o    <= '1';
					yellow_1_o <= '0';
					green_1_o  <= '0';
					red_2_o    <= '0';
					yellow_2_o <= '0';
					green_2_o  <= '1';
					if unsigned(clk_cycles_passed) >= to_unsigned(CYCLES_IN_GREEN, 28) then
						clk_cycles_passed <= (others => '0');
						current_state <= R1_A2;
					end if;
				when R1_A2  =>
					red_1_o    <= '1';
					yellow_1_o <= '0';
					green_1_o  <= '0';
					red_2_o    <= '0';
					yellow_2_o <= '1';
					green_2_o  <= '0';
					if unsigned(clk_cycles_passed) >= to_unsigned(CYCLES_IN_YELLOW, 28) then
						clk_cycles_passed <= (others => '0');
						current_state <= RA1_R2;
					end if;
				when RA1_R2 =>
					red_1_o    <= '1';
					yellow_1_o <= '1';
					green_1_o  <= '0';
					red_2_o    <= '1';
					yellow_2_o <= '0';
					green_2_o  <= '0';
					if unsigned(clk_cycles_passed) >= to_unsigned(CYCLES_IN_YELLOW, 28) then
						clk_cycles_passed <= (others => '0');
						current_state <= V1_R2;
					end if;
				when V1_R2  =>
					red_1_o    <= '0';
					yellow_1_o <= '0';
					green_1_o  <= '1';
					red_2_o    <= '1';
					yellow_2_o <= '0';
					green_2_o  <= '0';
					if unsigned(clk_cycles_passed) >= to_unsigned(CYCLES_IN_GREEN, 28) then
						clk_cycles_passed <= (others => '0');
						current_state <= A1_R2;
					end if;
				when A1_R2  =>
					red_1_o    <= '0';
					yellow_1_o <= '1';
					green_1_o  <= '0';
					red_2_o    <= '1';
					yellow_2_o <= '0';
					green_2_o  <= '0';
					if unsigned(clk_cycles_passed) >= to_unsigned(CYCLES_IN_YELLOW, 28) then
						clk_cycles_passed <= (others => '0');
						current_state <= R1_RA2;
					end if;
				when R1_RA2 =>
					red_1_o    <= '1';
					yellow_1_o <= '0';
					green_1_o  <= '0';
					red_2_o    <= '1';
					yellow_2_o <= '1';
					green_2_o  <= '0';
					if unsigned(clk_cycles_passed) >= to_unsigned(CYCLES_IN_YELLOW, 28) then
						clk_cycles_passed <= (others => '0');
						current_state <= R1_V2;
					end if;
			end case;
		end if;
	end process;
end;
