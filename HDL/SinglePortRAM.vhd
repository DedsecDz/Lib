library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;


entity SinglePortRAM is 
    generic (
        DATA_Width          : integer := 32;      
        ADDR_Width          : integer := 9;

        READING_CONFIG_SYNC : boolean := true -- flase ==> Asynchrone
        
        );
    Port ( 
        -- In
        clk         : in std_logic;

        Addr        : in std_logic_vector(ADDR_Width-1 downto 0);       -- Bus Address 
        W_DATA      : in std_logic_vector(DATA_Width-1 downto 0);       -- Write Data 
        nW_Enb      : in std_logic;                                     -- Write Enable 
        nCS         : in std_logic;                                     -- Chip Select 
        mask        : in std_logic_vector(DATA_Width-1 downto 0);

        -- Out
        R_DATA      : out std_logic_vector(DATA_Width-1 downto 0)       -- Read DATA 
    );
end SinglePortRAM;

architecture TOP of SinglePortRAM is
    type MemoryBlock is array (0 to 2**ADDR_Width-1) of std_logic_vector(DATA_Width-1 downto 0);
    signal ram          : MemoryBlock := (others => (others => '0'));
    signal Data_d1      : std_logic_vector(DATA_Width-1 downto 0);
    signal Data_d2      : std_logic_vector(DATA_Width-1 downto 0);

begin

    -- Writing 
    WriteProcess : process(clk)
    begin 
        if rising_edge(clk) then
            if nCS = '0' and nW_Enb = '0' then
                for i in 1 to DATA_Width/8 loop
                    if  Mask(8*i-1 downto 8*(i-1)) = "11111111" then
                        ram(to_integer(unsigned(Addr)))(8*i-1 downto 8*(i-1)) <= W_DATA(8*i-1 downto 8*(i-1));
                    end if;
                end loop;
            end if;
        end if;
    end process;

    -- Reading
    SyncRead : if READING_CONFIG_SYNC = true generate
    begin 
        ReadProcess : process(clk) 
        begin
            if rising_edge(clk) then 
                if nCS = '0' and nW_Enb = '1' then
                    Data_d1 <= ram(to_integer(unsigned(Addr)));
                end if;
            end if;
        end process;
    end generate;

    ASyncRead : if READING_CONFIG_SYNC = false generate
    begin 
       Data_d1 <= ram(to_integer(unsigned(Addr))) when nCS = '0' and nW_Enb = '1' else (others => '0');
    end generate;
    
    Data_d2 <= Data_d1;
    R_DATA  <= Data_d2;

end TOP;

