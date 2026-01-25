library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_REC_PIXEL is
end tb_REC_PIXEL;

architecture sim of tb_REC_PIXEL is

component REC_PIXEL
	port
	(
		reset,CLK	: in std_logic;
		PixelACK	: in std_logic;
		DATA		: in std_logic_vector (7 downto 0);
		DATA_READY	: in std_logic;
		RecACK		: out std_logic;
		Pixel		: out std_logic_vector (15 downto 0);
		Pixel_Rec	: out std_logic
	);
end component;

	signal tb_reset, tb_CLK       : std_logic := '1';
    	signal tb_PixelACK            : std_logic := '0';
   	signal tb_DATA                : std_logic_vector (7 downto 0);
   	signal tb_DATA_READY          : std_logic := '0';
    	signal tb_RecACK              : std_logic;
    	signal tb_Pixel               : std_logic_vector (15 downto 0);
    	signal tb_Pixel_Rec           : std_logic;

begin
        DUT: REC_PIXEL
        port map (
            reset       => tb_reset,
            CLK         => tb_CLK,
            PixelACK    => tb_PixelACK,
            DATA        => tb_DATA,
            DATA_READY  => tb_DATA_READY,
            RecACK      => tb_RecACK,
            Pixel       => tb_Pixel,
            Pixel_Rec   => tb_Pixel_Rec
        );

	tb_CLK <= not tb_CLK after 10 ns;  --periodo de 20ns
process
    begin
	wait for 20 ns;   
	   tb_DATA <= "11001010"; 
           tb_reset <= '0';
        wait for 40 ns;
	   tb_DATA_READY <= '1';
	wait for 60 ns; --DATA_READY se mantiene activo durante 3 ciclos según la unidad de control de módulo UART.
	   tb_DATA_READY <= '0';
	wait for 180 ns;
	   tb_DATA <= "10100101";
	wait for 200 ns; --En realidad, habría que esperar mucho mas para que se reciban los nuevos 8 bits, pero así es mas sencillo de ver.
	   tb_DATA_READY <= '1';
	wait for 40 ns;
	   tb_PixelACK<='1';
	wait for 20 ns; --PixelACK se activará 1 ciclo.
	   tb_PixelACK<='0';
	   tb_DATA_READY <= '0';
	wait;
    end process;
end sim;