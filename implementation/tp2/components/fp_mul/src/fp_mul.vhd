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

    -- Order of bits:
    -- | SIGN_BIT | EXPONENT_BITS | MANTISSA_BITS | --
	constant SIGN_BITS             : integer := 1;
    constant EXPONENT_BITS         : integer := 8;
    constant MANTISSA_BITS         : integer := 23;
	constant N_BITS                : integer := 32;

    constant EXPONENT_BIAS         : signed(EXPONENT_BITS downto 0) := to_signed(127, EXPONENT_BITS+1);
    constant MAX_EXPONENT          : signed(EXPONENT_BITS downto 0) := to_signed(127, EXPONENT_BITS+1);
    constant MIN_EXPONENT          : signed(EXPONENT_BITS downto 0) := to_signed(-126, EXPONENT_BITS+1);

    constant SIGN_START_BIT        : integer := N_BITS - SIGN_BITS;
    constant SIGN_END_BIT          : integer := SIGN_START_BIT - SIGN_BITS + 1;

    constant EXPONENT_START_BIT    : integer := SIGN_END_BIT - 1;
    constant EXPONENT_END_BIT      : integer := EXPONENT_START_BIT - EXPONENT_BITS + 1;

    constant MANTISSA_START_BIT    : integer := EXPONENT_END_BIT - 1;
    constant MANTISSA_END_BIT      : integer := 0;


	signal result_sign             : std_logic := '0';
	signal result_exponent         : unsigned(EXPONENT_BITS+1 downto 0) := (others => '0');
	signal result_mantissa         : unsigned(MANTISSA_BITS - 1 downto 0) := (others => '0');

    -- Exponent registers need one more bit to be able to compute the unsigned operations.
    signal a_exp                   : signed(EXPONENT_BITS downto 0) := (others => '0');
    signal b_exp                   : signed(EXPONENT_BITS downto 0) := (others => '0');
    signal aux_exp                 : signed(EXPONENT_BITS downto 0) := (others => '0');

    -- Significand registers need two more bit to be able to detect overflow and add the '1' bit on top.
    signal a_mantissa           : unsigned(MANTISSA_BITS downto 0);
    signal b_mantissa           : unsigned(MANTISSA_BITS downto 0);
    signal aux_mantissa         : unsigned(MANTISSA_BITS*2+1 downto 0);

    signal debug : std_logic := 'U';
begin
    
    -- Compute sign
    result_sign <= a(SIGN_START_BIT) xor b(SIGN_START_BIT);
    
    -- Compute exponent
    a_exp <= signed("0" & a(EXPONENT_START_BIT downto EXPONENT_END_BIT)) - EXPONENT_BIAS;
    b_exp <= signed("0" & b(EXPONENT_START_BIT downto EXPONENT_END_BIT)) - EXPONENT_BIAS;
    aux_exp <= a_exp + b_exp;

    -- Compute mantissa
    a_mantissa <= unsigned("1" & a(MANTISSA_START_BIT downto MANTISSA_END_BIT));
    b_mantissa <= unsigned("1" & a(MANTISSA_START_BIT downto MANTISSA_END_BIT));
    aux_mantissa <= a_mantissa * b_mantissa;

    -- Shifting mantissa if necessary
    mantissa_shift: process(aux_mantissa, aux_exp)
	begin
		if aux_mantissa(MANTISSA_BITS*2+1) = '1' then
            debug <= '1';
			result_mantissa <= aux_mantissa(MANTISSA_BITS*2 downto MANTISSA_BITS+1);
			result_exponent <= unsigned(aux_exp + to_signed(1, result_exponent'length) + EXPONENT_BIAS);
		else
            debug <= '0';
            result_mantissa <= unsigned(signed(aux_mantissa(2*MANTISSA_BITS-1 downto MANTISSA_BITS)));
			result_exponent <= unsigned(signed("0" & aux_exp)  + EXPONENT_BIAS);
		end if;		
	end process;

    process(clk)
    begin
        if rising_edge(clk) then
            z <= result_sign & std_logic_vector(result_exponent(EXPONENT_BITS-1 downto 0)) & std_logic_vector(result_mantissa);
        end if;
    end process;
end;
