library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity session3 is
  port( clk_25, vga_vs 	: in std_logic;
		btn, sw			: in std_logic_vector(3 downto 0);
		led 			: out std_logic_vector(3 downto 0);
		xpos_min, xpos_MAX, ypos_min, ypos_MAX : out std_logic_vector(9 downto 0) );
end session3;


architecture lecture of session3 is
  
  -- Unnit Control States
  type state_definition is ( ini, w_b0_b1, ld_count, w_b0, check_b1, w_vs, count, w_vs2);  -- Unnit Control States
  type leds_Status is (off, l_up, l_down);
  -- Led status
  signal state : state_definition;
  signal leds : leds_Status;
  -- Control signals for the up-dawn counters with parallel load.
  signal ld, ce, up : std_logic;
  -- Internal signals of y_position
  signal ymin, ymax : std_logic_vector(9 downto 0);
  
begin
-- Xsignals never change. Better be a constant:
  xpos_min <= "0100000000"; --256
  xpos_MAX <= "0100001111"; --256+15

-- Control Unit.
  process(clk_25) 
  begin
	if (clk_25'event and clk_25='1') then
		case state is
			when ini  => state <= w_b0_b1;
						 leds <= off;
						 up <= '1';
			when w_b0_b1  => if btn(0) ='1' then state <= ld_count;
							 elsif btn(1) = '1' then state <= check_b1;
							 end if;
							 
			when ld_count  => state <= w_b0;
			when w_b0 => if btn(0) = '0' then state <= w_b0_b1;
						end if;
			when check_b1 => if btn(1) = '1' then state <= w_vs;
							else state <= ini;
							end if;
			when w_vs => if vga_vs = '0' then state <= count; end if;
			when count => state <= w_vs2;
						if (up = '1') then leds <= l_up; else leds <= l_down;
						end if;
			when w_vs2 => if vga_vs = '1' then state <= check_b1;
						end if;
						--- update of up	
						if (up = '1') and (ymax >= 480) then up <= '0';
						elsif (up='0') and (ymin = 0) then up <='1';
						end if;
			
		end case;
	end if;
end process;

-- Outputs of the control unit:
ld <= '1' when state = ld_count else '0';
ce <= '1' when state = count else '0';

-- leds status
led <= "0000" when leds = off else
		"1100" when leds = l_up else "0011";
-- Counters for ypos_min and ypos_MAX
process(clk_25)
begin
	--if (btn(3) = '1') then ymin <= "0000000000";ymax <= "0000001111";
	if (clk_25'event and clk_25='1') then
	    if ld = '1' then
			ymin <= "0" & sw & "00000";
			ymax <= "0" & sw & "01111";
		elsif ce = '1' then
			if up = '1' then
				ymax <= ymax +1;
				ymin <= ymin +1;
			else
				ymin <= ymin -1;
				ymax <= ymax -1;
			end if;
		end if;
	end if;
end process;
				
ypos_min <= ymin;
ypos_MAX <= ymax;

end lecture;