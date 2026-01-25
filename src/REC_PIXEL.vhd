library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity REC_PIXEL IS
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
end REC_PIXEL;



architecture ARCH_REC_PIXEL of REC_PIXEL is

	type state is (E0,E1,E2,E3,E4,E5);
	signal EP,ES: state;	
	signal LD_DATA1, LD_DATA2 : std_logic;
	signal R_DATA1 : std_logic_vector (7 downto 0);
	signal R_DATA2 : std_logic_vector (7 downto 0);
	
begin

  	-------------------------------------------------------------------------------------------
	-- CONTROL UNIT
	-------------------------------------------------------------------------------------------
	--
	-- Current state Register (State Machine)
	process (CLK, reset)
	begin
		if reset = '1' then EP <= E0;
	  	elsif (CLK'EVENT) and (CLK ='1') then EP <= ES ;
		end if;
	end process;

	-- Next state generation logic
	process (EP, DATA_READY, PixelACK)
	begin
  		case EP is
			when E0 =>	if (DATA_READY='0') then ES <= E0;
					else ES <= E1;
					end if;

			when E1 =>	ES <= E2;

			when E2 =>	if (DATA_READY='1') then ES <= E2;
					else ES <= E3;
					end if;

			when E3 =>	if (DATA_READY='1') then ES <= E4;
					else ES <= E3;
					end if;

			when E4 =>	ES <= E5;

			when E5 =>	if (PixelACK='1') then ES <= E0;
					else ES <= E5;
					end if;

			when others => ES <= E0;
  		end case;
	end process;

	-- Control signals generation logic
	LD_DATA1 <= '1' when (EP=E1) else '0';
	LD_DATA2 <= '1' when (EP=E4) else '0';
	RecACK <= '1' when (EP=E1 or EP=E4) else '0';
	Pixel_Rec <= '1' when (EP=E4) else '0';

	-------------------------------------------------------------------------------------------
	-- PROCESS UNIT
	-------------------------------------------------------------------------------------------
	

	--Registro 1
	process(CLK,reset)
	begin
	if (reset='1') then R_DATA1<=(others=>'0'); 
   	elsif (CLK'event and CLK='1') then 
	     	if (LD_DATA1='1') then R_DATA1<=DATA; 
         	end if;
	end if;		  
	end process;


	--Registro 2
	process(CLK,reset)
	begin
	if (reset='1') then R_DATA2<=(others=>'0');
   	elsif (CLK'event and CLK='1') then 
	     	if (LD_DATA2='1') then R_DATA2<=DATA; 
         	end if;
	end if;		  
	end process;

	Pixel <= R_DATA1&R_DATA2;	
	
	-------------------------------------------------------------------------------------------

end ARCH_REC_PIXEL;
