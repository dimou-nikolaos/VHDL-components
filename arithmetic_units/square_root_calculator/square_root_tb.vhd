library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity square_root_tb is
end entity square_root_tb;

architecture RTL of square_root_tb is
	constant period      : time                                       := 5 ns;
	constant word_length : integer                                    := 8;
	--inputs
	signal clk           : std_logic                                  := '0';
	signal rst           : std_logic                                  := '0';
	signal num_in        : std_logic_vector(word_length - 1 downto 0) := (others => '0');
	signal valid_in      : std_logic                                  := '0';
	--outputs
	signal num_out       : std_logic_vector(word_length - 1 downto 0) := (others => '0');
	signal valid_out     : std_logic                                  := '0';

begin
	clk_driver : process
	begin
		clk <= '0';
		wait for period / 2;
		clk <= '1';
		wait for period / 2;
	end process clk_driver;

	square_root_inst : entity work.square_root
		generic map(
			word_length => word_length
		)
		port map(
			clk       => clk,
			rst       => rst,
			num_in    => num_in,
			valid_in  => valid_in,
			num_out   => num_out,
			valid_out => valid_out
		);

	stim : process is
	begin
		rst <= '1';
		wait for 10 * period;
		rst <= '0';
		wait for 10 * period;

		for i in 0 to 128 loop
			num_in   <= std_logic_vector(to_unsigned(i, word_length));
			valid_in <= '1';
			wait for period;
		end loop;

		valid_in <= '0';

		wait;

	end process stim;

end architecture RTL;

