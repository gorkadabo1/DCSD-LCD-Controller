library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity LCD_DRAWING IS
	port
	(
		reset,CLK		: in 	std_logic;
		DEL_SCREEN		: in	std_logic;
		DRAW_FIG		: in	std_logic;
		DRAW_IMAGE		: in	std_logic;
		VIDEO			: in	std_logic;
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
end LCD_DRAWING;

architecture ARCH_LCD_DRAWING of LCD_DRAWING is

	type state is (E0,E1,E2,E3,E4,E5,E6,E7,E8,E9,E10,E11,E12,E13,E14,E15,E16,E17,E18,E19,E20,E21,E22,E23,E24,E25,E26,E27,E28);
	signal EP,ES: state;
	
	signal LD_X,LD_Y,LD_NUMPIX,LD_RGB,LD_HEIGHT,LD_WAITFPS,LD_FRAME : std_logic;
	signal E_DRAWX,E_DRAWY,E_HEIGHT,E_WAITFPS,E_FRAME : std_logic;
	signal XCOL_internal : std_logic_vector(7 downto 0);
	signal YROW_internal : std_logic_vector(8 downto 0);
	signal Q_FRAME : std_logic_vector(1 downto 0);
	signal FIN_COL,FIN_IMG,FIN_HEIGHT,FIN_FPS : std_logic;
	signal SEL_NUMPIX,SEL_UART,SEL_FPS_X: std_logic_vector(1 downto 0);
	signal SEL_FPS_Y: std_logic;
	signal NUMPIX_internal : std_logic_vector(16 downto 0);
	signal RCOLOUR_CODE: std_logic_vector(2 downto 0);
	signal Q_HEIGHT : std_logic_vector(6 downto 0);
	signal Q_FPS : std_logic_vector(19 downto 0);
	

	
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
	process (EP,DEL_SCREEN, DRAW_FIG, DRAW_IMAGE, VIDEO, Pixel_Rec, DONE_CURSOR, DONE_COLOUR, FIN_COL, FIN_IMG, Q_FRAME, FIN_HEIGHT, FIN_FPS)
	begin
  		case EP is
			when E0 =>	if (DEL_SCREEN='0') then
						if(DRAW_FIG='0') then
							if (DRAW_IMAGE='0') then
								if(VIDEO='0') then ES <= E0;
								else ES <= E16;
								end if;
							else ES <= E8;
							end if;
						else ES <= E4;
						end if;
					else ES <= E1;
					end if;

			when E1 => ES <= E2;

			when E2 =>	if (DONE_CURSOR='0') then ES <= E2;
					else ES <= E3;
					end if;

			when E3 =>	if (DONE_COLOUR='0') then ES <= E3;
					else ES <= E0;
					end if;

			when E4 => ES <= E5;

			when E5 =>	if (DONE_CURSOR='0') then ES <= E5;
					else ES <= E6;
					end if;

			when E6 =>	if (DONE_COLOUR='0') then ES <= E6;
					else ES <= E7;
					end if;

			when E7 =>	if (FIN_COL='0') then ES <= E5;
					else ES <= E0;
					end if;

			when E8 => ES <= E9;

			when E9 =>	if (DONE_CURSOR='0') then ES <= E9;
					else ES <= E10;
					end if;

			when E10 =>	if (Pixel_Rec='0') then ES <= E10;
					else ES <= E11;
					end if;

			when E11 => ES <= E12;

			when E12 => ES <= E13;

			when E13 => 	if (DONE_COLOUR='0') then ES <= E13;
					else ES <= E14;
					end if;

			when E14 => 	if (FIN_COL='1') then 
						if (FIN_IMG='1') then ES <= E0;
						else ES <= E15;
						end if;
					else ES <= E9;
					end if;

			when E15 => ES <= E9;

			when E16 => ES <= E17;

			when E17 => ES <= E18;

			when E18 =>	if (DONE_CURSOR='0') then ES <= E18;
					else ES <= E19;
					end if;

			when E19 =>	if (DONE_COLOUR='0') then ES <= E19;
					else
						if(Q_FRAME="10") then ES <= E20;
						elsif (Q_FRAME="01") then ES <= E21;
						else ES <= E22;
						end if;
					end if;

			when E20 => ES <= E23;

			when E21 => ES <= E23;

			when E22 => ES <= E23;

			when E23 =>	if (DONE_CURSOR='0') then ES <= E23;
					else ES <= E24;
					end if;

			when E24 =>	if (DONE_COLOUR='0') then ES <= E24;
					else ES <= E25;
					end if;

			when E25 =>	if (FIN_HEIGHT='0') then ES <= E26;
					else ES <= E27;
					end if;

			when E26 => ES <= E23;


			when E27 =>	if (FIN_FPS='0') then ES <= E27;
					else ES <= E28;
					end if;

			when E28 => ES <= E17;

			when others => ES <= E0;

		end case;
	end process;
	
	-- Control signals generation logic
	LD_X <= '1' when (EP=E1 or EP=E4 or EP=E8 or EP=E15 or EP=E17 or EP=E20 or EP=E21 or EP=E22 or EP=E26) else '0';
	LD_Y <= '1' when (EP=E1 or EP=E4 or EP=E8 or EP=E17 or EP=E20 or EP=E21 or EP=E22) else '0';
	LD_HEIGHT <= '1' when EP=E17 else '0';
	LD_NUMPIX <= '1' when (EP=E1 or EP=E4 or EP=E8 or EP=E17 or EP=E20 or EP=E21 or EP=E22) else '0';
	LD_WAITFPS <= '1' when EP=E17 else '0';
	LD_FRAME <= '1' when (EP=E16 or EP=E22) else '0';
	LD_RGB <= '1' when (EP=E4 OR EP=E1) else '0';
	SEL_NUMPIX <=   "01" when (EP=E4 or EP=E8) else 
			"10" when (EP=E20 or EP=E22) else
			"11" when EP=E21 else
			"00";
	OP_SETCURSOR <= '1' when (EP=E2 or EP=E5 or EP=E9 or EP=E18 or EP=E23) else '0';
	OP_DRAWCOLOUR <= '1' when (EP=E3 or EP=E6 or EP=E12 or EP=E19 or EP=E24) else '0';
	E_DRAWX <= '1' when (EP=E7 or EP=E14) else '0';
	E_DRAWY <= '1' when (EP=E7 or EP=E15 or EP=E26) else '0';
	PixelACK <= '1' when EP=E11 else '0';
	SEL_UART <= "01" when EP = E13 else 
		    "10" when EP = E19 else
		    "11" when EP = E24  else
		    "00";
	SEL_FPS_X <= "01" when EP=E21 else
		     "10" when EP=E22 else
		     "00";
	SEL_FPS_Y <= '1' when (EP=E20 or EP=E21 or EP=E22) else '0';
	E_HEIGHT <= '1' when EP=E25 else '0';
	E_WAITFPS <= '1' when EP=E27 else '0';
	E_FRAME <= '1' when EP=E28 else '0';
		    
	

	-------------------------------------------------------------------------------------------
	-- PROCESS UNIT
	-------------------------------------------------------------------------------------------
	
	-- XCOL COUNTER
	process(CLK, reset)
	begin
		if (reset = '1') then	XCOL_internal <= (others => '0');
		elsif (CLK'event and CLK = '1') then
			if (LD_X = '1') then 
				if (SEL_FPS_X="00") then XCOL_internal <= (others => '0'); --0
				elsif (SEL_FPS_X="01") then XCOL_internal <= "01010000"; --80
				elsif (SEL_FPS_X="10") then XCOL_internal <= "11001000"; --200
				end if;
			elsif (E_DRAWX = '1') then XCOL_internal <= std_logic_vector(unsigned(XCOL_internal) + 1); -- XCOL <= XCOL +1
            		end if;
    		end if;
	end process;
	FIN_COL <= '1' when XCOL_internal = "11101111" else '0';
	XCOL <= XCOL_internal;



	-- YROW COUNTER
	process(CLK,reset)
	begin
		if (reset='1') then  YROW_internal <= (others => '0');
		elsif (CLK'event and CLK='1') then
			if (LD_Y='1')then 
				if (SEL_FPS_Y='0') then YROW_internal <= (others => '0'); --0
				elsif (SEL_FPS_Y='1') then YROW_internal <= "001111000"; --80
				end if;
			elsif (E_DRAWY='1') then YROW_internal <= std_logic_vector(unsigned(YROW_internal) + 1); 
			end if;
		end if;
	end process;
	YROW <= YROW_internal;
	FIN_IMG <= '1' when (FIN_COL='1' and YROW_internal="100111111") else '0';

	
	-- NUMPIX REGISTER
	process(CLK,reset)
	begin
		if (reset='1') then NUMPIX_internal <= (others => '0');
		elsif (CLK'event and CLK='1') then 
			if (LD_NUMPIX='1') then 
				if (SEL_NUMPIX="00") then NUMPIX_internal <= "10010110000000000"; --76800 pixeles seguidos
				elsif (SEL_NUMPIX="01") then NUMPIX_internal <= "00000000000000001"; --1 pixel
				elsif (SEL_NUMPIX="10") then NUMPIX_internal <= "00000000000101000"; --40 pixeles seguidos
				else NUMPIX_internal <= "00000000001010000"; --SEL_NUMPIX=3
				end if;
			end if;
		end if;
	end process;
	NUMPIX <= NUMPIX_internal;

	-- COLOUR CODE REGISTER
	process(CLK,reset)
	begin
		if (reset='1') then RCOLOUR_CODE <= (others => '0');
		elsif (CLK'event and CLK='1') then 
			if (LD_RGB='1') then RCOLOUR_CODE <= COLOUR_CODE;
			end if;
		end if;		
	end process;


	-- RGB MUX
	RGB <=  X"0000" when (SEL_UART="00" and RCOLOUR_CODE="000") else -- NEGRO
      		X"1111" when (SEL_UART="00" and RCOLOUR_CODE="001") else -- BLANCO
      		X"F800" when (SEL_UART="00" and RCOLOUR_CODE="010") else -- ROJO
       		X"07E0" when (SEL_UART="00" and RCOLOUR_CODE="011") else -- VERDE
       		X"001F" when (SEL_UART="00" and RCOLOUR_CODE="100") else -- AZUL
       		X"A145" when (SEL_UART="00" and RCOLOUR_CODE="101") else -- MARRON
       		X"FD40" when (SEL_UART="00" and RCOLOUR_CODE="110") else -- NARANJA
       		X"F819" when (SEL_UART="00" and RCOLOUR_CODE="111") else -- ROSA
       		Pixel when (SEL_UART="01") else
		X"1111" when (SEL_UART="10") else -- BLANCO
		X"0000" when (SEL_UART="11") else -- BLANCO
       		(others => '0');

	
	-- FRAME COUNTER
	process(CLK,reset)
	begin
		if (reset='1') then  Q_FRAME <= (others => '0');
		elsif (CLK'event and CLK='1') then
			if (LD_FRAME='1')then Q_FRAME <=  "10";
			elsif (E_FRAME='1') then Q_FRAME <= std_logic_vector(unsigned(Q_FRAME) - 1); 
			end if;
		end if;
	end process;


	-- HEIGHT COUNTER
	process(CLK,reset)
	begin
		if (reset='1') then  Q_HEIGHT <= (others => '0');
		elsif (CLK'event and CLK='1') then
			if (LD_HEIGHT='1')then Q_HEIGHT <=  "1010000"; --80
			elsif (E_HEIGHT='1') then Q_HEIGHT <= std_logic_vector(unsigned(Q_HEIGHT) - 1); 
			end if;
		end if;
	end process;
	FIN_HEIGHT <= '1' when Q_HEIGHT="0000000" else '0';


	-- FPS COUNTER
	process(CLK,reset)
	begin
		if (reset='1') then  Q_FPS <= (others => '0');
		elsif (CLK'event and CLK='1') then
			if (LD_WAITFPS='1')then Q_FPS <=  "10000000001011001000"; --525000
			elsif (E_WAITFPS='1') then Q_FPS <= std_logic_vector(unsigned(Q_FPS) - 1); 
			end if;
		end if;
	end process;
	FIN_FPS <= '1' when Q_FPS="00000000000000000000" else '0';


end ARCH_LCD_DRAWING;