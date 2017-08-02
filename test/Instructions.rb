require_relative '../Instructions'
require 'test/unit'

class TestInstruction < Test::Unit::TestCase

	def test_lookup
		assert_equal(
			Instructions.lookup(:xba, :implied, true, 2),
			{:m => false, :x => false, :mnemonic => :xba, :mode => :implied, :opcode => 0xeb, :size => 0 }
		)

		assert_raise {
			Instructions.lookup(:xba, :implied, true, 1)
		}

		assert_raise {
			Instructions.lookup(:xba, :implied, true, 0)
		}


		assert_equal(
			Instructions.lookup(:bra, :absolute, false, 2),
			{:m => false, :x => false, :mnemonic => :bra, :mode => :relative, :opcode => 0x80, :size => 1 }
		)

	end

end