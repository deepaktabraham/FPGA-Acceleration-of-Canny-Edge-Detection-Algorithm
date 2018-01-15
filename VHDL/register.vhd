library ieee;
use ieee.std_logic_1164.all;

entity reg is
  generic (
  width  :  positive := 16);
  port (
    clk     : in  std_logic;
    rst     : in  std_logic;
    vld_in  : in  std_logic;
    input   : in  std_logic_vector(width-1 downto 0);
    output  : out std_logic_vector(width-1 downto 0));
end reg;

architecture BHV of reg is
begin
  process(clk, rst)
  begin
    if (rst = '1') then
      output <= (others => '0');
    elsif (clk'event and clk = '1') then
      if (vld_in = '1') then
        output <= input;
      end if;        
    end if;
  end process;
end BHV;
