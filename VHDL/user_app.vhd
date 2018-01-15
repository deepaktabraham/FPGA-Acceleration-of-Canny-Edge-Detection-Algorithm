library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.config_pkg.all;
--use work.user_pkg.all;

entity user_app is
    port (
        clk : in std_logic;
        rst : in std_logic;

        -- memory-map interface
        mmap_wr_en   : in  std_logic;
        mmap_wr_addr : in  std_logic_vector(MMAP_ADDR_RANGE);
        mmap_wr_data : in  std_logic_vector(MMAP_DATA_RANGE);
        mmap_rd_en   : in  std_logic;
        mmap_rd_addr : in  std_logic_vector(MMAP_ADDR_RANGE);
        mmap_rd_data : out std_logic_vector(MMAP_DATA_RANGE)
        );
end user_app;

architecture default of user_app is

	signal go   : std_logic;
    signal size : std_logic_vector(C_MEM_ADDR_WIDTH downto 0);
    signal done : std_logic;
	
	signal mem_in_wr_data       : std_logic_vector(C_MEM_IN_WIDTH-1 downto 0);
    signal mem_in_wr_addr       : std_logic_vector(C_MEM_ADDR_WIDTH-1 downto 0);
    signal mem_in_rd_data1      : std_logic_vector(C_MEM_IN_WIDTH-1 downto 0);
    signal mem_in_rd_addr1      : std_logic_vector(C_MEM_ADDR_WIDTH-1 downto 0) := (others => '0');
    signal mem_in_rd_data2      : std_logic_vector(C_MEM_IN_WIDTH-1 downto 0);
    signal mem_in_rd_addr2      : std_logic_vector(C_MEM_ADDR_WIDTH-1 downto 0) := (others => '0');
    signal mem_in_rd_data3      : std_logic_vector(C_MEM_IN_WIDTH-1 downto 0);
    signal mem_in_rd_addr3      : std_logic_vector(C_MEM_ADDR_WIDTH-1 downto 0) := (others => '0');
    signal mem_in_wr_en         : std_logic;
    signal mem_in_rd_addr_valid : std_logic;
	
	signal data_vld             : std_logic;
	signal data_vld_addr_gen    : std_logic;
	signal smartBuff_en         : std_logic;
	signal datapath_valid_in    : std_logic;
	
	signal row_count            : std_logic_vector(C_MEM_ADDR_WIDTH downto 0) := std_logic_vector(to_unsigned(C_COLUMN_COUNT, C_MEM_ADDR_WIDTH+1));
	
	signal gx_result    : std_logic_vector(51 downto 0);
	signal gy_result    : std_logic_vector(51 downto 0);
	signal mag_en      : std_logic_vector(3 downto 0);
	signal buffer_en   : std_logic;
	signal mag_result  : std_logic_vector(59 downto 0);
	
	
	signal input_prev           : std_logic_vector(47 downto 0);
    signal input_curr           : std_logic_vector(47 downto 0);
    signal input_next           : std_logic_vector(47 downto 0);
	
	signal mag_prev              : std_logic_vector(59 downto 0);
    signal mag_curr              : std_logic_vector(59 downto 0);
    signal mag_next              : std_logic_vector(59 downto 0);
	signal mag_valid             : std_logic;
	
	signal th_input_prev        : std_logic_vector(89 downto 0);
    signal th_input_curr        : std_logic_vector(89 downto 0);
    signal th_input_next        : std_logic_vector(89 downto 0);
	signal th_valid             : std_logic;
	
	signal rslt_rdy             : std_logic;
	
	
	signal mem_out_wr_data       : std_logic_vector(C_MEM_OUT_WIDTH-1 downto 0) := (others => '0');
    signal mem_out_wr_addr       : std_logic_vector(C_MEM_ADDR_WIDTH-1 downto 0) := (others => '0');
    signal mem_out_rd_data       : std_logic_vector(C_MEM_OUT_WIDTH-1 downto 0);
    signal mem_out_rd_addr       : std_logic_vector(C_MEM_ADDR_WIDTH-1 downto 0);
    signal mem_out_wr_en         : std_logic_vector(3 downto 0);
    signal mem_out_wr_data_valid : std_logic;
    signal mem_out_done          : std_logic;	
    
    signal out_prev_row          : std_logic_vector(89 downto 0);
    signal out_curr_row          : std_logic_vector(89 downto 0);
    signal out_next_row          : std_logic_vector(89 downto 0);
    signal prev_row              : std_logic_vector(89 downto 0);
    signal curr_row              : std_logic_vector(89 downto 0);
    signal next_row              : std_logic_vector(89 downto 0);

