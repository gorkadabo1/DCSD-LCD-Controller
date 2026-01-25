library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity hex_7seg is
	port
	(
		hex	: in	std_logic_vector(3 downto 0);
		dig	: out	std_logic_vector(6 downto 0)
	);
end hex_7seg;

architecture a of hex_7seg is

	TYPE hex_7Seg_Table_type IS ARRAY (0 TO 15)  OF std_logic_vector(6 DOWNTO 0);
	CONSTANT Conv_hex_to_7Seg : hex_7Seg_Table_type := (
        "1000000", -- "0"
		"1111001", -- "1" 
		"0100100", -- "2" 
		"0110000", -- "3" 
		"0011001", -- "4" 
		"0010010", -- "5" 
		"0000010", -- "6" 
		"1111000", -- "7" 
		"0000000", -- "8" 
		"0010000", -- "9" 
		"0001000", -- "a" 
		"0000011", -- "b" 
		"1000110", -- "c" 
 		"0100001", -- "d" 
 		"0000110", -- "e" 
 		"0001110"  -- "f"       
    );
    
	signal hex_int  :unsigned(3 downto 0);

    begin
    
      hex_int <= unsigned(hex);
      dig <= Conv_hex_to_7Seg(to_integer(hex_int));
    
end architecture a;

-----------------------------------------------------------------------------
--- Ejemplo de uso:
---
---
---signal ContadorN	: natural range 0 to 255;	
---signal ContadorU	: unsigned( 7 downto 0 );
---signal Std_Vector	: std_logic_vector( 7 downto 0 );	
---
--- Con un dato Natural range 0 to 255
---	Std_Vector <= std_logic_vector(to_unsigned(ContadorN, 8 )) ;
---	
--- Con un dato Unsigned ( 7 downto 0 )
---	Std_Vector <= std_logic_vector(ContadorU) ;
---
---HEX_0: hex_7seg
---port map(
---	hex => Std_Vector(3 downto 0),
---	dig => HEX0
---	);
---			
---HEX_1: hex_7seg
---	port map(
---		hex => Std_Vector(7 downto 4),
---		dig => HEX1
---	);
-----------------------------------------------------------------------------
