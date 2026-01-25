-----------------------------------------------------
--  Phase 1 Project template
--
-------------------------------------------------------
--
-- CLOCK_50 is the system clock.
-- KEY0 is the active-low system reset.
-- LEDR9 is the LT24_Init_Done signal
-- 
---------------------------------------------------------------
-- Version: V1.0  
---       Basic Vhdl layout with the definitions of the 
--        LT24Setup, LCD_CTRL, and LCD_DRAWING components, 
--        and an instance of the LT24Setup component.
--
---------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity DE1SOC_LCDLT24_v1 is
 port(
    -- CLOCK ----------------
    CLOCK_50: in  std_logic;
    -- KEY ----------------
    KEY     : in  std_logic_vector(3 downto 0);
    -- SW ----------------
    SW      : in  std_logic_vector(9 downto 0);
    -- LEDR ----------------
    LEDR    : out std_logic_vector(9 downto 0);
    -- LT24_LCD ----------------
    LT24_LCD_ON     : out std_logic;
    LT24_RESET_N    : out std_logic;
    LT24_CS_N       : out std_logic;
    LT24_RD_N       : out std_logic;
    LT24_RS         : out std_logic;
    LT24_WR_N       : out std_logic;
    LT24_D          : out   std_logic_vector(15 downto 0);

    -- GPIO ----------------
    -- GPIO_0 : inout std_logic_vector(35 downto 0);
    -- UART----------------
     UART_RX : in std_logic;

    -- SEG7 ----------------
    HEX0  : out    std_logic_vector(6 downto 0);
    HEX1  : out    std_logic_vector(6 downto 0);
    HEX2  : out    std_logic_vector(6 downto 0);
    HEX3  : out    std_logic_vector(6 downto 0);
    HEX4  : out    std_logic_vector(6 downto 0);
    HEX5  : out    std_logic_vector(6 downto 0)

 );
end;

