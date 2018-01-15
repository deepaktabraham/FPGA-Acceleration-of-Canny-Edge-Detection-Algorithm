library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.config_pkg.all;

entity smart_buff is
 generic (width : positive := 32; outputWidth : positive := 48);
 port ( 
        clk    : in std_logic;
		rst    : in std_logic;
		en     : in std_logic;
        input  : in std_logic_vector(width-1 downto 0);
        output : out std_logic_vector(outputWidth-1 downto 0)
        );
end smart_buff;

architecture BHV of smart_buff is
signal state : std_logic_vector(2 downto 0);
signal sbuffer : std_logic_vector((2*width)-1 downto 0);
signal zero : std_logic_vector(width-1 downto 0) := (others => '0');

begin
  process(clk, rst)
    begin
      if rst = '1' then
        state <= "000";	
        output <= (others => '0');
        sbuffer <= (others => '0');	
      elsif rising_edge(clk) then
		  if state = "000" then   
		    if en = '1' then    
		      state <= "001";
              output <= (others => '0');
              sbuffer <= zero & input;			  
		    end if;
          elsif state = "001" then			
              state <= "010"; 
              output <= (others => '0');
              sbuffer <= sbuffer(width-1 downto 0) & input;
		  elsif state = "010" then
		    if en = '0' then			
              state <= "100";
              output <= sbuffer((2*width)-1 downto (2*width)-outputWidth);
              sbuffer <= sbuffer(width-1 downto 0) & zero;
            else			
              state <= "011";
              output <= sbuffer((2*width)-1 downto (2*width)-outputWidth);
              sbuffer <= sbuffer(width-1 downto 0) & input;
            end if;
		  elsif state = "011" then
		    if en = '0' then			
              state <= "100";
              output <= sbuffer((2*width)-1 downto (2*width)-outputWidth);
              sbuffer <= sbuffer(width-1 downto 0) & zero;
			else
			  state <= "011";
              output <= sbuffer((2*width)-1 downto (2*width)-outputWidth);
              sbuffer <= sbuffer(width-1 downto 0) & input;
            end if;  		 
		  elsif state = "100" then			
              state <= "101";
              output <= sbuffer((2*width)-1 downto (2*width)-outputWidth);
              sbuffer <= sbuffer(width-1 downto 0) & zero;
		  elsif state = "101" then			
              state <= "000";		
              output <= (others => '0');
              sbuffer <= (others => '0');
          else
              state <= "000";
              output <= (others => '0');
              sbuffer <= (others => '0');
          end if;			
      end if;
    end process;
end BHV;
