library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_UART is
end tb_UART;

architecture sim of tb_UART is

component UART
	port
        (
		reset,CLK	: in std_logic;
		RX		: in std_logic;
		RecACK		: in std_logic;
		DATA		: out std_logic_vector (7 downto 0);
		DATA_READY	: out std_logic
	);
end component;

        signal tb_reset,tb_CLK	: std_logic:='1';
	signal tb_RX		: std_logic:='1';
	signal tb_RecACK        : std_logic:='0';
	signal tb_DATA		: std_logic_vector (7 downto 0);
	signal tb_DATA_READY	: std_logic;

begin
   DUT: UART
   port map (
	reset       => tb_reset,
        CLK         => tb_CLK,
   	RX          => tb_RX,
        RecACK      => tb_RecACK,
        DATA        => tb_DATA,
	DATA_READY  => tb_DATA_READY
   );

   tb_CLK <= not tb_CLK after 10 ns;  --periodo de 20ns

   process
     begin
	wait for 20 ns;      
           tb_reset <= '0';
        wait for 20 ns;
	   tb_RX<='0';
	wait for 8681 ns;
	   tb_RX<='1';
	wait for 8681 ns;
	   tb_RX<='1';
	wait for 8681 ns;
	   tb_RX<='0';
	wait for 8681 ns;
	   tb_RX<='0';
	wait for 8681 ns;
	   tb_RX<='1';
	wait for 8681 ns;
	   tb_RX<='0';
	wait for 8681 ns;
	   tb_RX<='1';
	wait for 8681 ns;
	   tb_RX<='0';
	wait until tb_DATA_READY = '1';
	   wait for 20 ns;
	   tb_RecACK<='1';
	   wait for 20 ns;
	   tb_RecACK<='0';
	wait for 8661 ns;-- Esta espera no sabemos de cuanto va ser ya que eso lo decidirá el UART.
	   tb_RX<='1';
	wait for 8681 ns;
	   tb_RX<='0';
	wait for 200 ns;
     wait;
   end process;
end sim;