architecture ARCH_1 of DE1SOC_LCDLT24_v1 is 
    
    component LT24Setup 
    port (
        -- CLOCK and Reset_l ----------------
        clk            : in      std_logic;
        reset_l        : in      std_logic;

        LT24_LCD_ON      : out std_logic;
        LT24_RESET_N     : out std_logic;
        LT24_CS_N        : out std_logic;
        LT24_RS          : out std_logic;
        LT24_WR_N        : out std_logic;
        LT24_RD_N        : out std_logic;
        LT24_D           : out std_logic_vector(15 downto 0);

        LT24_CS_N_Int        : in std_logic;
        LT24_RS_Int          : in std_logic;
        LT24_WR_N_Int        : in std_logic;
        LT24_RD_N_Int        : in std_logic;
        LT24_D_Int           : in std_logic_vector(15 downto 0);
      
        LT24_Init_Done       : out std_logic
    );
    end component;
  

    component LCD_DRAWING is
    port (
          clk, reset: in std_logic;
          
          DEL_SCREEN:   in std_logic;
          DRAW_FIG:    in std_logic;
			 DRAW_IMAGE:	in std_logic;
			 VIDEO:			in std_logic;
          COLOUR_CODE:  in std_logic_vector(2 downto 0);
          DONE_CURSOR:  in std_logic;
          DONE_COLOUR:  in std_logic;
			 Pixel_Rec		: in std_logic;
			 Pixel			: in std_logic_vector (15 downto 0);
			 
          OP_SETCURSOR: out std_logic;
          XCOL:         out std_logic_vector(7 downto 0);
          YROW:         out std_logic_vector(8 downto 0);
          
          OP_DRAWCOLOUR: out std_logic;
          RGB:           out std_logic_vector(15 downto 0);
          NUMPIX:       out std_logic_vector(16 downto 0);
		    PixelACK		: out std_logic
    );
    end component;


    component LCD_CTRL
    port (
            reset,CLK        : in     std_logic;
            LCD_INIT_DONE    : in std_logic;
            OP_SETCURSOR     : in    std_logic;
            XCOL             : in std_logic_vector(7 downto 0);
            YROW             : in std_logic_vector(8 downto 0);
            OP_DRAWCOLOUR    : in    std_logic;
            RGB              : in std_logic_vector(15 downto 0);
            NUMPIX           : in std_logic_vector(16 downto 0);
				
            DONE_CURSOR, DONE_COLOUR   : out std_logic;
            
				LCD_CS_N, LCD_RS, LCD_WR_N : out std_logic;
            LCD_DATA                   : out std_logic_vector(15 downto 0)
    );
    end component;
	 
	 
	 component UART
	 port (
				reset,CLK			: in std_logic;
				RX						: in std_logic;
				RecACK				: in std_logic;
				DATA					: out std_logic_vector (7 downto 0);
				DATA_READY			: out std_logic
	 );
	 end component;
	 
	 
	 component REC_PIXEL
	 port	(
				reset,CLK	: in std_logic;
				PixelACK	: in std_logic;
				DATA		: in std_logic_vector (7 downto 0);
				DATA_READY	: in std_logic;
				RecACK		: out std_logic;
				Pixel		: out std_logic_vector (15 downto 0);
				Pixel_Rec	: out std_logic
	 );
	 end component;
	 

    component  hex_7seg
    port (
        hex    : in    std_logic_vector(3 downto 0);
        dig    : out    std_logic_vector(6 downto 0)
    );
    end component;

  
    signal clk, reset :  std_logic;
    signal reset_l    :  std_logic;

    signal DONE_CURSOR, DONE_COLOUR      : std_logic;
    signal OP_SETCURSOR, OP_DRAWCOLOUR   :  std_logic;
    signal COL      :  std_logic_vector(7 downto 0);
    signal ROW      :  std_logic_vector(8 downto 0);
    signal RGB      :  std_logic_vector(15 downto 0);
    signal NUMPIX   : std_logic_vector (16 downto 0);
    
    signal  LT24_Init_Done    : std_logic;
    signal  LT24_CS_N_Int     :  std_logic;
    signal  LT24_RS_Int       :  std_logic;
    signal  LT24_WR_N_Int     :  std_logic;
    signal  LT24_RD_N_Int     :  std_logic;
    signal  LT24_D_Int        :  std_logic_vector(15 downto 0);
	 
	 signal Pixel_Rec	: std_logic;
	 signal Pixel		: std_logic_vector(15 downto 0);
	 signal PixelACK	: std_logic;
	 
	 signal RX			: std_logic;
	 signal RecACK		: std_logic;
	 signal DATA		: std_logic_vector(7 downto 0);
	 signal DATA_READY: std_logic;
	 
  
   constant  RED_COLOR    : std_logic_vector(15 downto 0)  := "11111" & "000000" & "00000";
   constant  GREEN_COLOR  : std_logic_vector(15 downto 0)  := "00000" & "111111" & "00000";
   constant  BLUE_COLOR   : std_logic_vector(15 downto 0)  := "00000" & "000000" & "11111";
   constant  WHITE_COLOR  : std_logic_vector(15 downto 0)  := "11111" & "111111" & "11111";
  
  
  constant  NUMPIXELS        : std_logic_vector(16 downto 0)  := "0" & x"A000";
  
begin 
   clk      <= CLOCK_50;
   reset    <= not(KEY(0));
   reset_l  <= KEY(0);
    
   LT24_RD_N_Int  <= '1';
    
