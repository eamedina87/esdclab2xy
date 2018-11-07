-- lached 10 bits window comparator.
-- Author: J. Altet. September 2018.

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.STD_LOGIC_ARITH.all;
USE IEEE.STD_LOGIC_UNSIGNED.all;


ENTITY comparator IS

	PORT(cx_min, cx_max, cy_min, cy_max		: IN	STD_LOGIC_VECTOR(9 downto 0); -- 64x64 object position
		 pixel_row, pixel_column			: IN STD_LOGIC_VECTOR(9 DOWNTO 0); -- coming from VGA _SYNC
		 clk_25								: IN STD_LOGIC; 
		 pixel_color : OUT STD_LOGIC_VECTOR(2 downto 0) -- object pixel colr RGB
		 ); -- video memory address counter

END comparator;

ARCHITECTURE a OF comparator IS
	CONSTANT color_object : STD_LOGIC_VECTOR(2 downto 0) := "001"; -- color Blue
	CONSTANT color_background : STD_LOGIC_VECTOR(2 downto 0) := "111"; -- color White
	-- object position mask in 64x64 grid (16x16 pixels)
	SIGNAL plot_square		: STD_LOGIC;
	Signal color_in			: STD_LOGIC_VECTOR(2 downto 0); -- object pixel colr RGB
	

BEGIN

	-- check object coordinates against pixel row/column
	plot_square <= '1' when ((pixel_column >= cx_min) and (pixel_column <= cx_max) AND (pixel_row >= cy_min) and (pixel_row <= cy_max))
	            else '0';
	
		
	color_in <= color_object when plot_square='1'
					else color_background;

					-- Flip flop at the output at the comparator to provide a nice and clean signals to the RGB detector.
	
	
	process(clk_25)
	Begin
		If (clk_25'event and clk_25 = '1') then
			pixel_color <= color_in;
		end if;
	end Process;
	
END architecture a;
