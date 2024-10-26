library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity DualPortRAM is 
    generic (
        DATA_Width          : integer := 8;      
        ADDR_Width          : integer := 8;
        
        READING_CONFIG_SYNC : boolean := true -- flase ==> Asynchrone
        );
    Port ( 
        -- In
        clk_A      : in std_logic;
        clk_B      : in std_logic;

        Addr_PA    : in std_logic_vector(ADDR_Width-1 downto 0);       -- Bus Address A
        W_DATA_PA  : in std_logic_vector(DATA_Width-1 downto 0);       -- Write Data A
        W_Enb_PA   : in std_logic;                                     -- Write Enable A
        CSA        : in std_logic;                                     -- Chip Select A

        

        Addr_PB    : in std_logic_vector(ADDR_Width-1 downto 0);       -- Bus Address B
        W_DATA_PB  : in std_logic_vector(DATA_Width-1 downto 0);       -- Write Data B
        W_Enb_PB   : in std_logic;                                     -- Write Enable B
        CSB        : in std_logic;                                     -- Chip Select B

        -- Out
        R_DATA_PA  : out std_logic_vector(DATA_Width-1 downto 0);       -- Read DATA A
        R_DATA_PB  : out std_logic_vector(DATA_Width-1 downto 0)        -- Read DATA B
    );
end DualPortRAM;


architecture TOP of DualPortRAM is
    type MemoryBlock is array (0 to 2**ADDR_Width-1) of std_logic_vector(DATA_Width-1 downto 0);
    signal ram          : MemoryBlock := (others => (others => '0'));
    signal rdata_PA     : std_logic_vector(DATA_Width-1 downto 0);  
    signal rdata_PB     : std_logic_vector(DATA_Width-1 downto 0);


begin

    R_DATA_PA <= rdata_PA;
    R_DATA_PB <= rdata_PB;

    -- Writing 
    PAWriteProcess : process(clk_B)
    begin 
        if rising_edge(clk_A) then
            if CSA = '1' and W_Enb_PA = '1' then
                ram(to_integer(unsigned(Addr_PA))) <= W_DATA_PA;
            end if;
        end if;
    end process;

    PBWriteProcess : process(clk_B)
    begin
        if rising_edge(clk_B) then
            if CSB = '1' and W_Enb_PB = '1' then
                ram(to_integer(unsigned(Addr_PB))) <= W_DATA_PB;
            end if;
        end if;
    end process;

    -- Reading 
    SyncRead : if READING_CONFIG_SYNC = true generate
    begin
        PA_ReadProcess : process(clk_A) -- Synchrone
        begin
            if rising_edge(clk_A) then 
                if CSA = '1' and W_Enb_PA = '1' then
                    rdata_PA <= ram(to_integer(unsigned(Addr_PA)));
                end if;
            end if;
        end process;

        PB_ReadProcess : process(clk_B) -- Synchrone
        begin
            if rising_edge(clk_B) then 
                if CSB = '1' and W_Enb_PB = '1' then
                    rdata_PB <= ram(to_integer(unsigned(Addr_PB)));
                end if;
            end if;
        end process;

    end generate;
    
    ASyncRead : if READING_CONFIG_SYNC = false generate
    begin
        PA_ReadProcess : process( CSA, W_Enb_PA)  -- Asynchrone
        begin
            if CSA = '1' and W_Enb_PA = '1' then
                rdata_PA <= ram(to_integer(unsigned(Addr_PA)));
            end if;
        end process;
        
        PB_ReadProcess : process(CSB, W_Enb_PB)  -- Asynchrone
        begin
            if CSB = '1' and W_Enb_PB = '1' then
                rdata_PB <= ram(to_integer(unsigned(Addr_PB)));
            end if;
        end process;

    end generate;
 

end TOP;


