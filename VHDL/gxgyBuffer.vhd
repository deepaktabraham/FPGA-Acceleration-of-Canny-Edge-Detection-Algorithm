library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.config_pkg.all;

entity gxgyBuffer is
 generic (width : positive := 64;
          inputWidth : positive := 32);
 port ( 
        clk         : in std_logic;
		rst         : in std_logic;
		en          : in std_logic;
		row_count   : in std_logic_vector(C_MEM_ADDR_WIDTH downto 0);
        input       : in std_logic_vector(inputWidth-1 downto 0);
        output_prev : out std_logic_vector(inputWidth-1 downto 0);
		output_curr : out std_logic_vector(inputWidth-1 downto 0);
		output_next : out std_logic_vector(inputWidth-1 downto 0);
		vld_out     : out std_logic
        );
end gxgyBuffer;

architecture BHV of gxgyBuffer is
signal state : std_logic_vector(2 downto 0);
signal prev_buffer : std_logic_vector(width-1 downto 0);
signal curr_buffer : std_logic_vector(width-1 downto 0);
signal next_buffer : std_logic_vector(width-1 downto 0);
signal temp_buffer : std_logic_vector((inputWidth/4)-1 downto 0);
signal zero        : std_logic_vector((inputWidth/4)-1 downto 0) := (others => '0');
signal next_buffer_zero : std_logic_vector(width-inputWidth-1 downto 0) := (others => '0');

