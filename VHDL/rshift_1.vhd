LIBRARY ieee ;
USE ieee.std_logic_1164.all ;
ENTITY shift1 IS
 generic (
    width  :     positive := 8);
 port (  
		 clk : IN STD_LOGIC ;
		 rst : IN STD_LOGIC ;
		 en  : IN STD_LOGIC ;
		 R 	 : IN  STD_LOGIC_VECTOR(width-1 DOWNTO 0);
		 Q 	 : OUT STD_LOGIC_VECTOR(width-1 DOWNTO 0));
END shift1 ;

ARCHITECTURE str OF shift1 IS

BEGIN

process (clk,rst)
begin
if(rst='1') then  
  Q<=R;
 elsif(rising_edge(clk)) then
  if(en='1') then
Q(0) <= R(1);
Q(1) <= R(2);
Q(2) <= R(3);
Q(3) <= R(4);
Q(4) <= R(5);
Q(5) <= R(6);
Q(6) <= R(7);
Q(7) <= '0';
end if ;
end if;
end process ;

end str ;