begin

     
	------------------------------------------------------------------------------
    U_MMAP : entity work.memory_map
        port map (
            clk     => clk,
            rst     => rst,
            wr_en   => mmap_wr_en,
            wr_addr => mmap_wr_addr,
            wr_data => mmap_wr_data,
            rd_en   => mmap_rd_en,
            rd_addr => mmap_rd_addr,
            rd_data => mmap_rd_data,
		
			-- TODO: connect to appropriate logic
            go              => go,         
            size            => size,       
            done            => done,       
			
			-- already connected to block RAMs
			-- the memory map functionality writes to the input ram
			-- and reads from the output ram
            mem_in_wr_data  => mem_in_wr_data,
            mem_in_wr_addr  => mem_in_wr_addr,
            mem_in_wr_en    => mem_in_wr_en,
            mem_out_rd_data => mem_out_rd_data,
            mem_out_rd_addr => mem_out_rd_addr
            );
	------------------------------------------------------------------------------

	
	------------------------------------------------------------------------------
    -- input memory
    -- written to by memory map
    -- read from by controller+datapath
    U_MEM_IN : entity work.ip_ram(SYNC_READ)
        generic map (
            num_words  => 2**C_MEM_ADDR_WIDTH,
            word_width => C_MEM_IN_WIDTH,
            addr_width => C_MEM_ADDR_WIDTH)
        port map (
            clk   => clk,
            wen   => mem_in_wr_en,
            waddr => mem_in_wr_addr,
            wdata => mem_in_wr_data,
            raddr1 => mem_in_rd_addr1,  -- TODO: connect to input address generator prev row
            rdata1 => mem_in_rd_data1,  -- TODO: connect to smart buffer 1
            raddr2 => mem_in_rd_addr2,  -- TODO: connect to input address generator current row
            rdata2 => mem_in_rd_data2,  -- TODO: connect to smart buffer 2
            raddr3 => mem_in_rd_addr3,  -- TODO: connect to input address generator next row
            rdata3 => mem_in_rd_data3); -- TODO: connect to smart buffer 3                        
	------------------------------------------------------------------------------

	
	------------------------------------------------------------------------------
    -- output memory
    -- written to by controller+datapath
    -- read from by memory map
    U_MEM_OUT : entity work.op_ram(SYNC_READ)
        generic map (
            num_words  => 2**C_MEM_ADDR_WIDTH,
            word_width => C_MEM_OUT_WIDTH,
            addr_width => C_MEM_ADDR_WIDTH)
        port map (
            clk   => clk,
            wen   => mem_out_wr_en(0), --cs_datapath_vld(0), --gx_valid, --gxBuffer_en(0), --mem_out_wr_en(0),
            waddr => mem_out_wr_addr,  -- TODO: connect to output address generator
            wdata => mem_out_wr_data, --temp, --cs_result(7 downto 0), --mem_out_wr_data,  -- TODO: connect to pipeline output
            raddr => mem_out_rd_addr,
            rdata => mem_out_rd_data);
	------------------------------------------------------------------------------
    U_CONTROLLER : entity work.controller
        port map (
            clk => clk,
            rst => rst,
            go  => go,
            rslt_rdy => rslt_rdy,
            done => done,
            data_vld => data_vld
            );	
	------------------------------------------------------------------------------            
    U_IP_ADD_GEN_PREV_ROW : entity work.ip_address_generator_prow
                port map (
                    clk => clk,
                    rst => rst,
                    en  => data_vld,
                    --size => size,
                    add_out => mem_in_rd_addr1
                    );
    ------------------------------------------------------------------------------
    U_PREV_ROW_SMART_BUFFER : entity work.smart_buff
                generic map (
                width => 32,
                outputWidth => 48)
                port map (
                    clk => clk,
                    rst => rst,
                    en  => smartBuff_en,
                    input => mem_in_rd_data1,
                    output => input_prev
                    );
    ------------------------------------------------------------------------------    
    U_IP_ADD_GEN_CURR_ROW : entity work.ip_address_generator_crow
                port map (
                    clk => clk,
                    rst => rst,
                    en  => data_vld,
                    --size => size,
                    add_out => mem_in_rd_addr2,
                    vld_out => data_vld_addr_gen
                    );
    ------------------------------------------------------------------------------
    U_REG_VLD_ADDR_GEN : entity work.regbit port map(clk, rst, '1', data_vld_addr_gen, smartBuff_en);
    ------------------------------------------------------------------------------
    U_CURR_ROW_SMART_BUFFER : entity work.smart_buff_v
                generic map (
                width => 32,
                outputWidth => 48)
                port map (
                    clk => clk,
                    rst => rst,
                    en  => smartBuff_en,
                    input => mem_in_rd_data2,
                    valid => datapath_valid_in,
                    output => input_curr
                    );
    ------------------------------------------------------------------------------
    U_IP_ADD_GEN_NEXT_ROW : entity work.ip_address_generator_nrow
                port map (
                    clk => clk,
                    rst => rst,
                    en  => data_vld,
                    --size => size,
                    add_out => mem_in_rd_addr3
                    );
    ------------------------------------------------------------------------------
    U_NEXT_ROW_SMART_BUFFER : entity work.smart_buff
                generic map (
                width => 32,
                outputWidth => 48)
                port map (
                    clk => clk,
                    rst => rst,
                    en  => smartBuff_en,
                    input => mem_in_rd_data3,
                    output => input_next
                    );
    ------------------------------------------------------------------------------  
  LOOP_UNROLL1: for n in 3 downto 0 generate           
    DATAPATH_GX : entity work.datapathGx
               generic map (8)
               port map (
                   clk => clk,
                   rst => rst,
                   prev_row => input_prev,
                   curr_row => input_curr,
                   next_row => input_next,
                   input_prev  => input_prev(8*(n+3)-1 downto 8*n), --mem_in_rd_data1(23 downto 0),
                   input_curr  => input_curr(8*(n+3)-1 downto 8*n), --mem_in_rd_data2(23 downto 0),
                   input_next  => input_next(8*(n+3)-1 downto 8*n), --mem_in_rd_data3(23 downto 0),
                   sob_coeff1  => "01",
                   sob_coeff2  => "10",
                   result => gx_result(13*(n+1)-1 downto 13*n),  --mem_out_wr_data(8*(n+1)-1 downto 8*n),				   
                   vld_in => datapath_valid_in,  --data_vld_addr_gen, 
                   vld_out => mag_en(n), 
                   out_prev_row => out_prev_row,
                   out_curr_row => out_curr_row,
                   out_next_row => out_next_row
                   );
  end generate LOOP_UNROLL1;
    ------------------------------------------------------------------------------            
    LOOP_UNROLL2: for n in 3 downto 0 generate           
      DATAPATH_GY : entity work.datapath_gy
                 generic map (8)
                 port map (
                     clk => clk,
                     rst => rst,
                     input_prev  => input_prev(8*(n+3)-1 downto 8*n),
                     input_next  => input_next(8*(n+3)-1 downto 8*n),
                     sob_coeff1  => "01",
                     sob_coeff2  => "10",
                     result => gy_result(13*(n+1)-1 downto 13*n),  --mem_out_wr_data(8*(n+1)-1 downto 8*n),                   
                     vld_in => datapath_valid_in,
                     vld_out => open  
                     );
    end generate LOOP_UNROLL2;  
						
	U_MAG : entity work.datapath
			generic map(width => 13)
			port map(
				clk 	=> clk,
				rst 	=> rst,
				out_prev_row => out_prev_row,
				out_curr_row => out_curr_row,
                out_next_row => out_next_row,
                gx1 	=> gx_result(51 downto 39),
				gx2 	=> gx_result(38 downto 26),
				gx3 	=> gx_result(25 downto 13),
				gx4 	=> gx_result(12 downto 0),
				gy1 	=> gy_result(51 downto 39),
				gy2 	=> gy_result(38 downto 26),
				gy3 	=> gy_result(25 downto 13),
				gy4 	=> gy_result(12 downto 0),
				vld_in  => mag_en(0),
				vld_out => buffer_en,
				mag     => mag_result,
				th_input_prev => th_input_prev,
                th_input_curr => th_input_curr,
                th_input_next => th_input_next				
				);
		
