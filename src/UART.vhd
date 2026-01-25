library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity UART IS
	port
	(
		reset,CLK	: in std_logic;
		RX		: in std_logic;
		RecACK		: in std_logic;
		DATA		: out std_logic_vector (7 downto 0);
		DATA_READY	: out std_logic
	);
end UART;



architecture ARCH_UART of UART is

	type state is (E0,E1,E2,E3,E4,E5,E6,E7);
	signal EP,ES: state;	
	signal LD_CONT, LD_WAIT, LD_REST: std_logic;
	signal E_CONT, E_WAIT, E_REST: std_logic;
	signal SEL_REST : std_logic;
	signal DESP : std_logic_vector(1 downto 0);
	signal DATA_internal: std_logic_vector (7 downto 0) := (others => '0');
	signal DATA_READY_internal : std_logic;
	signal FIN_WAIT : std_logic;
	signal Q_COUNT : std_logic_vector (3 downto 0);
	signal Q_WAIT : std_logic_vector (8 downto 0);
	signal Q_REST : std_logic_vector (8 downto 0);
	
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
	process (EP, RX, DATA_READY_internal, FIN_WAIT, RecACK)
	begin
  		case EP is
			when E0 =>	if (RX='1') then ES <= E0;
					else ES <= E1;
					end if;

			when E1 =>	if (DATA_READY_internal='1') then 
						if (RecACK='1') then ES <= E6;
						else ES <= E5;
						end if;
					else 
						if (FIN_WAIT='0') then ES <= E2;
						else ES <= E3;
						end if;
					end if;

			when E2 =>	if (FIN_WAIT='1') then ES <= E3;
					else ES <= E2;
					end if;

			when E3 =>	ES <= E4;

			when E4 =>	if (DATA_READY_internal='1') then
						if (RecACK='1') then ES <= E6;
						else ES <= E5;
						end if;
					else
						if (FIN_WAIT='0') then ES <= E2;
						else ES <= E3;
						end if;
					end if;

			when E5 =>	if (RecACK='1') then ES <= E6;
					else ES <= E5;
					end if;

			when E6 =>	ES <= E7;

			when E7 =>	if (FIN_WAIT='0') then ES <= E7;
					else ES <= E0;
					end if;

			when others =>  ES <= E0;
  		end case;
	end process;
	

	-- Control signals generation logic
	LD_CONT <= '1' when (EP=E1 or EP=E6) else '0';
	LD_WAIT <= '1' when (EP=E0 or EP=E3 or EP=E6) else '0';
	LD_REST <= '1' when (EP=E1) else '0';
	DESP <= "11" when EP = E1 else
                "01" when EP = E3 else
                "00";
	E_CONT <= '1' when (EP=E3) else '0';
	E_WAIT <= '1' when (EP=E2 or EP=E7) else '0';
	E_REST <= '1' when (EP=E5) else '0';
	SEL_REST <= '1' when (EP=E6) else '0';


	-------------------------------------------------------------------------------------------
	-- PROCESS UNIT
	-------------------------------------------------------------------------------------------
	

	--Registro de desplazamiento
	process (CLK, RESET)
    	begin
		if (reset='1') then DATA_internal <= (others => '0');
       	 	elsif (CLK'event and CLK='1') then
			case DESP is
				when "00" => 
                   			DATA_internal <= DATA_internal;
                		when "01" => 
                    			DATA_internal <= DATA_internal(6 downto 0) & RX;
                		when "10" => 
                    			DATA_Internal <= RX & DATA_Internal(7 downto 1);
                		when others => -- when "11"
                    			DATA_internal <= (others => '0');
            		end case;
        	end if;
    	end process;

	DATA <= DATA_internal;


	--Contador de bits recibidos
	process(CLK,reset)
	begin
		if (reset='1') then Q_COUNT <= "1000";
   		elsif (CLK'event and CLK='1') then 
	     		if (LD_CONT='1') then Q_COUNT <= "1000";
           		elsif (E_CONT='1') then Q_COUNT <= std_logic_vector(unsigned(Q_COUNT) - 1);
			end if;
		end if;		  
	end process;
	DATA_READY_internal <= '1' when Q_COUNT="0000" else '0';
	DATA_READY <= DATA_READY_internal;

	--Contador de espera de ciclos
	process(CLK,reset)
	begin
		if (reset='1') then Q_WAIT <= (others=>'0');
   	elsif (CLK'event and CLK='1') then 
	     	if (LD_WAIT='1') then 
				if (SEL_REST = '0') then Q_WAIT <= "110110010"; -- 435 en binario
            else Q_WAIT <= std_logic_vector("110110011" - unsigned(Q_REST)); -- 435 - Q_REST
            end if;
           elsif (E_WAIT='1') then Q_WAIT <= std_logic_vector(unsigned(Q_WAIT) - 1);
           end if;
		end if;		  
	end process;
	FIN_WAIT <= '1' when Q_WAIT= "000000000" else '0';


	--Contador de Ciclos tardados esperando el RecACK
	process(CLK,reset)
	begin
		if (reset='1') then Q_REST <= (others=>'0');
   		elsif (CLK'event and CLK='1') then 
	     		if (LD_REST='1') then Q_REST <= (others=>'0');
           		elsif (E_REST='1') then Q_REST <= std_logic_vector(unsigned(Q_REST) + 1);
           		end if;
		end if;		  
	end process;

	-------------------------------------------------------------------------------------------

end  ARCH_UART;
