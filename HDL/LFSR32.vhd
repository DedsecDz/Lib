library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity LFSR32 is 
    Port ( 
        clk         : in std_logic;
        reset       : in std_logic;
        rand    : out std_logic_vector(31 downto 0)
    );
end LFSR32;

architecture behavioral of LFSR32 is
    signal REG32        : std_logic_vector(31 downto 0) ;
       
begin
    rand <= REG32;

    LFSR32 : Process(clk, reset)
    begin
        if reset = '1' then 
            REG32 <= (others => '1');  -- Reset the LFSR to the initial value
        elsif rising_edge(clk) then  
            REG32 <= REG32(30 downto 0) & (REG32(31) xor REG32(21) xor REG32(1) xor REG32(0));  -- Shift the new bit into the MSB position
        end if;
    end process;
end behavioral;
