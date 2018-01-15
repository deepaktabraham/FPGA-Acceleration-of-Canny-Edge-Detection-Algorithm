library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity comparator1 is
  generic (
    width  :     positive := 8);
  port (
    clk    : in  std_logic;
    rst    : in  std_logic;
    en     : in  std_logic;
    in1 : in  std_logic_vector(width+1 downto 0);
	in2 : in  std_logic_vector(width-1 downto 0);
    result  : out  std_logic_vector(width+1 downto 0));
    
end comparator1;


architecture bhv of comparator1 is
   
begin
process (clk,rst)
begin
 if(rst='1') then 
  result <= (others=> '0');
 elsif(rising_edge(clk)) then
  if(en='1') then
    if (unsigned(in1) <= unsigned(in2)) then
      result <= std_logic_vector(resize(unsigned(in1), width+2));  
    else
      result <= in1;
    end if;
  end if;
 end if;  

end process;

end bhv;
