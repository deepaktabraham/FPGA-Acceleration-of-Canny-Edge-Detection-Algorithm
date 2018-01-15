library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity datapath_threshold is
  generic (
  width  :  positive := 8);
  port (
    clk         : in  std_logic;
    rst         : in  std_logic;
    mag         : in std_logic_vector(14 downto 0);
    input_prev  : in  std_logic_vector((3*width)-1 downto 0);
    input_curr  : in  std_logic_vector((3*width)-1 downto 0);
    input_next  : in  std_logic_vector((3*width)-1 downto 0);
    vld_in      : in  std_logic;
	vld_out		: out std_logic;
    result      : out std_logic_vector(7 downto 0));
end datapath_threshold;

architecture pipe_datapath of datapath_threshold is

signal reg1_out, reg2_out, reg3_out, reg4_out, reg5_out, reg6_out, reg7_out, reg8_out, reg9_out : std_logic_vector(width-1 downto 0);
signal vld1 : std_logic;  
 
begin
  REG1 : entity work.reg generic map(width) port map(clk, rst, vld_in, input_prev((3*width)-1 downto 2*width), reg1_out);
  REG2 : entity work.reg generic map(width) port map(clk, rst, vld_in, input_prev((2*width)-1 downto width), reg2_out);
  REG3 : entity work.reg generic map(width) port map(clk, rst, vld_in, input_prev(width-1 downto 0), reg3_out);
  REG4 : entity work.reg generic map(width) port map(clk, rst, vld_in, input_curr((3*width)-1 downto 2*width), reg4_out);
  REG5 : entity work.reg generic map(width) port map(clk, rst, vld_in, mag, reg5_out);
  REG6 : entity work.reg generic map(width) port map(clk, rst, vld_in, input_curr(width-1 downto 0), reg6_out);
  REG7 : entity work.reg generic map(width) port map(clk, rst, vld_in, input_next((3*width)-1 downto 2*width), reg7_out);
  REG8 : entity work.reg generic map(width) port map(clk, rst, vld_in, input_next((2*width)-1 downto width), reg8_out);
  REG9 : entity work.reg generic map(width) port map(clk, rst, vld_in, input_next(width-1 downto 0), reg9_out); 
  
  REGV1 : entity work.regbit port map(clk, rst, '1', vld_in, vld1);
  REGV2 : entity work.regbit port map(clk, rst, '1', vld1, vld_out);
  
  THRESHOLD_COMPARATOR : entity work.thres_comp generic map(width) port map(clk, rst, vld1, reg1_out, reg2_out, reg3_out, reg4_out, reg5_out, reg6_out, reg7_out, reg8_out,reg9_out, result);

end pipe_datapath;