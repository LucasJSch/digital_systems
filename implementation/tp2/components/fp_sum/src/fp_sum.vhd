library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;



entity fp_sum is
	port(
        clk : in  std_logic;
		a   : in  std_logic_vector(31 downto 0);
		b   : out std_logic_vector(31 downto 0);
		z   : out std_logic_vector(31 downto 0)
	);
end entity;

architecture fp_sum_arch of fp_sum is

    -- Order of bits:
    -- | SIGN_BIT | EXPONENT_BITS | MANTISSA_BITS | --
	constant SIGN_BITS           : integer := 1;
    constant EXPONENT_BITS       : integer := 8;
    constant MANTISSA_BITS       : integer := 23;
	constant N_BITS              : integer := 32;

    -- FP representation of zero
    constant ZERO_FP_REP         : std_logic_vector(N_BITS-1 downto 0) := (others => '0');
    -- Maximum representable FP number
    constant MAX_FP_REP          : std_logic_vector(N_BITS-1 downto 0) := "0" & "11111110" & "11111111111111111111111";

    constant EXPONENT_BIAS       : signed(EXPONENT_BITS downto 0) := to_signed(127, EXPONENT_BITS+1);
    constant MAX_BIASED_EXPONENT : unsigned(EXPONENT_BITS downto 0) := to_unsigned(254, EXPONENT_BITS+1);
    constant MIN_BIASED_EXPONENT : unsigned(EXPONENT_BITS downto 0) := to_unsigned(1, EXPONENT_BITS+1);

    constant SIGN_START_BIT      : integer := N_BITS - SIGN_BITS;
    constant SIGN_END_BIT        : integer := SIGN_START_BIT - SIGN_BITS + 1;

    constant EXPONENT_START_BIT  : integer := SIGN_END_BIT - 1;
    constant EXPONENT_END_BIT    : integer := EXPONENT_START_BIT - EXPONENT_BITS + 1;

    constant MANTISSA_START_BIT  : integer := EXPONENT_END_BIT - 1;
    constant MANTISSA_END_BIT    : integer := 0;


    signal result_sign           : std_logic := '0';
	signal result_exponent       : unsigned(EXPONENT_BITS+1 downto 0) := (others => '0');
	signal result_mantissa       : unsigned(MANTISSA_BITS-1 downto 0) := (others => '0');

    signal xor_sign              : std_logic;
    -- Exponent registers need one more bit to be able to compute the unsigned operations.
    signal a_exp                 : signed(EXPONENT_BITS-1 downto 0) := (others => '0');
    signal b_exp                 : signed(EXPONENT_BITS-1 downto 0) := (others => '0');
    signal aux_exp               : signed(EXPONENT_BITS-1 downto 0) := (others => '0');

    -- Significand registers need two more bit to be able to detect overflow and add the '1' bit on top.
    signal a_mantissa            : unsigned(MANTISSA_BITS downto 0);
    signal b_mantissa            : unsigned(MANTISSA_BITS downto 0);
    signal aux_mantissa          : unsigned(MANTISSA_BITS*2+1 downto 0);

    function A2_COMPLEMENT(X : std_logic_vector(b_mantissa'length-2 downto 0))
    return std_logic_vector is
    begin
        return std_logic_vector(resize(unsigned(not X) + to_unsigned(1, X'length), X'length));
    end A2_COMPLEMENT;

begin

    -- Step 1: Checking lowest exponent
    a_exp <= signed(a(EXPONENT_START_BIT downto EXPONENT_END_BIT)) when
            (a(EXPONENT_START_BIT downto EXPONENT_END_BIT) > b(EXPONENT_START_BIT downto EXPONENT_END_BIT)) else
            signed(b(EXPONENT_START_BIT downto EXPONENT_END_BIT));
    b_exp <= signed(b(EXPONENT_START_BIT downto EXPONENT_END_BIT)) when
            (a(EXPONENT_START_BIT downto EXPONENT_END_BIT) > b(EXPONENT_START_BIT downto EXPONENT_END_BIT)) else
            signed(a(EXPONENT_START_BIT downto EXPONENT_END_BIT));
    aux_exp <= a_exp;

    -- Step 2: Check different signs
    a_mantissa <= unsigned("1" & a(MANTISSA_START_BIT downto MANTISSA_END_BIT));
    xor_sign <= a(SIGN_START_BIT) xor b(SIGN_START_BIT);

    b_mantissa <= unsigned("1" & b(MANTISSA_START_BIT downto MANTISSA_END_BIT)) when
                  xor_sign = '0' else
                  unsigned("1" & (A2_COMPLEMENT(std_logic_vector(b(MANTISSA_START_BIT downto MANTISSA_END_BIT)))));

    -- Step 3: Shifting the B register according to the exponent difference

    -- Step 4: Compute preliminary mantissa
    -- Step 5: Compute final mantissa
    -- Step 6: Adjust 'r' and 's' bits
    -- Step 7: Approximating the mantissa
    -- Step 8: Computing the result's sign

end;
