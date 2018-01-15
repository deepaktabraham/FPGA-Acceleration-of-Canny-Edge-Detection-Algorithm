library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity thres_comp is
  generic (
  width : positive := 8);
  port (
    clk         : in  std_logic;
    rst         : in  std_logic;
    vld_in    	: in  std_logic;
	input_p1    : in  std_logic_vector((width)-1 downto 0);
    input_p2    : in  std_logic_vector((width)-1 downto 0);
	input_p3    : in  std_logic_vector((width)-1 downto 0);
    input_q1    : in  std_logic_vector((width)-1 downto 0);
	input_q2    : in  std_logic_vector((width)-1 downto 0);
    input_q3    : in  std_logic_vector((width)-1 downto 0);
	input_r1    : in  std_logic_vector((width)-1 downto 0);
    input_r2    : in  std_logic_vector((width)-1 downto 0);
	input_r3    : in  std_logic_vector((width)-1 downto 0);
    result    	: out std_logic_vector(7 downto 0));
end thres_comp;

architecture BHV of thres_comp is 
signal threshold2 : std_logic_vector (7 downto 0) := "10110010";
signal threshold1 : std_logic_vector (7 downto 0) := "00111010";
begin
  process(clk, rst)
  begin
    if (rst = '1') then
		result <= (others => '0');
    elsif (clk'event and clk = '1') then
      if (vld_in = '1') then
        if(unsigned(input_q2) >= unsigned(threshold2)) then
			result <= "11111111";
		elsif(unsigned(input_q2) <= unsigned(threshold1)) then
			result <= "00000000";
		elsif(unsigned(input_p1) >= unsigned(threshold2) or unsigned(input_p2) >= unsigned(threshold2) or unsigned(input_p3) >= unsigned(threshold2) or unsigned(input_q1) >= unsigned(threshold2) or unsigned(input_q3) >= unsigned(threshold2) or unsigned(input_r1) >= unsigned(threshold2) or unsigned(input_r2) >= unsigned(threshold2) or unsigned(input_r3) >= unsigned(threshold2)) then	
			result <= "11111111";
		else 	
			result <= "00000000";
		end if;	
	  end if;        
    end if;
  end process;
end BHV;