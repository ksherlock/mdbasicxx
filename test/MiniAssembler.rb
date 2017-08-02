require_relative '../MiniAssembler'
require 'test/unit'

class TestAssembler < Test::Unit::TestCase

	def test_parse_operands
		assert_equal(
			MiniAssembler.expect_block_operand("a,b"),
			{:mode => :block, :explicit => true, :value => [:a, :b]}
		)

		assert_equal(
			MiniAssembler.expect_block_operand("1,2"),
			{:mode => :block, :explicit => true, :value => [1, 2]}
		)

		assert_equal(
			MiniAssembler.expect_operand(nil),
			{:mode => :implied, :explicit => true }
		)

		assert_equal(
			MiniAssembler.expect_operand(""),
			{:mode => :implied, :explicit => true }
		)


		assert_equal(
			MiniAssembler.expect_operand("<0"),
			{:mode => :zp, :explicit => true, :value => 0 }
		)

		assert_equal(
			MiniAssembler.expect_operand("|0"),
			{:mode => :absolute, :explicit => true, :value => 0 }
		)

		assert_equal(
			MiniAssembler.expect_operand(">0"),
			{:mode => :absolute_long, :explicit => true, :value => 0 }
		)


		assert_equal(
			MiniAssembler.expect_operand("<0,x"),
			{:mode => :zp_x, :explicit => true, :value => 0 }
		)

		assert_equal(
			MiniAssembler.expect_operand("|0,x"),
			{:mode => :absolute_x, :explicit => true, :value => 0 }
		)

		assert_equal(
			MiniAssembler.expect_operand(">0,x"),
			{:mode => :absolute_long_x, :explicit => true, :value => 0 }
		)



	end

	def test_parse

		assert_equal(
			MiniAssembler.parse("label"),
			[:label, nil, nil]
		)

		assert_equal(
			MiniAssembler.parse("label ; comment"),
			[:label, nil, nil]
		)


		assert_equal(
			MiniAssembler.parse(" .machine 65816"),
			[nil, :".machine", "65816"]
		)

		assert_equal(
			MiniAssembler.parse("label opcode ; comment"),
			[:label, :opcode, nil]
		)

		assert_equal(
			MiniAssembler.parse("label opcode 'oper;and' ; comment"),
			[:label, :opcode, "'oper;and'"]
		)


	end

	def test_process
		m = MiniAssembler::new
		m.process(" .machine 65816")
		m.process(" .long m")
		m.process(" lda #0")
	end

end