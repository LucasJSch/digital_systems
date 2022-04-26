-- FFD with input of N bits, with synchronic reset
library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity seq_detector is
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
    end entity;
        
architecture seq_detector_arch of seq_detector is
            
    -- Buffer representing the input history.
    signal history : std_logic_vector(N-1 downto 0);

    function isSequenceMatched(target_sequence  : std_logic_vector(N-1 downto 0); 
                               current_sequence : std_logic_vector(N-1 downto 0)) 
                               return std_logic is
    begin
        if target_sequence = current_sequence then
            return'1';
        else
            return '0';
        end if;
    end function;

begin
    process (clk)
    begin
        if rising_edge(clk) then
            if rst_i = '1' then
                history <= (others => '0');
                q_o <= isSequenceMatched(seq_i, history); 
            else 
                history <= history(N-2 downto 0) & d_i;
                q_o <= isSequenceMatched(seq_i, history); 
            end if;
        end if;
    end process;
end architecture;