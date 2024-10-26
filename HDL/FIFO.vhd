library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


-------------------------------------------------------------------
--                          Entity                               --
-------------------------------------------------------------------
entity FIFO is
    generic (
        DATA_WIDTH : integer := 8;  -- Largeur des données
        FIFO_DEPTH : integer := 16  -- Profondeur de la FIFO
    );
    port (
        clk        : in  std_logic;           -- Horloge
        rst        : in  std_logic;           -- Reset
        data_in    : in  std_logic_vector(DATA_WIDTH - 1 downto 0); -- Données entrantes
        push       : in  std_logic;           -- Signal pour ajouter des données
        pop        : in  std_logic;           -- Signal pour retirer des données
        data_out   : out std_logic_vector(DATA_WIDTH - 1 downto 0); -- Données sortantes
        full       : out std_logic;           -- Indicateur FIFO pleine
        empty      : out std_logic            -- Indicateur FIFO vide
    );
end FIFO;

-------------------------------------------------------------------
--                       Architecture                            --
-------------------------------------------------------------------
architecture Behavioral of FIFO is

    -- Fonction pour calculer le plafond du log2
    function log2ceil(val : integer) return integer is
        variable result : integer := 1;
    begin
        while (2**result < val) loop
            result := result + 1;
        end loop;
        return result;
    end log2ceil;

-------------------------------------------------------------------
--                        Signals                                --
-------------------------------------------------------------------
    type MemoryBlock is array (0 to FIFO_DEPTH - 1) of std_logic_vector(DATA_Width-1 downto 0);
    signal fifo_mem : MemoryBlock:= (others => (others => '0'));
    
    constant F_bit        : integer := log2ceil(FIFO_DEPTH);                -- Nb Bits pour FIFO Depth
    
    signal   read_ptr     : unsigned(F_bit  downto 0) := (others => '0');   -- Pointeur de lecture (LSB) -- MSB Pour le status FIFO
    signal   write_ptr    : unsigned(F_bit  downto 0) := (others => '0');   -- Pointeur d'ecriture (MSB) -- MSB Pour le status FIFO
   
    signal   full_s       : std_logic := '1';                               -- Indicateur FIFO pleine
    signal   empty_s      : std_logic := '0';                               -- Indicateur FIFO vide


begin
    -------------------------------------------------------------------
    --                       Out Connexion                          --
    -------------------------------------------------------------------
    full  <= full_s;
    empty <= empty_s;
    
    -------------------------------------------------------------------
    --                   Indicateurs de statut                       --
    -------------------------------------------------------------------
    full_s    <= '1' when write_ptr(F_bit) /= read_ptr(F_bit) and write_ptr(F_bit-1 downto 0) = read_ptr(F_bit-1 downto 0) else  '0';
    empty_s   <= '1' when write_ptr(F_bit)  = read_ptr(F_bit) and write_ptr(F_bit-1 downto 0) = read_ptr(F_bit-1 downto 0) else  '0';
    
    -------------------------------------------------------------------
    --                        Write Process                          --
    -------------------------------------------------------------------
    WritePorcess : process(clk, rst)
    begin
        if rst = '1' then 
            write_ptr <= (others => '0');
            
        elsif rising_edge(clk) then
            if push = '1' and full_s = '0' then
                fifo_mem(to_integer(write_ptr(F_bit-1 downto 0))) <= data_in;
                write_ptr <= write_ptr + 1;
            end if;
        end if;
    end process;

    -------------------------------------------------------------------
    --                         Read Process                          --
    -------------------------------------------------------------------
    process(clk, rst)
    begin
        if rst = '1' then
            read_ptr <= (others => '0');
        elsif rising_edge(clk) then
            if pop = '1' and empty_s = '0' then
                data_out <= fifo_mem(to_integer(read_ptr(F_bit-1 downto 0)));
                read_ptr <= read_ptr + 1;
            end if;
        end if;
    end process;
    
   

  
     
end Behavioral;