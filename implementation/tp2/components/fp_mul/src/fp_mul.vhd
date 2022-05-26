library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity fp_mul is
	port(
        clk : in  std_logic;
		a   : in  std_logic_vector(31 downto 0);
		b   : out std_logic_vector(31 downto 0);
		z   : out std_logic_vector(31 downto 0)
	);
end entity;

architecture fp_mul_arch of fp_mul is

	constant N_BITS                : integer := 32;
    constant EXPONENT_BIAS         : integer := -127;
    constant MAX_EXPONENT          : integer := 127;
    constant MIN_EXPONENT          : integer := -126;

    -- Order of bits:
    -- | SIGN_BIT | EXPONENT_BITS | SIGNIFICAND_BITS | --
	constant SIGN_BITS             : integer := 1;
    constant EXPONENT_BITS         : integer := 8;
    constant SIGNIFICAND_BITS      : integer := 23;

    constant SIGN_START_BIT        : integer := N_BITS - SIGN_BITS;
    constant SIGN_END_BIT          : integer := SIGN_START_BIT - SIGN_BITS + 1;

    constant EXPONENT_START_BIT    : integer := SIGN_END_BIT - 1;
    constant EXPONENT_END_BIT      : integer := EXPONENT_START_BIT - EXPONENT_BITS + 1;

    constant SIGNIFICAND_START_BIT : integer := EXPONENT_END_BIT - 1;
    constant SIGNIFICAND_END_BIT   : integer := 0;



	signal result_sign             : std_logic := '0';
	signal result_exponent         : std_logic_vector(EXPONENT_BITS downto 0) := (others => '0');
	signal result_significand      : std_logic_vector(SIGNIFICAND_BITS - 1 downto 0) := (others => '0');
    signal bits_shift              : integer := 0;
    signal result_ready            : std_logic := '0';

    signal debug_a_exp : std_logic_vector(EXPONENT_BITS-1 downto 0);
    signal debug_b_exp : std_logic_vector(EXPONENT_BITS-1 downto 0);
    signal debug_bias : std_logic_vector(EXPONENT_BITS downto 0);
    signal debug_max_exp : std_logic_vector(EXPONENT_BITS downto 0);

begin
	process(clk)
    begin
        if rising_edge(clk) then

            -------------- debugging --------------
            debug_a_exp <=  a(EXPONENT_START_BIT downto EXPONENT_END_BIT);
            debug_b_exp <=  b(EXPONENT_START_BIT downto EXPONENT_END_BIT);
            debug_bias <=  std_logic_vector(to_signed(EXPONENT_BIAS, result_exponent'length));
            debug_bias <=  std_logic_vector(to_signed(MAX_EXPONENT, result_exponent'length));
            ---------------------------------------

            -- Compute sign
            result_sign <= a(SIGN_START_BIT) xor b(SIGN_START_BIT);
            
            -- Compute exponent
            result_exponent <= std_logic_vector(
                signed(a(EXPONENT_START_BIT downto EXPONENT_END_BIT)) + signed(b(EXPONENT_START_BIT downto EXPONENT_END_BIT)) + to_signed(EXPONENT_BIAS, result_exponent'length) + to_signed(EXPONENT_BIAS, result_exponent'length)
                );

            if (signed(result_exponent) > to_signed(MAX_EXPONENT, result_exponent'length)) then
                result_exponent <= std_logic_vector(to_signed(MAX_EXPONENT, result_exponent'length));
                result_significand <= (others => '1');
                result_ready <= '1';
            end if;

            if (signed(result_exponent) < to_signed(MIN_EXPONENT, result_exponent'length)) then
                result_exponent <= std_logic_vector(to_signed(MIN_EXPONENT, result_exponent'length));
                result_significand <= (others => '0');
                result_ready <= '1';
            end if;

            if (result_ready = '0') then
                -- -- Compute base
                -- result_significand <= std_logic_vector(
                --     signed(a(SIGNIFICAND_START_BIT downto SIGNIFICAND_END_BIT)) * signed(b(SIGNIFICAND_START_BIT downto SIGNIFICAND_END_BIT))
                --     )(result_significand'length downto 0);
                    
                -- while (result_exponent & 0x) == 0) loop 
                --     bits_shift <<= 1
                -- end loop;
            end if;

            z <= result_sign & result_exponent(EXPONENT_BITS-1 downto 0) & result_significand;
        end if;
	end process;
end;
