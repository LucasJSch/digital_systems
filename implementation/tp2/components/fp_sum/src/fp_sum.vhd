library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity fp_sum is
	port(
        clk           : in std_logic;
		a             : in std_logic_vector(31 downto 0);
		b             : in std_logic_vector(31 downto 0);
        -- TODO: Make this a type.
        rounding_mode : in std_logic_vector(1 downto 0);
		z             : out std_logic_vector(31 downto 0)
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

    component normalizer is
        generic(N: integer:= 4; M: integer := 4);
        port(
            X            : in std_logic_vector(N-1 downto 0);
            g_bit        : std_logic;
            shifted_bits : out unsigned(M-1 downto 0);
            Y            : out std_logic_vector(N-1 downto 0)
        );
    end component;

    component adder is
        generic(N: integer:= 4);
        port(
            X0        : in std_logic_vector(N-1 downto 0);
            X1        : in std_logic_vector(N-1 downto 0);
			substract : in std_logic;
			swap_ops  : in std_logic;
			Y         : out std_logic_vector(N-1 downto 0);
            carry_out : out std_logic);
    end component;

    -- Order of bits:
    -- | SIGN_BIT | EXPONENT_BITS | MANTISSA_BITS | --
	constant SIGN_BITS           : integer := 1;
    constant EXPONENT_BITS       : integer := 8;
    constant MANTISSA_BITS       : integer := 23;
	constant N_BITS              : integer := 32;
	constant MANTISSA_SHIFT_BITS : integer := 8;

    constant SIGN_BIT      : integer := N_BITS - SIGN_BITS;
    constant SIGN_END_BIT        : integer := SIGN_BIT - SIGN_BITS + 1;

    constant EXPONENT_START_BIT  : integer := SIGN_END_BIT - 1;
    constant EXPONENT_END_BIT    : integer := EXPONENT_START_BIT - EXPONENT_BITS + 1;

    constant MANTISSA_START_BIT  : integer := EXPONENT_END_BIT - 1;
    constant MANTISSA_END_BIT    : integer := 0;


    signal result_sign           : std_logic := '0';
	-- signal result_mantissa       : unsigned(MANTISSA_BITS-1 downto 0) := (others => '0');

    signal xor_sign              : std_logic := '0';
    -- Exponent registers need one more bit to be able to compute the unsigned operations.
    signal a_exp                 : signed(EXPONENT_BITS-1 downto 0) := (others => '0');
    signal b_exp                 : signed(EXPONENT_BITS-1 downto 0) := (others => '0');
    signal final_exp             : signed(EXPONENT_BITS-1 downto 0) := (others => '0');

    -- Significand registers need two more bit to be able to detect overflow and add the '1' bit on top.
    signal a_mantissa            : unsigned(MANTISSA_BITS downto 0) := (others => '0');
    signal b_mantissa            : unsigned(MANTISSA_BITS downto 0) := (others => '0');
    signal b_mantissa_pre_shift  : unsigned(MANTISSA_BITS+MANTISSA_SHIFT_BITS downto 0) := (others => '0');
    signal b_shifted_mantissa    : unsigned(MANTISSA_BITS+MANTISSA_SHIFT_BITS downto 0) := (others => '0');
    -- b_shifted_mantissa Without flag bits
    signal b_shifted_mantissa_2  : unsigned(MANTISSA_BITS downto 0) := (others => '0');
    signal aux_mantissa          : unsigned(MANTISSA_BITS*2+1 downto 0) := (others => '0');
    signal preliminary_mantissa  : unsigned(MANTISSA_BITS downto 0) := (others => '0');
    signal preliminary_mantissa_2: unsigned(MANTISSA_BITS downto 0) := (others => '0');
    signal normalized_mantissa   : unsigned(MANTISSA_BITS downto 0) := (others => '0');
    signal final_mantissa        : unsigned(MANTISSA_BITS-1 downto 0) := (others => '0');

    signal are_swapped           : std_logic := '0';
    signal exp_selection         : std_logic_vector(1 downto 0) := (others => '0');
    signal mantissa_selection    : std_logic_vector(1 downto 0) := (others => '0');
    signal carry_out             : std_logic := '0';
    signal substract_bit         : std_logic := '0';
    signal swap_ops_bit          : std_logic := '0';

    signal shift_exp_bits        : unsigned(EXPONENT_BITS-1 downto 0) := (others => '0');
    signal shifted_mantissa_bits : unsigned(EXPONENT_BITS-1 downto 0);
    signal flag_bits             : std_logic_vector(7 downto 0);
    signal g_bit                 : std_logic := '0';
    signal r_bit                 : std_logic := '0';
    signal r_bit_final           : std_logic := '0';
    signal s_bit                 : std_logic := '0';
    signal s_bit_final           : std_logic := '0';


    function A2_COMPLEMENT(X : std_logic_vector(b_mantissa'length-1 downto 0))
    return std_logic_vector is
    begin
        return std_logic_vector(resize(unsigned(not X) + to_unsigned(1, X'length), X'length));
    end A2_COMPLEMENT;

    function A2_COMPLEMENT2(X : std_logic_vector(preliminary_mantissa'length-1 downto 0))
    return std_logic_vector is
    begin
        return std_logic_vector(resize(unsigned(not X) + to_unsigned(1, X'length), X'length));
    end A2_COMPLEMENT2;

begin

    -- Step 1: Checking lowest exponent
    are_swapped <= '0' when 
                   (signed(a(EXPONENT_START_BIT downto EXPONENT_END_BIT)) >= signed(b(EXPONENT_START_BIT downto EXPONENT_END_BIT))) 
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
        signed(Y)	=> b_exp);

    exp_selection <= "00" when are_swapped = '0' else "11"; 
    shift_exp_bits <= unsigned(a_exp - b_exp);
    
    -- Step 2: Check different signs
    xor_sign <= a(SIGN_BIT) xor b(SIGN_BIT);

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
        X1  => "1" & b(MANTISSA_START_BIT downto MANTISSA_END_BIT),	
        X2  => "1" & a(MANTISSA_START_BIT downto MANTISSA_END_BIT),
        X3  => "1" & a(MANTISSA_START_BIT downto MANTISSA_END_BIT),
        sel => mantissa_selection,
        unsigned(Y)	=> b_mantissa);

    process(are_swapped, xor_sign)
    begin
        mantissa_selection <= "00" when (are_swapped = '0' and xor_sign = '0') else
                              "01" when (are_swapped = '0' and xor_sign = '1') else
                              "10" when (are_swapped = '1' and xor_sign = '0') else
                              "11" when (are_swapped = '1' and xor_sign = '1'); 
    end process;

    process(b_mantissa)
    begin
        b_mantissa_pre_shift <= (b_mantissa) & (b_mantissa_pre_shift'length-1-b_mantissa'length downto 0 => '0'); 
    end process;

    -- Step 3: Shifting the B register according to the exponent difference
    process(shift_exp_bits, b_mantissa_pre_shift)
    begin
        -- if xor_sign = '0' then
            b_shifted_mantissa <= shift_right(unsigned(b_mantissa_pre_shift), to_integer(shift_exp_bits));
        -- else
            -- b_shifted_mantissa <= unsigned(shift_right(signed(b_mantissa_pre_shift), to_integer(shift_exp_bits)));
        -- end if;
    end process;
    
    process(b_shifted_mantissa)
    begin
        flag_bits <= std_logic_vector(b_shifted_mantissa(7 downto 0));
        b_shifted_mantissa_2 <= b_shifted_mantissa(b_shifted_mantissa'length-1 downto MANTISSA_SHIFT_BITS);
    end process;

    process(flag_bits)
    begin
        g_bit <= flag_bits(7);
        r_bit <= flag_bits(6);
        s_bit <= '0' when flag_bits(5 downto 0) = "000000" else '1';
    end process;

    -- Step 4: Compute preliminary mantissa
    preliminary_mantissa_adder : adder
    generic map(a_mantissa'length)
    port map (
        X0          => std_logic_vector(a_mantissa),	
        X1          => std_logic_vector(b_shifted_mantissa_2),
        substract   => substract_bit,
        swap_ops    => swap_ops_bit,
        unsigned(Y) => preliminary_mantissa,
        carry_out   => carry_out);

    process(preliminary_mantissa, xor_sign)
    begin
        if (xor_sign = '0') then
            swap_ops_bit <= '0';
            substract_bit <= '0';
        elsif unsigned(a_mantissa) >= unsigned(b_shifted_mantissa_2) then
            swap_ops_bit <= '0';
            substract_bit <= '1';
        else
            swap_ops_bit <= '1';
            substract_bit <= '1';
        end if;
    end process;
    preliminary_mantissa_2 <= preliminary_mantissa;
    
    -- Step 5: Compute final mantissa
    mantissa_normalizer : normalizer
    generic map(preliminary_mantissa_2'length, EXPONENT_BITS)
    port map (
        X            => std_logic_vector(preliminary_mantissa_2),
        g_bit        => g_bit,	
        shifted_bits => shifted_mantissa_bits,
        unsigned(Y)  => normalized_mantissa);
    
    final_mantissa <= ('1' & preliminary_mantissa_2(MANTISSA_BITS downto 2)) when (carry_out = '1') else
                      normalized_mantissa(MANTISSA_BITS-1 downto 0);

    final_exp  <= a_exp+1 when (carry_out = '1') else (a_exp - signed(shifted_mantissa_bits));
    
    -- Step 6: Adjust 'r' and 's' bits
    -- TODO: Do this with muxes.
    r_bit_final <= preliminary_mantissa_2(preliminary_mantissa_2'right) when (xor_sign = '0' and carry_out = '1') else
                   g_bit when (shifted_mantissa_bits = to_unsigned(0, shifted_mantissa_bits'length)) else
                   r_bit when (shifted_mantissa_bits = to_unsigned(0, shifted_mantissa_bits'length)) else 
                   '0';
             
    s_bit_final <= (g_bit or s_bit or r_bit) when (xor_sign = '0' and carry_out = '1') else
                   (r_bit or s_bit) when (shifted_mantissa_bits = to_unsigned(0, shifted_mantissa_bits'length)) else
                   s_bit when (shifted_mantissa_bits = to_unsigned(0, shifted_mantissa_bits'length)) else 
                   '0';

    -- -- Step 7a: Rounding the mantissa
    -- result_mantissa <= final_mantissa + 1 when (rounding_mode = "00" and (r or s) = '1' and xor_sign = '0') else
    --                    final_mantissa + 1 when (rounding_mode = "01" and (r or s) = '1' and xor_sign = '1') else
    --                    (others => '0') when (rounding_mode = "10") else
    --                    final_mantissa + 1 when (rounding_mode = "11" and ((r and s) = '1' or (r and ) = '1')) else
    --                    final_mantissa;
    
    -- -- Step 7b: Checking for carry-out

    -- Step 8: Computing the result's sign
    -- TODO: This may not be correct in some cases.
    result_sign <= b(SIGN_BIT) when (are_swapped = '1') else
                   a(SIGN_BIT);

    z <= result_sign & std_logic_vector(final_exp) & std_logic_vector(final_mantissa);
end;
