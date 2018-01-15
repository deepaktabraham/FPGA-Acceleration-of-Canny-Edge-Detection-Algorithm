library ieee;
use ieee.std_logic_1164.all;

entity regbit is
  port (
    clk     : in  std_logic;
    rst     : in  std_logic;
    vld_in  : in  std_logic;
    input   : in  std_logic;
    output  : out std_logic);
end regbit;

architecture BHV of regbit is
begin
  process(clk, rst)
  begin
    if (rst = '1') then
      output <= '0';
    elsif (clk'event and clk = '1') then
      if (vld_in = '1') then
        output <= input;
      end if;        
    end if;
  end process;
end BHV;
