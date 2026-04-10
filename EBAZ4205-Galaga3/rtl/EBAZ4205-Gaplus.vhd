---------------------------------------------------------------------------------
--                           Galaga3 - EBAZ4205
--                           Code from MiSTer-X
--
--                         Modified for EBAZ4205 
--                            by pinballwiz.org 
--                               27/03/2026
---------------------------------------------------------------------------------
-- Keyboard inputs :
--   5 : Add coin
--   2 : Start 2 players
--   1 : Start 1 player
--   LEFT Ctrl   : Fire
--   RIGHT arrow : Move Right
--   LEFT arrow  : Move Left
--   UP arrow    : Move Up
--   DOWN arrow  : Move Down
---------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.ALL;
use ieee.numeric_std.all;
---------------------------------------------------------------------------------
entity gaplus_ebaz4205 is
port(
	clock_50    : in std_logic;
   	I_RESET     : in std_logic; -- pulled up
	O_VIDEO_R	: out std_logic_vector(2 downto 0); 
	O_VIDEO_G	: out std_logic_vector(2 downto 0);
	O_VIDEO_B	: out std_logic_vector(1 downto 0);
	O_HSYNC		: out std_logic;
	O_VSYNC		: out std_logic;
	O_AUDIO_L 	: out std_logic;
	O_AUDIO_R 	: out std_logic;
	greenLED 	: out std_logic;
	redLED 	    : out std_logic;
   	ps2_clk     : in std_logic;
	ps2_dat     : inout std_logic;
	led         : out std_logic_vector(7 downto 0)
);
end gaplus_ebaz4205;
------------------------------------------------------------------------------
architecture struct of gaplus_ebaz4205 is
 
 signal	clock_48        : std_logic;
 signal	clock_24        : std_logic;
 signal	clock_12        : std_logic;
 signal	clock_9         : std_logic;
 --
 signal video_r         : std_logic_vector(5 downto 0);
 signal video_g         : std_logic_vector(5 downto 0);
 signal video_b         : std_logic_vector(5 downto 0);
 --
 signal video_r_i         : std_logic_vector(5 downto 0);
 signal video_g_i         : std_logic_vector(5 downto 0);
 signal video_b_i         : std_logic_vector(5 downto 0);
 --
 signal h_sync          : std_logic;
 signal v_sync	        : std_logic;
 signal hblank          : std_logic;
 signal vblank	        : std_logic;
 signal pclk	        : std_logic;
 --
 signal hpos            : std_logic_vector(8 downto 0);
 signal vpos            : std_logic_vector(8 downto 0);
 signal pout            : std_logic_vector(11 downto 0);
 --
 signal audio           : std_logic_vector(7 downto 0);
 signal audio_pwm       : std_logic;
 --
 signal INP0            : std_logic_vector(4 downto 0);
 signal INP1            : std_logic_vector(4 downto 0);
 signal INP2            : std_logic_vector(2 downto 0);
 --
 signal reset           : std_logic;
 --
 signal kbd_intr        : std_logic;
 signal kbd_scancode    : std_logic_vector(7 downto 0);
 signal joy_BBBBFRLDU   : std_logic_vector(9 downto 0);
  --
 constant CLOCK_FREQ    : integer := 27E6;
 signal counter_clk     : std_logic_vector(25 downto 0);
 signal clock_4hz       : std_logic;
 signal AD              : std_logic_vector(15 downto 0);
---------------------------------------------------------------------------
component gaplus_clocks
port(
  clk_out1          : out    std_logic;
  clk_out2          : out    std_logic;
  clk_in1           : in     std_logic
 );
end component;
---------------------------------------------------------------------------
begin

reset       <= not I_RESET; -- reset active = '1'  
greenLED    <= '1'; -- turn off leds
redLED      <= '1';
---------------------------------------------------------------------------
Clocks: gaplus_clocks
    port map (
        clk_in1   => clock_50,
        clk_out1  => clock_48,
        clk_out2  => clock_9
    );
---------------------------------------------------------------------------
-- Clocks Divide

process (clock_48)
begin
 if rising_edge(clock_48) then
	clock_24  <= not clock_24;
 end if;
