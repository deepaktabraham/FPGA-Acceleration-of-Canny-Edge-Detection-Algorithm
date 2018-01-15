library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity add_pipe is
  generic (
    width1  :  positive := 16;
    width2  :  positive := 16);
  port (
    clk     : in  std_logic;
    rst     : in  std_logic;
    vld_in1 : in  std_logic;
    in1     : in  std_logic_vector(width1-1 downto 0);
    in2     : in  std_logic_vector(width2-1 downto 0);
    output  : out std_logic_vector(width1 downto 0));    
end add_pipe;

-- TODO: Implement a behavioral description of a pipelined adder (i.e., an
-- adder with a register on the output). The output should be one bit larger
-- than the input, and should use the "width" generic as opposed to being
-- hardcoded to a specific value.

architecture BHV of add_pipe is
begin
  process(clk, rst)
    begin
      if rst = '1' then
        output <= (others => '0');     
      elsif rising_edge(clk) then
        if vld_in1 = '1' then
          output <= std_logic_vector(resize(signed(in1), width1+1) + resize(signed(in2), width1+1));  
        end if;  
      end if;
    end process;	  
end BHV;
