library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- TODO: Implement a mux with two channels


entity fp_sum is
	port(
        clk : in  std_logic;
		a   : in  std_logic_vector(31 downto 0);
		b   : out std_logic_vector(31 downto 0);
		z   : out std_logic_vector(31 downto 0)
	);
end entity;

architecture fp_sum_arch of fp_sum is

    component mux is
        generic(N : integer:= 32);
        port (
            X0  : in std_logic_vector(N-1 downto 0);
            X1  : in std_logic_vector(N-1 downto 0);
            X2  : in std_logic_vector(N-1 downto 0);
            X3  : in std_logic_vector(N-1 downto 0);
            sel : in std_logic_vector(1 downto 0);
            Y   : out std_logic_vector(N-1 downto 0) 
        );
    end component;

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
    signal b_shifted_mantissa    : unsigned(MANTISSA_BITS downto 0);
    signal aux_mantissa          : unsigned(MANTISSA_BITS*2+1 downto 0);
    signal preliminary_mantissa  : unsigned(MANTISSA_BITS downto 0);

    signal are_swapped           : std_logic := '0';
    signal exp_selection         : std_logic_vector(1 downto 0);
    signal mantissa_selection    : std_logic_vector(1 downto 0);


    function A2_COMPLEMENT(X : std_logic_vector(b_mantissa'length-2 downto 0))
    return std_logic_vector is
    begin
        return std_logic_vector(resize(unsigned(not X) + to_unsigned(1, X'length), X'length));
    end A2_COMPLEMENT;

begin

    -- Step 1: Checking lowest exponent
    are_swapped <= '0' when 
                   (a(EXPONENT_START_BIT downto EXPONENT_END_BIT) > b(EXPONENT_START_BIT downto EXPONENT_END_BIT)) 
                   else '1';
    
    a_exp_mux : mux
    generic map(EXPONENT_BITS)
    port map (
        X0  => a(EXPONENT_START_BIT downto EXPONENT_END_BIT),
        X1  => a(EXPONENT_START_BIT downto EXPONENT_END_BIT),
        X2  => b(EXPONENT_START_BIT downto EXPONENT_END_BIT),
        X3  => b(EXPONENT_START_BIT downto EXPONENT_END_BIT),	
        sel => exp_selection,
        signed(Y)	=> a_exp);

    b_exp_mux : mux
    generic map(EXPONENT_BITS)
    port map (
        X0  => b(EXPONENT_START_BIT downto EXPONENT_END_BIT),
        X1  => b(EXPONENT_START_BIT downto EXPONENT_END_BIT),	
        X2  => a(EXPONENT_START_BIT downto EXPONENT_END_BIT),
        X3  => a(EXPONENT_START_BIT downto EXPONENT_END_BIT),
        sel => exp_selection,
        signed(Y)	=> a_exp);

    process(clk)
    begin
        if rising_edge(clk) then
            exp_selection <= "00" when are_swapped = '1' else "11"; 
        end if;
    end process;
    
    -- Step 2: Check different signs
    xor_sign <= a(SIGN_START_BIT) xor b(SIGN_START_BIT);

    a_mantissa_mux : mux
    generic map(MANTISSA_BITS+1)
    port map (
        X0  => "1" & a(MANTISSA_START_BIT downto MANTISSA_END_BIT),
        X1  => "1" & a(MANTISSA_START_BIT downto MANTISSA_END_BIT),	
        X2  => "1" & b(MANTISSA_START_BIT downto MANTISSA_END_BIT),
        X3  => "1" & b(MANTISSA_START_BIT downto MANTISSA_END_BIT),
        sel => mantissa_selection,
        unsigned(Y)	=> a_mantissa);

    b_mantissa_mux : mux
    generic map(MANTISSA_BITS+1)
    port map (
        X0  => "1" & b(MANTISSA_START_BIT downto MANTISSA_END_BIT),
        X1  => "1" & (A2_COMPLEMENT(std_logic_vector(b(MANTISSA_START_BIT downto MANTISSA_END_BIT)))),	
        X2  => "1" & a(MANTISSA_START_BIT downto MANTISSA_END_BIT),
        X3  => "1" & (A2_COMPLEMENT(std_logic_vector(a(MANTISSA_START_BIT downto MANTISSA_END_BIT)))),
        sel => mantissa_selection,
        unsigned(Y)	=> b_mantissa);

    process(clk)
    begin
        if rising_edge(clk) then
            mantissa_selection <= "00" when (are_swapped = '0' and xor_sign = '0') else
                                  "01" when (are_swapped = '0' and xor_sign = '1') else
                                  "10" when (are_swapped = '1' and xor_sign = '0') else
                                  "11" when (are_swapped = '1' and xor_sign = '1'); 
        end if;
    end process;

    -- Step 3: Shifting the B register according to the exponent difference
    b_shifted_mantissa <= shift_right(b_mantissa, to_integer(a_exp - b_exp)) when xor_sign = '0' else
                          unsigned(shift_right(signed(b_mantissa), to_integer(a_exp - b_exp)));

    -- Step 4: Compute preliminary mantissa
    preliminary_mantissa <= b_shifted_mantissa + a_mantissa;

    -- Step 5: Compute final mantissa
    

    -- Step 6: Adjust 'r' and 's' bits
    -- Step 7: Approximating the mantissa
    -- Step 8: Computing the result's sign

end;
