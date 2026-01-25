library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_LCD_CTRL is
end tb_LCD_CTRL;

architecture sim of tb_LCD_CTRL is

    component LCD_CTRL
        port(
            	reset,CLK		: in 	std_logic;
		LCD_INIT_DONE		: in std_logic;
		OP_SETCURSOR		: in	std_logic;
		XCOL			: in std_logic_vector(7 downto 0);
		YROW			: in std_logic_vector(8 downto 0);
		OP_DRAWCOLOUR		: in	std_logic;
		RGB			: in std_logic_vector(15 downto 0);
		NUMPIX			: in std_logic_vector(16 downto 0);
		DONE_CURSOR,DONE_COLOUR	: out std_logic;
		LCD_CS_N,LCD_RS,LCD_WR_N	: out std_logic;
		LCD_DATA		: out std_logic_vector(15 downto 0)
        );
    end component;
    
    signal tb_reset, tb_CLK  :  std_logic := '1';
    signal tb_LCD_INIT_DONE, tb_OP_SETCURSOR, tb_OP_DRAWCOLOUR : std_logic := '0';
    signal tb_XCOL : std_logic_vector(7 downto 0):=(others=>'0');
    signal tb_YROW : std_logic_vector(8 downto 0):=(others=>'0');
    signal tb_RGB : std_logic_vector(15 downto 0):=(others=>'0');
    signal tb_NUMPIX : std_logic_vector(16 downto 0) := (others=>'0');
    signal tb_DONE_CURSOR, tb_DONE_COLOUR  : std_logic;
    signal tb_LCD_CS_N, tb_LCD_RS, tb_LCD_WR_N : std_logic;
    signal tb_LCD_DATA : std_logic_vector(15 downto 0);

begin

 DUT: LCD_CTRL
 port map (
  reset => tb_reset,
  CLK => tb_CLK,
  LCD_INIT_DONE => tb_LCD_INIT_DONE,
  OP_SETCURSOR => tb_OP_SETCURSOR,
  XCOL => tb_XCOL,
  YROW => tb_YROW,
  OP_DRAWCOLOUR => tb_OP_DRAWCOLOUR,
  RGB => tb_RGB,
  NUMPIX => tb_NUMPIX,
  DONE_CURSOR => tb_DONE_CURSOR,
  DONE_COLOUR => tb_DONE_COLOUR,
  LCD_CS_N => tb_LCD_CS_N,
  LCD_RS => tb_LCD_RS,
  LCD_WR_N => tb_LCD_WR_N,
  LCD_DATA => tb_LCD_DATA
  );

  tb_CLK <= not tb_CLK after 10 ns;  --periodo de 20ns

  process
    begin
      wait for 20 ns;      
        tb_reset <= '0';
      wait for 20 ns;    
        tb_LCD_INIT_DONE <= '1';
      wait for 20 ns;  
	tb_OP_SETCURSOR <= '1';
      wait for 20 ns;  
        tb_XCOL <= X"78";
        tb_YROW <= "0" & X"A0";
      wait until tb_DONE_CURSOR = '1';
        wait for 20 ns;
	  tb_OP_SETCURSOR <= '0';
	  tb_OP_DRAWCOLOUR <= '1';
        wait for 20 ns;
	  tb_RGB <= X"001C";
	  tb_NUMPIX <= "00000000000000011";
    wait;
  end process;
end sim;
