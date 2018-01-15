library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity datapath is
    generic (
        WIDTH : positive := 8);
    port (
        clk : in std_logic;
		rst : in std_logic;
		out_prev_row : in std_logic_vector(89 downto 0);
		out_curr_row : in std_logic_vector(89 downto 0);
        out_next_row : in std_logic_vector(89 downto 0);
        gx1 : in std_logic_vector(width-1 downto 0);
		gx2 : in std_logic_vector(width-1 downto 0);
		gx3 : in std_logic_vector(width-1 downto 0);
		gx4 : in std_logic_vector(width-1 downto 0);
		gy1 : in std_logic_vector(width-1 downto 0);
		gy2 : in std_logic_vector(width-1 downto 0);
		gy3 : in std_logic_vector(width-1 downto 0);
		gy4 : in std_logic_vector(width-1 downto 0);
		vld_in : in std_logic;
		vld_out: out std_logic;
        mag : out std_logic_vector(59 downto 0);
        th_input_prev : out std_logic_vector(89 downto 0);
        th_input_curr : out std_logic_vector(89 downto 0);
        th_input_next : out std_logic_vector(89 downto 0)
                        
        
        );
end datapath;

architecture structural of datapath is

signal reg1_out, reg2_out, reg3_out, reg4_out, reg5_out, reg6_out, reg7_out, reg8_out : std_logic_vector(width-1 downto 0);

signal a1,a2,a3,a4,b1,b2,b3,b4 : std_logic_vector(width-1 downto 0);

signal bl1,bl2,bl3,bl4,a31,a32,a33,a34,a21,a22,a23,a24,a11,a12,a13,a14,a1_out1,a2_out1,a3_out1,a4_out1,a1_out2,a2_out2,a3_out2,a4_out2,a1_out3,a2_out3,a3_out3,a4_out3 : std_logic_vector(width-1 downto 0);

signal add_b_1,add_b_2,add_b_3,add_b_4,add_a_1,add_a_2,add_a_3,add_a_4 : std_logic_vector(width downto 0);

signal add_1,add_2,add_3,add_4 : std_logic_vector(width+1 downto 0);

signal vld1, vld2, vld3, vld4, vld5: std_logic;



