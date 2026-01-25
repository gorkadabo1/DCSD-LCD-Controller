library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_LCD_DRAWING is
end tb_LCD_DRAWING;

architecture sim of tb_LCD_DRAWING is

component LCD_DRAWING
	port
	(
	   	reset,CLK		: in 	std_logic;
	   	DEL_SCREEN		: in	std_logic;
	   	DRAW_FIG		: in	std_logic;
	   	DRAW_IMAGE		: in	std_logic;
		VIDEO			: in 	std_logic;
		COLOUR_CODE		: in	std_logic_vector(2 downto 0);
		DONE_CURSOR,DONE_COLOUR	: in std_logic;
		Pixel_Rec		: in std_logic;
		Pixel			: in std_logic_vector (15 downto 0);
		OP_SETCURSOR		: out	std_logic;
		XCOL			: out std_logic_vector(7 downto 0);
		YROW			: out std_logic_vector(8 downto 0);
		OP_DRAWCOLOUR		: out	std_logic;
		RGB			: out std_logic_vector(15 downto 0);
		NUMPIX			: out std_logic_vector(16 downto 0);
		PixelACK		: out std_logic
	);
end component;

    signal tb_reset, tb_CLK          : std_logic := '1';
    signal tb_DEL_SCREEN             : std_logic := '0';
    signal tb_DRAW_FIG               : std_logic := '0';
    signal tb_DRAW_IMAGE             : std_logic := '0';
    signal tb_VIDEO		     : std_logic := '0';
    signal tb_COLOUR_CODE            : std_logic_vector(2 downto 0) := (others => '0');
    signal tb_DONE_CURSOR            : std_logic := '0';
    signal tb_DONE_COLOUR            : std_logic := '0';
    signal tb_Pixel_Rec              : std_logic := '0';
    signal tb_Pixel                  : std_logic_vector(15 downto 0);
    signal tb_OP_SETCURSOR           : std_logic;
    signal tb_XCOL                   : std_logic_vector(7 downto 0);
    signal tb_YROW                   : std_logic_vector(8 downto 0);
    signal tb_OP_DRAWCOLOUR          : std_logic;
    signal tb_RGB                    : std_logic_vector(15 downto 0);
    signal tb_NUMPIX                 : std_logic_vector(16 downto 0);
    signal tb_PixelACK               : std_logic;
  

begin
   DUT: LCD_DRAWING
   port map (
	 reset       => tb_reset,
         CLK         => tb_CLK,
         DEL_SCREEN  => tb_DEL_SCREEN,
         DRAW_FIG    => tb_DRAW_FIG,
         DRAW_IMAGE  => tb_DRAW_IMAGE,
	 VIDEO	     => tb_VIDEO,
         COLOUR_CODE => tb_COLOUR_CODE,
         DONE_CURSOR => tb_DONE_CURSOR,
         DONE_COLOUR => tb_DONE_COLOUR,
         Pixel_Rec   => tb_Pixel_Rec,
         Pixel       => tb_Pixel,
         OP_SETCURSOR=> tb_OP_SETCURSOR,
         XCOL        => tb_XCOL,
         YROW        => tb_YROW,
         OP_DRAWCOLOUR=> tb_OP_DRAWCOLOUR,
         RGB         => tb_RGB,
         NUMPIX      => tb_NUMPIX,
         PixelACK    => tb_PixelACK
   );

   tb_CLK <= not tb_CLK after 10 ns;  --periodo de 20ns

   process
     begin

	--BORRAR PANTALLA
	wait for 20 ns;
	  tb_reset <= '0';
	wait for 20 ns;
	  tb_DEL_SCREEN <= '1';
	wait for 20 ns;
	  tb_DEL_SCREEN <= '0';
	wait for 120 ns;
	  tb_DONE_CURSOR <='1';
	wait for 20 ns;
	  tb_DONE_CURSOR <= '0';
	wait for 300 ns; --Pintar todos los pixeles (en realidad la espera es mas larga pero ponemos 300 para hacer las pruebas)
	  tb_DONE_COLOUR <= '1';
	wait for 20 ns;
	  tb_DONE_COLOUR <= '0';
	

	--DIBUJAR LÍNEA
	wait for 20 ns;      
          tb_reset <= '0';
        wait for 20 ns;
	  tb_DRAW_FIG <= '1';
	wait for 20 ns;
	  tb_DRAW_FIG <= '0';
	wait for 120 ns;
	  tb_DONE_CURSOR <= '1';
	wait for 20 ns;
	  tb_DONE_CURSOR <= '0';
	wait for 200 ns;
	  tb_DONE_COLOUR <= '1';
	wait for 20 ns;
	  tb_DONE_COLOUR <= '0';
	wait for 60 ns;           -- A partir de aquí activamos las señales DONE_CURSOR Y DONE_COLOUR ya que aunque realmente no se mantienen
	  tb_DONE_CURSOR <= '1';  -- activos todo el rato debido a las esperas que hay para hacer las operaciónes, así podemos ver que el
	  tb_DONE_COLOUR <= '1';  -- comportaminto de XCOL, YROW y FIN_COL es el correcto.


	--DIBUJAR IMAGEN
	wait for 20 ns;
	   tb_reset <= '0';
	wait for 20 ns;
	   tb_DRAW_IMAGE <= '1';
	wait for 20 ns;
	   tb_DRAW_IMAGE <= '0';
	wait for 120 ns;
	   tb_DONE_CURSOR <= '1';
	wait for 20 ns;
	   tb_DONE_CURSOR <= '0';
	wait for 160 ns;                    -- Esta es la espera correspondiente a que el modulo del UART y el RecPixel 'generen' el pixel
	   tb_Pixel <= "1100101010100101";  -- completo aunque luego la espera será mucho mayor.
	wait for 20 ns;
	   tb_Pixel_Rec <= '1';	  
	wait for 20 ns;
	   tb_Pixel_Rec <= '0';
	wait for 240 ns;
	   tb_DONE_COLOUR <= '1';
	wait for 20 ns;
	   tb_DONE_COLOUR <= '0';
	wait for 40 ns;		   -- A partir de aquí activamos las señales DONE_CURSOR, DONE_COLOUR y Pixel_Rec ya que aunque realmente no
	   tb_DONE_CURSOR <= '1';  -- se mantienen activos todo el rato debido a las esperas que hay para hacer las operaciones, así podemos
	   tb_DONE_COLOUR <= '1';  -- ver que el comportamiento de XCOL, YROW, FIN_COL y FIN_IMG es el correcto
	   tb_Pixel_Rec <= '1';


	--VIDEO
	wait for 20 ns;
	   tb_reset <= '0';
	wait for 20 ns;
	   tb_VIDEO <= '1';
	wait for 140 ns;
	   tb_DONE_CURSOR <= '1';
	wait for 140 ns;
	   tb_DONE_COLOUR <= '1';
     wait;
   end process;
end sim;