-- LT24Setup component instantiation -----------    
   O1_SETUP:LT24Setup 
   port map(
      clk          => clk,
      reset_l      => reset_l,

      LT24_LCD_ON      => LT24_LCD_ON,
      LT24_RESET_N     => LT24_RESET_N,
      LT24_CS_N        => LT24_CS_N,
      LT24_RS          => LT24_RS,
      LT24_WR_N        => LT24_WR_N,
      LT24_RD_N        => LT24_RD_N,
      LT24_D           => LT24_D,

      LT24_CS_N_Int       => LT24_CS_N_Int,
      LT24_RS_Int         => LT24_RS_Int,
      LT24_WR_N_Int       => LT24_WR_N_Int,
      LT24_RD_N_Int       => LT24_RD_N_Int,
      LT24_D_Int          => LT24_D_Int,
      
      LT24_Init_Done      => LT24_Init_Done
   );
   
   LEDR(9)  <= LT24_Init_Done;

   LEDR(6)  <= not(KEY(3));   -- OP_SETCURSOR
   LEDR(5)  <= not(KEY(2));   -- OP_DRAWCOLOUR


   LEDR(1)  <= DONE_CURSOR;
   LEDR(0)  <= DONE_COLOUR;
      
   --  Not Used I/O Pins (to avoid compiler warnings) ------
   --LEDR(2)  <= not(KEY(1)) or SW(2); LEDR(3)  <= SW(3) or SW(4);  
	LEDR(2)  <= DATA_READY;
	LEDR(4)  <= SW(5) or SW(6);  
   LEDR(7)  <= SW(7) or SW(8);  LEDR(8)  <= SW(9);
   ---------------------------------------------------------

   
 -- LCD_CTRL component instantiation -----------    
  O2_LCDCONT: LCD_CTRL
   port map (
      CLK     => clk,
      reset   => reset,
      LCD_INIT_DONE  => LT24_Init_Done,    
      
      OP_SETCURSOR   => OP_SETCURSOR ,
      XCOL   => COL,            -- "00111111",
      YROW   => ROW,            -- "001111111",
      
      OP_DRAWCOLOUR  => OP_DRAWCOLOUR,
      RGB            => RGB,    
      NUMPIX         => NUMPIX,       --- "0" & x"A000",
      
      DONE_CURSOR    => DONE_CURSOR,
      DONE_COLOUR    => DONE_COLOUR,
      
      LCD_CS_N  => LT24_CS_N_Int,
      LCD_RS    => LT24_RS_Int,
      LCD_WR_N  => LT24_WR_N_Int,
      LCD_DATA  => LT24_D_Int
   );

    
			 
 -- LCD_DRAWING component instantiation -----------    
   O3_LCDDRAW: LCD_DRAWING
   port map (
      reset => reset,
      CLK   => clk,
        
      DEL_SCREEN   => not(KEY(2)),
      DRAW_FIG     => not(KEY(3) and not(SW(9))),
      DRAW_IMAGE	 => not(KEY(1)),
		VIDEO        => not(KEY(3) and SW(9)), 
		
      COLOUR_CODE  => SW(2 downto 0),
      
      DONE_CURSOR  => DONE_CURSOR,
      DONE_COLOUR  => DONE_COLOUR,
      
		Pixel_Rec	 => Pixel_Rec,
		Pixel			 => Pixel,
		
      OP_SETCURSOR => OP_SETCURSOR,
      XCOL => COL,
      YROW => ROW,
        
      OP_DRAWCOLOUR => OP_DRAWCOLOUR,
      RGB           => RGB,
      NUMPIX       => NUMPIX,
		PixelACK		=> PixelACK
   );



	-- UART component instantiation -----------    
   O4_UART: UART
   port map (
      reset => reset,
      CLK   => clk,
        
      RX		=>		UART_RX,
		RecACK	=>	RecACK,
		DATA		=>	DATA,
		DATA_READY	=> DATA_READY
   );
	
	
	
	-- REC_PIXEL component instantiation -----------    
   O5_REC_PIXEL: REC_PIXEL
   port map (
      reset => reset,
      CLK   => clk,
        
      PixelACK		=> PixelACK,
		DATA		=> DATA,
		DATA_READY	=> DATA_READY,	
		RecACK	=> RecACK,
		Pixel		=>	Pixel,
		Pixel_Rec	=> Pixel_Rec
   );



	-- hex_7seg component instantiation -----------    
	-- Colour Code
   O8_DUT_HEX0_7_SEG: hex_7seg
   port map (
 
      -- IN       
      hex     => "0" &  SW(2 downto 0), 
      -- OUT
      dig     => HEX0
   );

	-- Column bits 3...0
   O8_DUT_HEX1_7_SEG: hex_7seg
   port map (
 
      -- IN       
      hex     => COL(3 downto 0), 
      -- OUT
      dig     => HEX1
   );

	-- Column bits  7...4
   O8_DUT_HEX2_7_SEG: hex_7seg
   port map (
 
      -- IN       
      hex     => COL(7 downto 4), 
      -- OUT
      dig     => HEX2
   );

	-- Row bits  3...0
   O8_DUT_HEX3_7_SEG: hex_7seg
   port map (
 
      -- IN       
      hex     => ROW(3 downto 0), 
      -- OUT
      dig     => HEX3
   );

	-- Row bits  7...4
   O8_DUT_HEX4_7_SEG: hex_7seg
   port map (
 
      -- IN       
      hex     => ROW(7 downto 4), 
      -- OUT
      dig     => HEX4
   );

	-- Row bit  8
   O8_DUT_HEX5_7_SEG: hex_7seg
   port map (
 
      -- IN       
      hex     => "000" & ROW(8), 
      -- OUT
      dig     => HEX5
   );

  
END ARCH_1;
