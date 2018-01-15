library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity datapathGx is
  generic (
  width : positive := 8);
  port (
        clk          : in  std_logic;
        rst          : in  std_logic;
        prev_row     : in  std_logic_vector(47 downto 0);
        curr_row     : in  std_logic_vector(47 downto 0);
        next_row     : in  std_logic_vector(47 downto 0);
        input_prev   : in  std_logic_vector((3*width)-1 downto 0);
        input_curr   : in  std_logic_vector((3*width)-1 downto 0);
        input_next   : in  std_logic_vector((3*width)-1 downto 0);
        sob_coeff1   : in  std_logic_vector(1 downto 0);
        sob_coeff2   : in  std_logic_vector(1 downto 0);       	
        vld_in       : in  std_logic;
        vld_out      : out std_logic;
        result       : out std_logic_vector(width+4 downto 0);
        out_prev_row : out std_logic_vector(89 downto 0);
        out_curr_row : out std_logic_vector(89 downto 0);
        out_next_row : out std_logic_vector(89 downto 0)
    );
end datapathGx;

architecture pipe_datapath of datapathGx is
signal mult1_out, mult2_out, mult3_out, mult4_out, mult5_out, mult6_out : std_logic_vector(width+1 downto 0);
signal reg1_out, reg2_out, reg3_out, reg4_out, reg5_out, reg6_out : std_logic_vector(width-1 downto 0);
signal vld1, vld2, vld3, vld4 : std_logic;  
signal sub1_out, sub2_out, sub3_out, sub3_out1 : std_logic_vector(width+2 downto 0);
signal add1_out : std_logic_vector(width+3 downto 0);
--signal datapath_op : std_logic_vector(width+4 downto 0);
 
begin
  --result <= std_logic_vector(resize(unsigned(datapath_op), width));
  REG1 : entity work.reg generic map(width) port map(clk, rst, vld_in, input_prev((3*width)-1 downto 2*width), reg1_out);
  REG2 : entity work.reg generic map(width) port map(clk, rst, vld_in, input_prev(width-1 downto 0), reg2_out);
  REG3 : entity work.reg generic map(width) port map(clk, rst, vld_in, input_curr((3*width)-1 downto 2*width), reg3_out);
  REG4 : entity work.reg generic map(width) port map(clk, rst, vld_in, input_curr(width-1 downto 0), reg4_out);
  REG5 : entity work.reg generic map(width) port map(clk, rst, vld_in, input_next((3*width)-1 downto 2*width), reg5_out);
  REG6 : entity work.reg generic map(width) port map(clk, rst, vld_in, input_next(width-1 downto 0), reg6_out);
  
  REGV1 : entity work.regbit port map(clk, rst, '1', vld_in, vld1);
  REGV2 : entity work.regbit port map(clk, rst, '1', vld1, vld2);
  REGV3 : entity work.regbit port map(clk, rst, '1', vld2, vld3);
  REGV4 : entity work.regbit port map(clk, rst, '1', vld3, vld4);
  REGV5 : entity work.regbit port map(clk, rst, '1', vld4, vld_out);  

  MULT1 : entity work.mult_pipe generic map(width, 2) port map(clk, rst, vld1, reg1_out, sob_coeff1, mult1_out);
  MULT2 : entity work.mult_pipe generic map(width, 2) port map(clk, rst, vld1, reg2_out, sob_coeff1, mult2_out);
  MULT3 : entity work.mult_pipe generic map(width, 2) port map(clk, rst, vld1, reg3_out, sob_coeff2, mult3_out);
  MULT4 : entity work.mult_pipe generic map(width, 2) port map(clk, rst, vld1, reg4_out, sob_coeff2, mult4_out);
  MULT5 : entity work.mult_pipe generic map(width, 2) port map(clk, rst, vld1, reg5_out, sob_coeff1, mult5_out);
  MULT6 : entity work.mult_pipe generic map(width, 2) port map(clk, rst, vld1, reg6_out, sob_coeff1, mult6_out);
 
  SUB1   : entity work.sub_pipe generic map(width+2) port map(clk, rst, vld2, mult2_out, mult1_out, sub1_out);    
  SUB2   : entity work.sub_pipe generic map(width+2) port map(clk, rst, vld2, mult4_out, mult3_out, sub2_out);
  SUB3   : entity work.sub_pipe generic map(width+2) port map(clk, rst, vld2, mult6_out, mult5_out, sub3_out);

  ADD1   : entity work.add_pipe generic map(width+3, width+3) port map(clk, rst, vld3, sub1_out, sub2_out, add1_out);
  REG7   : entity work.reg generic map(width+3) port map(clk, rst, vld3, sub3_out, sub3_out1);  
  
  ADD2   : entity work.add_pipe generic map(width+4, width+3) port map(clk, rst, vld4, add1_out, sub3_out1, result);
 -- process(vld4)
 -- begin
   ---   if((vld4 = '1') and (clk'event and clk = '1')) then
            out_prev_row <= "0000000" & prev_row(47 downto 40) & "0000000" & prev_row(39 downto 32) 
                          & "0000000" & prev_row(31 downto 24) & "0000000" & prev_row(23 downto 16) 
                          & "0000000" & prev_row(15 downto 8) & "0000000" & prev_row(7 downto 0);
            out_curr_row <= "0000000" & curr_row(47 downto 40) & "0000000" & curr_row(39 downto 32) 
                          & "0000000" & curr_row(31 downto 24) & "0000000" & curr_row(23 downto 16) 
                          & "0000000" & curr_row(15 downto 8) & "0000000" & curr_row(7 downto 0);
            out_next_row <= "0000000" & next_row(47 downto 40) & "0000000" & next_row(39 downto 32) 
                          & "0000000" & next_row(31 downto 24) & "0000000" & next_row(23 downto 16) 
                          & "0000000" & next_row(15 downto 8) & "0000000" & next_row(7 downto 0);
   ---   end if;
  --end process;          
end pipe_datapath;