begin
  process(clk, rst)
    variable ip_count : std_logic_vector(C_MEM_ADDR_WIDTH downto 0) := (others => '0');
    begin
      if rst = '1' then
        state <= "000";	
        prev_buffer <= (others => '0');
        curr_buffer <= (others => '0');
        next_buffer <= (others => '0');
        output_prev <= (others => '0');
        output_curr <= (others => '0');
        output_next <= (others => '0');
        temp_buffer <= (others => '0');
        vld_out <= '0';	
      elsif rising_edge(clk) then
		  if state = "000" then   
		    if en = '1' then 
              ip_count := std_logic_vector(unsigned(ip_count) + to_unsigned(1, C_MEM_ADDR_WIDTH+1));			
		      state <= "001";
  		      if ip_count < row_count then
                next_buffer <= next_buffer(width-inputWidth-1 downto 0) & temp_buffer & input(inputWidth-1 downto (inputWidth/4));
                temp_buffer <= input((inputWidth/4)-1 downto 0);
              else 
                next_buffer <= next_buffer(width-inputWidth-1 downto 0) & temp_buffer & input(inputWidth-1 downto (inputWidth/2)) & zero;
                temp_buffer <= (others => '0');
              end if;         
              prev_buffer <= (others => '0');
              curr_buffer <= (others => '0');
              output_prev <= (others => '0');
              output_curr <= (others => '0');
              output_next <= (others => '0');         
              vld_out <= '0';			  
		    end if;
          elsif state = "001" then
            if ip_count < row_count then
              ip_count := std_logic_vector(unsigned(ip_count) + to_unsigned(1, C_MEM_ADDR_WIDTH+1));			
              state <= "001";
 		      if ip_count < row_count then
                next_buffer <= next_buffer(width-inputWidth-1 downto 0) & temp_buffer & input(inputWidth-1 downto (inputWidth/4));
                temp_buffer <= input((inputWidth/4)-1 downto 0);
              else 
                next_buffer <= next_buffer(width-inputWidth-1 downto 0) & temp_buffer & input(inputWidth-1 downto (inputWidth/2)) & zero;
                temp_buffer <= (others => '0');
              end if;         
              prev_buffer <= (others => '0');
              curr_buffer <= (others => '0');
              output_prev <= (others => '0');
              output_curr <= (others => '0');
              output_next <= (others => '0');         
              vld_out <= '0'; 
			else 
			  ip_count := (0 => '1', others => '0');
			  --temp_buffer <= (others => '0');
			  state <= "010";
	          output_prev <= curr_buffer(width-1 downto width-inputWidth);
              output_curr <= next_buffer(width-1 downto width-inputWidth);
              output_next <= zero & input(inputWidth-1 downto (inputWidth/4));
              prev_buffer <= curr_buffer;
              curr_buffer <= next_buffer;
              next_buffer <= next_buffer_zero & zero & input(inputWidth-1 downto (inputWidth/4));
              temp_buffer <= input((inputWidth/4)-1 downto 0);
              vld_out <= '1';			  
			end if;
		  elsif state = "010" then
		    if en = '0' then
              ip_count := (0 => '1', others => '0');			
              state <= "100";
	          output_prev <= curr_buffer(width-1 downto width-inputWidth);
              output_curr <= next_buffer(width-1 downto width-inputWidth);
              output_next <= (others => '0');
              temp_buffer <= (others => '0');       
              prev_buffer <= curr_buffer;
              curr_buffer <= next_buffer;
              next_buffer <= (others => '0');
              vld_out <= '1';
			else
	          if ip_count < row_count then
                ip_count := std_logic_vector(unsigned(ip_count) + to_unsigned(1, C_MEM_ADDR_WIDTH+1));			
                state <= "011";
                output_prev <= prev_buffer(width-1-(inputWidth*(to_integer(unsigned(ip_count))-1)) downto width-(inputWidth*to_integer(unsigned(ip_count))));
                output_curr <= curr_buffer(width-1-(inputWidth*(to_integer(unsigned(ip_count))-1)) downto width-(inputWidth*to_integer(unsigned(ip_count))));       
                prev_buffer <= prev_buffer;
                curr_buffer <= curr_buffer;
                if ip_count < row_count then
                  output_next <= temp_buffer & input(inputWidth-1 downto (inputWidth/4));
                  next_buffer <= next_buffer(width-inputWidth-1 downto 0) & temp_buffer & input(inputWidth-1 downto (inputWidth/4));
                  temp_buffer <= input((inputWidth/4)-1 downto 0);
                else 
                  output_next <= temp_buffer & input(inputWidth-1 downto (inputWidth/2)) & zero;
                  next_buffer <= next_buffer(width-inputWidth-1 downto 0) & temp_buffer & input(inputWidth-1 downto (inputWidth/2)) & zero;
                  temp_buffer <= (others => '0');
                end if;
                vld_out <= '1';
			  else 
			    ip_count := (0 => '1', others => '0');
			    state <= "010";
			    output_prev <= curr_buffer(width-1 downto width-inputWidth);
                output_curr <= next_buffer(width-1 downto width-inputWidth);
                output_next <= zero & input(inputWidth-1 downto (inputWidth/4));
                prev_buffer <= curr_buffer;
                curr_buffer <= next_buffer;
                next_buffer <= next_buffer_zero & zero & input(inputWidth-1 downto (inputWidth/4));
                temp_buffer <= input((inputWidth/4)-1 downto 0);
                vld_out <= '1';		
              end if;
			end if;
		  elsif state = "011" then
		    if en = '0' then			
              ip_count := (0 => '1', others => '0');			
              state <= "100";
              output_prev <= curr_buffer(width-1 downto width-inputWidth);
              output_curr <= next_buffer(width-1 downto width-inputWidth);
              output_next <= (others => '0');
              temp_buffer <= (others => '0');       
              prev_buffer <= curr_buffer;
              curr_buffer <= next_buffer;
              next_buffer <= (others => '0');
              vld_out <= '1';
			else
			  if ip_count < row_count then
			    ip_count := std_logic_vector(unsigned(ip_count) + to_unsigned(1, C_MEM_ADDR_WIDTH+1));
			    state <= "011";
                output_prev <= prev_buffer(width-1-(inputWidth*(to_integer(unsigned(ip_count))-1)) downto width-(inputWidth*to_integer(unsigned(ip_count))));
                output_curr <= curr_buffer(width-1-(inputWidth*(to_integer(unsigned(ip_count))-1)) downto width-(inputWidth*to_integer(unsigned(ip_count))));       
                prev_buffer <= prev_buffer;
                curr_buffer <= curr_buffer;
                if ip_count < row_count then
                  output_next <= temp_buffer & input(inputWidth-1 downto (inputWidth/4));
                  next_buffer <= next_buffer(width-inputWidth-1 downto 0) & temp_buffer & input(inputWidth-1 downto (inputWidth/4));
                  temp_buffer <= input((inputWidth/4)-1 downto 0);
                else 
                  output_next <= temp_buffer & input(inputWidth-1 downto (inputWidth/2)) & zero;
                  next_buffer <= next_buffer(width-inputWidth-1 downto 0) & temp_buffer & input(inputWidth-1 downto (inputWidth/2)) & zero;
                  temp_buffer <= (others => '0');
                end if;
                vld_out <= '1';
			  else
			    ip_count := (0 => '1', others => '0');
				--temp_buffer <= (others => '0');
			    state <= "010";
			    output_prev <= curr_buffer(width-1 downto width-inputWidth);
                output_curr <= next_buffer(width-1 downto width-inputWidth);
                output_next <= zero & input(inputWidth-1 downto (inputWidth/4));
                prev_buffer <= curr_buffer;
                curr_buffer <= next_buffer;
                next_buffer <= next_buffer_zero & zero & input(inputWidth-1 downto (inputWidth/4));
                temp_buffer <= input((inputWidth/4)-1 downto 0);
                vld_out <= '1';
			  end if;
            end if;
          elsif state = "100" then			
			  if ip_count < row_count then
			    ip_count := std_logic_vector(unsigned(ip_count) + to_unsigned(1, C_MEM_ADDR_WIDTH+1));
			    state <= "101";
	            output_prev <= prev_buffer(width-1-(inputWidth*(to_integer(unsigned(ip_count))-1)) downto width-(inputWidth*to_integer(unsigned(ip_count))));
                output_curr <= curr_buffer(width-1-(inputWidth*(to_integer(unsigned(ip_count))-1)) downto width-(inputWidth*to_integer(unsigned(ip_count))));              
                output_next <= (others => '0');
                temp_buffer <= (others => '0');
                prev_buffer <= prev_buffer;
                curr_buffer <= curr_buffer;
                next_buffer <= (others => '0');
                vld_out <= '1';
			  else
			    ip_count := (others => '0');
			    state <= "000";
                prev_buffer <= (others => '0');
                curr_buffer <= (others => '0');
                next_buffer <= (others => '0');
                output_prev <= (others => '0');
                output_curr <= (others => '0');
                output_next <= (others => '0');
                temp_buffer <= (others => '0');
                vld_out <= '0';
			  end if;
          elsif state = "101" then			
			  if ip_count < row_count then
			    ip_count := std_logic_vector(unsigned(ip_count) + to_unsigned(1, C_MEM_ADDR_WIDTH+1));
			    state <= "101";
	            output_prev <= prev_buffer(width-1-(inputWidth*(to_integer(unsigned(ip_count))-1)) downto width-(inputWidth*to_integer(unsigned(ip_count))));
                output_curr <= curr_buffer(width-1-(inputWidth*(to_integer(unsigned(ip_count))-1)) downto width-(inputWidth*to_integer(unsigned(ip_count))));              
                output_next <= (others => '0');
                temp_buffer <= (others => '0');
                prev_buffer <= prev_buffer;
                curr_buffer <= curr_buffer;
                next_buffer <= (others => '0');
                vld_out <= '1';
			  else
			    ip_count := (others => '0');
			    state <= "000";
                prev_buffer <= (others => '0');
                curr_buffer <= (others => '0');
                next_buffer <= (others => '0');
                output_prev <= (others => '0');
                output_curr <= (others => '0');
                output_next <= (others => '0');
                temp_buffer <= (others => '0');
                vld_out <= '0';		
			  end if;		
          end if;			  
      end if;
    end process;
end BHV;
