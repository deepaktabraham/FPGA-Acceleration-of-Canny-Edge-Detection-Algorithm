library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controller is

port (
    clk      : in  std_logic;
    rst      : in  std_logic;
    go       : in  std_logic;
    done     : out std_logic;
	data_vld : out std_logic;
	rslt_rdy : in std_logic
	);

end controller;

architecture BHV of controller is

begin

  process (clk, rst)
    begin
      if (rst = '1') then
		done <= '0';
		data_vld <= '0';
		
      elsif (rising_edge(clk)) then
		if (go = '1') then
          data_vld <= '1'; 
          done <= '0';
		elsif(go = '0') then
		  if(rslt_rdy = '1') then
			data_vld <= '0';
			done <= '1';  
		  end if;
		end if;
	  end if;	
	end process;
end BHV;
