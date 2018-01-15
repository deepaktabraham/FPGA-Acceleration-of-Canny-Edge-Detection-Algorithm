library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package config_pkg is

    constant C_MMAP_ADDR_WIDTH : positive := 18;
    constant C_MMAP_DATA_WIDTH : positive := 32;

    subtype MMAP_ADDR_RANGE is natural range C_MMAP_ADDR_WIDTH-1 downto 0;
    subtype MMAP_DATA_RANGE is natural range C_MMAP_DATA_WIDTH-1 downto 0;
    
        constant C_MEM_ADDR_WIDTH : positive := 15;
        constant C_MEM_IN_WIDTH   : positive := 32;
        constant C_MEM_OUT_WIDTH  : positive := 32;
        constant C_ELEMENT_COUNT  : positive := 4;
        constant C_COLUMN_COUNT   : positive := 32; --7; --32;
        constant C_TOTAL_GROUPS   : positive := 4096; --896; --4096;
    
        constant C_MEM_START_ADDR : std_logic_vector(MMAP_ADDR_RANGE) := (others => '0');
        constant C_MEM_END_ADDR   : std_logic_vector(MMAP_ADDR_RANGE) := std_logic_vector(unsigned(C_MEM_START_ADDR)+(2**C_MEM_ADDR_WIDTH-1));
    
        constant C_GO_ADDR   : std_logic_vector(MMAP_ADDR_RANGE) := std_logic_vector(to_unsigned(2**C_MMAP_ADDR_WIDTH-3, C_MMAP_ADDR_WIDTH));
        constant C_SIZE_ADDR : std_logic_vector(MMAP_ADDR_RANGE) := std_logic_vector(to_unsigned(2**C_MMAP_ADDR_WIDTH-2, C_MMAP_ADDR_WIDTH));
        constant C_DONE_ADDR : std_logic_vector(MMAP_ADDR_RANGE) := std_logic_vector(to_unsigned(2**C_MMAP_ADDR_WIDTH-1, C_MMAP_ADDR_WIDTH));
    
        constant C_1 : std_logic := '1';
        constant C_0 : std_logic := '0';
    
end config_pkg;