begin
  REG1 : entity work.reg generic map(width) port map(clk, rst, vld_in, gx1, reg1_out);
  REG2 : entity work.reg generic map(width) port map(clk, rst, vld_in, gx2, reg2_out);
  REG3 : entity work.reg generic map(width) port map(clk, rst, vld_in, gx3, reg3_out);
  REG4 : entity work.reg generic map(width) port map(clk, rst, vld_in, gx4, reg4_out);
  REG5 : entity work.reg generic map(width) port map(clk, rst, vld_in, gy1, reg5_out);
  REG6 : entity work.reg generic map(width) port map(clk, rst, vld_in, gy2, reg6_out);
  REG7 : entity work.reg generic map(width) port map(clk, rst, vld_in, gy3, reg7_out);
  REG8 : entity work.reg generic map(width) port map(clk, rst, vld_in, gy4, reg8_out);
  
  REGV1 : entity work.regbit port map(clk, rst, '1', vld_in, vld1);
  REGV2 : entity work.regbit port map(clk, rst, '1', vld1, vld2);
  REGV3 : entity work.regbit port map(clk, rst, '1', vld2, vld3);
  REGV4 : entity work.regbit port map(clk, rst, '1', vld3, vld4);
  REGV5 : entity work.regbit port map(clk, rst, '1', vld4, vld5);
  REGV6 : entity work.regbit port map(clk, rst, '1', vld5, vld_out);
  
  --------------------------------------------------------------------------------------------------------------------------
    
	U_CMP1 : entity work.comparator generic map (width) port map (clk, rst, vld1, reg1_out, reg5_out, a1, b1);
	U_CMP2 : entity work.comparator generic map (width) port map (clk, rst, vld1, reg2_out, reg6_out, a2, b2);
	U_CMP3 : entity work.comparator generic map (width) port map (clk, rst, vld1, reg3_out, reg7_out, a3, b3);
    U_CMP4 : entity work.comparator generic map (width) port map (clk, rst, vld1, reg4_out, reg8_out, a4, b4);

  ---------------------------------------------------------------------------------------------------------------------------
	
    U_SHIFT_B1 : entity work.shift1 generic map (width) port map (clk, rst, vld2, b1, bl1);
	U_SHIFT_B2 : entity work.shift1 generic map (width) port map (clk, rst, vld2, b2, bl2);
	U_SHIFT_B3 : entity work.shift1 generic map (width) port map (clk, rst, vld2, b3, bl3);
	U_SHIFT_B4 : entity work.shift1 generic map (width) port map (clk, rst, vld2, b4, bl4);

	U_SHIFT3_1 : entity work.shift3 generic map (width) port map (clk, rst, vld2, a1, a31);
	U_SHIFT3_2 : entity work.shift3 generic map (width) port map (clk, rst, vld2, a2, a32);
	U_SHIFT3_3 : entity work.shift3 generic map (width) port map (clk, rst, vld2, a3, a33);
	U_SHIFT3_4 : entity work.shift3 generic map (width) port map (clk, rst, vld2, a4, a34);	
	
	U_SHIFT2_1 : entity work.shift2 generic map (width) port map (clk, rst, vld2, a1, a21);
	U_SHIFT2_2 : entity work.shift2 generic map (width) port map (clk, rst, vld2, a2, a22);
	U_SHIFT2_3 : entity work.shift2 generic map (width) port map (clk, rst, vld2, a3, a23);
	U_SHIFT2_4 : entity work.shift2 generic map (width) port map (clk, rst, vld2, a4, a24);
	
	U_SHIFT_1 : entity work.shift1 generic map (width) port map (clk, rst, vld2, a1, a11);
	U_SHIFT_2 : entity work.shift1 generic map (width) port map (clk, rst, vld2, a2, a12);
	U_SHIFT_3 : entity work.shift1 generic map (width) port map (clk, rst, vld2, a3, a13);
	U_SHIFT_4 : entity work.shift1 generic map (width) port map (clk, rst, vld2, a4, a14);

	REG_A1 : entity work.reg generic map(width) port map(clk, rst, vld2, a1, a1_out1);
	REG_A2 : entity work.reg generic map(width) port map(clk, rst, vld2, a2, a2_out1);
	REG_A3 : entity work.reg generic map(width) port map(clk, rst, vld2, a3, a3_out1);
	REG_A4 : entity work.reg generic map(width) port map(clk, rst, vld2, a4, a4_out1);
    
	---------------------------------------------------------------------------------------------------------------------------------------
	
    U_ADD_B1 : entity work.add_pipe generic map (width, width) port map (clk, rst, vld3, bl1, a31, add_b_1);
	U_ADD_B2 : entity work.add_pipe generic map (width, width) port map (clk, rst, vld3, bl2, a32, add_b_2);
	U_ADD_B3 : entity work.add_pipe generic map (width, width) port map (clk, rst, vld3, bl3, a33, add_b_3);
	U_ADD_B4 : entity work.add_pipe generic map (width, width) port map (clk, rst, vld3, bl4, a34, add_b_4);

    U_ADD_A1 : entity work.add_pipe generic map (width, width) port map (clk, rst, vld3, a21, a11, add_a_1);
	U_ADD_A2 : entity work.add_pipe generic map (width, width) port map (clk, rst, vld3, a22, a12, add_a_2);
	U_ADD_A3 : entity work.add_pipe generic map (width, width) port map (clk, rst, vld3, a23, a13, add_a_3);
	U_ADD_A4 : entity work.add_pipe generic map (width, width) port map (clk, rst, vld3, a24, a14, add_a_4);
	
	REG_A11 : entity work.reg generic map(width) port map(clk, rst, vld3, a1_out1, a1_out2);
	REG_A22 : entity work.reg generic map(width) port map(clk, rst, vld3, a2_out1, a2_out2);
	REG_A33 : entity work.reg generic map(width) port map(clk, rst, vld3, a3_out1, a3_out2);
	REG_A44 : entity work.reg generic map(width) port map(clk, rst, vld3, a4_out1, a4_out2);
	
	---------------------------------------------------------------------------------------------------------------------------------------------
	
	U_ADD1 : entity work.add_pipe generic map (width+1, width+1) port map (clk, rst, vld4, add_b_1, add_a_1, add_1);
	U_ADD2 : entity work.add_pipe generic map (width+1, width+1) port map (clk, rst, vld4, add_b_2, add_a_2, add_2);
	U_ADD3 : entity work.add_pipe generic map (width+1, width+1) port map (clk, rst, vld4, add_b_3, add_a_3, add_3);
	U_ADD4 : entity work.add_pipe generic map (width+1, width+1) port map (clk, rst, vld4, add_b_4, add_a_4, add_4);
	
	REG_A111 : entity work.reg generic map(width) port map(clk, rst, vld4, a1_out2, a1_out3);
	REG_A222 : entity work.reg generic map(width) port map(clk, rst, vld4, a2_out2, a2_out3);
	REG_A333 : entity work.reg generic map(width) port map(clk, rst, vld4, a3_out2, a3_out3);
	REG_A444 : entity work.reg generic map(width) port map(clk, rst, vld4, a4_out2, a4_out3);
	
   ---------------------------------------------------------------------------------------------------------------------------------------------
   
    U_CMP_1 : entity work.comparator1 generic map(width) port map (clk, rst, vld5, add_1, a1_out3, mag(59 downto 45));
	U_CMP_2 : entity work.comparator1 generic map(width) port map (clk, rst, vld5, add_2, a2_out3, mag(44 downto 30));
	U_CMP_3 : entity work.comparator1 generic map(width) port map (clk, rst, vld5, add_3, a3_out3, mag(29 downto 15));
	U_CMP_4 : entity work.comparator1 generic map(width) port map (clk, rst, vld5, add_4, a4_out3, mag(14 downto 0));
            
   -- process(vld5)
   -- begin
     --   if(vld5 = '1' and (clk'event and clk = '1') ) then
            th_input_prev <= out_prev_row;
            th_input_curr <= out_curr_row;
            th_input_next <= out_next_row;
     --   end if;
   -- end process;    
              
end structural;
