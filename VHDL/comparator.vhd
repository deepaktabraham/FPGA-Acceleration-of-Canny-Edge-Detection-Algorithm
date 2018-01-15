library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity comparator is
  generic (
    width  :     positive := 8);
  port (
    clk    : in  std_logic;
    rst    : in  std_logic;
    en     : in  std_logic;
    in1 : in  std_logic_vector(width-1 downto 0);
	in2 : in  std_logic_vector(width-1 downto 0);
    max  : out  std_logic_vector(width-1 downto 0);
	min  : out  std_logic_vector(width-1 downto 0));
    
end comparator;


architecture bhv of comparator is
   
begin
process (clk,rst)
begin
 if(rst='1') then 
  max <= (others=> '0');
  min <= (others=> '0');
 elsif(rising_edge(clk)) then
  if(en='1') then
    if (unsigned(in1) <= unsigned(in2)) then
      max<= in2;
      min<= in1;
    else
      max<= in1;
      min<= in2;
    end if;
  end if;
 end if;  

end process;

end bhv;
