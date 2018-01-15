library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mult_pipe is
  generic (
    width1  :  positive := 16;
    width2  :  positive := 16);
  port (
    clk     : in  std_logic;
    rst     : in  std_logic;
    vld_in1 : in  std_logic;
    in1     : in  std_logic_vector(width1-1 downto 0);
    in2     : in  std_logic_vector(width2-1 downto 0);
    output  : out std_logic_vector(width1+width2-1 downto 0));
end mult_pipe;


architecture BHV of mult_pipe is
begin
  process(clk, rst)
    begin
      if rst = '1' then
        output <= (others => '0');
      elsif rising_edge(clk) then
        if vld_in1 = '1' then
          output <= std_logic_vector(unsigned(in1) * unsigned(in2));
        end if;	  
      end if;
    end process;
end BHV;