end process;
--
process (clock_24)
begin
 if rising_edge(clock_24) then
	clock_12  <= not clock_12;
 end if;
end process;
---------------------------------------------------------------------------
-- Inputs

INP0 <= joy_BBBBFRLDU(4) & joy_BBBBFRLDU(2) & joy_BBBBFRLDU(1) & joy_BBBBFRLDU(3) & joy_BBBBFRLDU(0);
INP1 <= joy_BBBBFRLDU(4) & joy_BBBBFRLDU(2) & joy_BBBBFRLDU(1) & joy_BBBBFRLDU(3) & joy_BBBBFRLDU(0);
INP2 <= joy_BBBBFRLDU(7) & joy_BBBBFRLDU(6) & joy_BBBBFRLDU(5);
---------------------------------------------------------------------------
-- Main

pm : entity work.FPGA_GAPLUS
port map (
RESET => reset,
MCLK  => clock_48,
PH    => hpos,
PV    => vpos,
PCLK  => pclk,
POUT  => pout,
SOUT  => audio,
INP0  => INP0,
INP1  => INP1,
INP2  => INP2,
DSW0  => "00000000",
DSW1  => "00000000", 
DSW2  => "00000011",
AD    => AD
);
----------------------------------------------------------------------------
-- Sync

HVGEN : entity work.hvgen
port map(
	HPOS => hpos,
	VPOS => vpos,
	PCLK => pclk,
	HBLK => hblank,
	VBLK => vblank,
	HSYN => h_sync,
	VSYN => v_sync
);
-----------------------------------------------------------------
video_r_i <= pout(3 downto 0) & pout(3 downto 2) when hblank = '0' and vblank = '0' else "000000";
video_g_i <= pout(7 downto 4) & pout(7 downto 6) when hblank = '0' and vblank = '0' else "000000";
video_b_i <= pout(11 downto 8)& pout(11 downto 10) when hblank = '0' and vblank = '0' else "000000";
-----------------------------------------------------------------
-- scan doubler

dblscan: entity work.scandoubler
	port map(
		clk_sys => clock_24,
		scanlines => "00",
		r_in   => video_r_i,
		g_in   => video_g_i,
		b_in   => video_b_i,
		hs_in  => h_sync,
		vs_in  => v_sync,
		r_out  => video_r,
		g_out  => video_g,
		b_out  => video_b,
		hs_out => O_HSYNC,
		vs_out => O_VSYNC
	);
-----------------------------------------------------------------------------
-- vga output

 O_VIDEO_R  <= video_r(5 downto 3);
 O_VIDEO_G  <= video_g(5 downto 3);
 O_VIDEO_B  <= video_b(5 downto 4);
------------------------------------------------------------------------------
-- get scancode from keyboard

keyboard : entity work.io_ps2_keyboard
port map (
  clk       => clock_9,
  kbd_clk   => ps2_clk,
  kbd_dat   => ps2_dat,
  interrupt => kbd_intr,
  scancode  => kbd_scancode
);
------------------------------------------------------------------------------
-- translate scancode to joystick

joystick : entity work.kbd_joystick
port map (
  clk           => clock_9,
  kbdint        => kbd_intr,
  kbdscancode   => std_logic_vector(kbd_scancode), 
  joy_BBBBFRLDU => joy_BBBBFRLDU 
);
------------------------------------------------------------------------------
-- dac

    dac : entity work.dac
    generic map(
      msbi_g  => 7
    )
    port  map(
      clk_i   => clock_12,
      res_n_i => I_RESET,
      dac_i   => audio,
      dac_o   => audio_pwm
    );

  O_AUDIO_L <= audio_pwm;
  O_AUDIO_R <= audio_pwm;
-------------------------------------------------------------------------------
-- debug

process(reset, clock_24)
begin
  if reset = '1' then
   clock_4hz <= '0';
   counter_clk <= (others => '0');
  else
    if rising_edge(clock_24) then
      if counter_clk = CLOCK_FREQ/8 then
        counter_clk <= (others => '0');
        clock_4hz <= not clock_4hz;
        led(7 downto 0) <= not AD(11 downto 4);
      else
        counter_clk <= counter_clk + 1;
      end if;
    end if;
  end if;
end process;	
-------------------------------------------------------------------------------
end struct;