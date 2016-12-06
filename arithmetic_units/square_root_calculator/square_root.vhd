library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity square_root is
	generic(
		word_length : integer := 32
	);

	port(
		--inputs
		clk      : in  std_logic;
		rst      : in  std_logic;
		num_in   : in  std_logic_vector(word_length - 1 downto 0);
		valid_in : in  std_logic;
		--outputs
		num_out  : out std_logic_vector(word_length - 1 downto 0);
		valid_out     : out std_logic
	);
end entity square_root;

architecture RTL of square_root is
	--only works for even resolutions.
	constant iterations_no : integer                                    := word_length / 2;
	constant MASK_INIT     : std_logic_vector(word_length - 1 downto 0) := (word_length - 2 => '1', others => '0');

	type temp_type is array (0 to iterations_no) of std_logic_vector(word_length - 1 downto 0);
	signal mask      : temp_type;
	signal remainder : temp_type := (others => (others => '0'));
	signal root      : temp_type := (others => (others => '0'));
	signal delay     : std_logic_vector(0 to iterations_no);

begin
	mask_init_inst : process(mask) is
	begin
		for i in 0 to iterations_no loop
			case i is
				when 0 =>
					mask(0) <= MASK_INIT;
				when 1 to iterations_no =>
					mask(i) <= std_logic_vector(shift_right(unsigned(mask(i - 1)), 2));
				when others => null;
			end case;

		end loop;

	end process mask_init_inst;

	name : process(clk) is
		variable sum : temp_type := (others => (others => '0'));
		variable temp : temp_type :=(others => (others => '0'));
	begin
		if rising_edge(clk) then
			if rst = '1' then
				remainder <= (others => (others => '0'));
				root      <= (others => (others => '0'));
				delay     <= (others => '0');

			else
				for i in 0 to iterations_no loop
					case i is
						when 0 =>
							delay(0) <= valid_in;
							root(0) <= (others  =>  '0');
							remainder(0)  <=  (others => '0');
							
							if (valid_in = '1') then
								remainder(0) <= num_in;
							end if;

						when 1 to iterations_no =>
							delay(i) <= delay(i - 1);
							sum(i)   := std_logic_vector(unsigned(root(i - 1)) + unsigned(mask(i - 1)));
							temp(i):=root(i-1);
							if (unsigned(sum(i)) <= unsigned(remainder(i - 1))) then
								remainder(i) <= std_logic_vector(unsigned(remainder(i - 1)) - (unsigned(sum(i))));
								temp(i):=  std_logic_vector( unsigned( temp(i) ) + shift_left( unsigned(mask(i - 1)),1));
							else
								remainder(i) <= remainder(i-1);
								end if;
							
								root(i) <= std_logic_vector(shift_right(unsigned(temp(i)), 1));
						when others => null;
					end case;

				end loop;

			end if;
		end if;
	end process name;

	num_out <= root(iterations_no);
	valid_out    <= delay(iterations_no);

end architecture RTL;
		                                    
		                                    
