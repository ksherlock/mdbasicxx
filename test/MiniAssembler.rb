require_relative '../lib/MiniAssembler'
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

	def test_assemble
		m = MiniAssembler::new
		m.process(" .org 300")
		m.process(" .machine 65816")
		m.process(" .long m")
		m.process(" .export start")
		m.process("start")
		m.process(" lda #0")
		m.process(" rts")


		data = []
		st = {}
		m.finish(data, st)

		assert_equal(st, {:start => 300 })
		assert_equal(data, ["DATA 169,0,0,96"])
	end

	def test_unary
		m = MiniAssembler::new
		m.process(" lda #+5")
		m.process(" lda #-5")
		m.process(" lda #~5")
		m.process(" lda #^5")

		data = []
		st = {}
		m.finish(data, st)

		assert_equal(data, ["DATA 169,5,169,251,169,250,169,0"])

	end

	def test_binary
		m = MiniAssembler::new
		m.process(" lda #3+5")
		m.process(" lda #3-5")
		m.process(" lda #3*5")
		m.process(" lda #3/5")
		m.process(" lda #3%5")
		m.process(" lda #3&5")
		m.process(" lda #3|5")
		m.process(" lda #3>>1")
		m.process(" lda #3<<1")

		data = []
		st = {}
		m.finish(data, st)

		assert_equal(data, ["DATA 169,8,169,254,169,15,169,0,169,3,169,1,169,7,169,1,169,6"])

	end



end