--	U_MAG_BUFFER : entity work.gxgyBuffer
--                      generic map (width => 60*C_COLUMN_COUNT, inputWidth => 60)
--                      port map (
--                        clk 		=> clk,
--                        rst 		=> rst,
--                        en  		=> buffer_en,
--                        row_count 	=> row_count,
--                        input 		=> mag_result,
--                        output_prev => mag_prev,
--                        output_curr => mag_curr, 
--                        output_next => mag_next,
--                        vld_out 	=> mag_valid
--                        );	
					
--    ------------------------------------------------------------------------------
--    U_GX_PREV_ROW_SMART_BUFFER : entity work.smart_buff
--                                 generic map (
--                                   width => 60,
--                                   outputWidth => 90)
--                                 port map (
--                                   clk => clk,
--                                   rst => rst,
--                                   en  => mag_valid,
--                                   input => mag_prev,
--                                   output => th_input_prev
--                                   );
--    ------------------------------------------------------------------------------
--    U_GX_CURR_ROW_SMART_BUFFER : entity work.smart_buff_v
--                              generic map (
--                                width => 60,
--                                outputWidth => 90)
--                              port map (
--                                clk => clk,
--                                rst => rst,
--                                en  => mag_valid,
--                                input => mag_curr,
--                                valid => th_valid,
--                                output => th_input_curr
--                                );
--    ------------------------------------------------------------------------------
--    U_GX_NEXT_ROW_SMART_BUFFER : entity work.smart_buff
--                                 generic map (
--                                 width => 60,
--                                 outputWidth => 90)
--                                 port map (
--                                 clk => clk,
--                                 rst => rst,
--                                 en  => mag_valid,
--                                 input => mag_next,
--                                 output => th_input_next
--                                 );
--    ------------------------------------------------------------------------------  
    
				
		LOOP_UNROLL_THRESH: for n in 3 downto 0 generate		
				THRESHOLD_COMPARATOR : entity work.datapath_threshold
							generic map (15)
							port map(
								clk         => clk,
								rst         => rst,
								mag         => mag_result(15*(n+1) - 1 downto 15*n),
								input_prev  => th_input_prev(15*(n+3)-1 downto 15*n),
								input_curr  => th_input_curr(15*(n+3)-1 downto 15*n),
								input_next  => th_input_next(15*(n+3)-1 downto 15*n),
								vld_in      => buffer_en,
								vld_out		=> mem_out_wr_en(n),
								result      => mem_out_wr_data(8*(n+1)-1 downto 8*n)
								);
				end generate LOOP_UNROLL_THRESH;				
								
								

      ------------------------------------------------------------------------------            
    U_OP_ADD_GEN : entity work.op_address_generator
                port map (
                    clk => clk,
                    rst => rst,
                    en  => mem_out_wr_en(0), 
                    add_out => mem_out_wr_addr,
					endstream => rslt_rdy
                    );
                                    			
end default;
