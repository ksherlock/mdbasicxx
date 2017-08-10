
require_relative 'Instructions'
require_relative 'Expression'

class Literal < String
end


class MiniAssembler

	# applesoft has a limit of 236 chars / line. 236/4 = 59.
	CHUNK_SIZE = 50

	M6502 = 0
	M65C02 = 1
	M65816 = 2

	EQU = :'.equ'
	ORG = :'.org'
	MACHINE = :'.machine'
	LONG = :'.long'
	SHORT = :'.short'
	POKE = :'.poke'
	EXPORT = :'.export'
	DB = :'.db'
	DW = :'.dw'
	DA = :'.da'
	DL = :'.dl'

	DCI = :'.dci'
	MSB = :'.msb'

	STR = :'.str'
	PSTR = :'.pstr'

	COLON = :':'
	GT = :'>'
	LT = :'<'
	LPAREN = :'('
	RPAREN = :')'
	LBRACKET = :'['
	RBRACKET = :']'
	PIPE = :'|'
	COMMA = :','
	STAR = :'*'
	POUND = :'#'

	UNARY = [:'+', :'-', :'~', :'^']
	BINARY = [:'+', :'-', :'*', :'/', :'%', :'&', :'|', :'^', :'<<', :'>>']

	PREC = { :'|' => 10,
		:'^' => 9,
		:'&' => 8,
		:'<<' => 5, :'>>' => 5,
		:'+' => 4, :'-' => 4,
		:'*' => 3, :'/' => 3, :'%' => 3,
	}


	def initialize(args = nil)
		reset()
	end

	def reset
		@pc = 0
		@org = 0
		@m = 0
		@x = 0
		@machine = M6502
		@data = []
		@symbols = {}
		@exports = {}
		@patches = []
		@poke = false
		@dci = false
		@msb = false
	end



	def add_label(label, value)

		return unless label && value
		if @symbols.has_key? label && @symbols[label] != value
			raise "Attempt to redefine symbol #{label}"
		end

		@symbols[label] = value

	end


	def process(line)
		line.chomp!

		data = self.class.parse(line)
		return unless data
		label, opcode, operand = data

		@symbols[:'*'] = @pc

		case opcode

		when nil
			# insert a label w/ the current pc.
			add_label(label, @pc)

		when ORG
			raise "org already set" if @pc != @org
			@org = @pc = self.class.expect_number(operand)

		when MACHINE
			@machine = self.class.expect_machine(operand)

		when LONG
			raise "invalid opcode" unless @machine = M65816
			value = self.class.expect_mx(operand)
			@m = true if value.include? ?m
			@x = true if value.include? ?x

		when SHORT
			raise "invalid opcode" unless @machine = M65816
			value = self.class.expect_mx(operand)
			@m = false if value.include? ?m
			@x = false if value.include? ?x

		when POKE
			self.class.expect_nil(operand)
			@poke = true

		when EQU
			value = self.class.expect_number(operand, @symbols)
			add_label(label, value)

			# .export symbol [, ...]
		when EXPORT
			self.class.expect_symbol_list(operand).each {|x|
				@exports[x] = true
			}

		when DB, DW, DA, DL
			add_label(label, @pc) if label

			values = self.class.expect_expr_list(operand)

			size = case opcode
			when DB ; 1
			when DW ; 2
			when DA ; 3
			when DL ; 4
			end

			values.each {|v|
				push_operand( reduce_operand(v), size, :immediate)
				@pc += size
			}

		when DCI
			@dci = self.class.expect_on_off(operand)
		when MSB
			@msb = self.class.expect_on_off(operand)

		when STR, PSTR
			add_label(label, @pc) if label

			_begin = @pc
			if opcode == PSTR
				@data.push(0)
				@pc += 1
			end

			values = self.class.expect_string_list(operand)

			values.each {|x|

				case x
				when String
					bytes = x.bytes
					bytes.map! {|c| (c | 0x80) & 0xff } if @msb
					bytes[-1] ^= 0x80 if @dci && !bytes.empty?

					@data.push(*bytes)
					@pc += bytes.length
				else
					push_operand(reduce_operand(x), 1, :immediate)
					@pc += 1
				end
			}

			_end = @pc
			if opcode === PSTR
				length = _end - _begin - 1
				raise "Pascal string too long" if length > 255
				@data[_begin] = length
			end


		when :mvp, :mvn
			add_label(label, @pc) if label
			do_instruction(opcode, self.class.expect_block_operand(operand))


		else
			add_label(label, @pc) if label
			do_instruction(opcode, self.class.expect_operand(operand))


		end

		return true

	end

	def reduce_operand(value)
		case value
		when Expression ; value.reduce(@symbols)
		when Symbol ; @symbols[value] || value
		when Array
			value.map {|x| reduce_operand(x)}
		else value
		end
	end

	def push_operand(value, size, mode)
		case value
		when Symbol, Expression
			@patches.push( { :pc => @pc, :size => size, :value => value, :mode => mode } )
			size.times { @data.push 0 }
		when Literal
			raise "Literal values not allowed" unless @poke
			raise "Literal values must be 1 byte" unless size == 1
			@data.push value.to_s

		when Integer

			if mode == :relative
				# fudge value...
				value = value - (@pc + size)
				if size == 1
					if value < -128 || value > 127
						raise "relative branch out of range (#{value})"
					end
				end
				value = value & 0xffff
			end

			size.times {
				@data.push value & 0xff
				value >>= 8
			}
		end
	end

	def do_instruction(opcode, operand)

		value = operand[:value]
		mode = operand[:mode]

		# todo -- if mode == :block, value is array of 2 elements.

		value = reduce_operand(value)

		# implicit absolute < 256 -> zp
		if Integer === value && !operand[:explicit]
			if value <= 0xff
				mode = case mode
				when :absolute ; :zp
				when :absolute_x ; :zp_x
				when :absolute_y ; :zp_y
				else ; mode
				end
			end
			if value > 0xffff
				mode = case mode
				when :absolute ; :absolute_long
				when :absolute_x ; :absolute_long_x
				else ; mode
				end
			end
		end


		instr = Instructions.lookup(opcode, mode, operand[:explicit], @machine)

		mode = instr[:mode]
		size = instr[:size]

		@data.push instr[:opcode]
		@pc = @pc + 1

		size = size + 1 if @machine == M65816 && instr[:m] && @m
		size = size + 1 if @machine == M65816 && instr[:x] && @x

		if mode == :block
			push_operand(value[1], 1, :immediate)
			push_operand(value[0], 1, :immediate)
		else
			push_operand(value, size, mode)
		end

		@pc = @pc + size

	end


	def self.parse(line)

		label = nil
		operand = nil
		opcode = nil

		return nil if line.empty?
		return nil if line =~ /^[*;]/


		# remove ; comments...
		re = /
			^
			((?: [^;'"] | "[^"]*" | '[^']*' )*)
			(.*?)
			$
			/x


		if line =~ re
			line = $1.rstrip
			x = $2
			raise "unterminated string" unless x.empty? || x[0] == ?;
		else
			raise "lexical error"
		end

		return nil if line.empty?

		if line =~ /^([A-Za-z_][A-Za-z0-9_]*)/
			label = $1.intern
			line = $' # string after match
		end

		line.lstrip!


		if line =~ /^(\.?[A-Za-z_][A-Za-z0-9_]*)/
			opcode = $1.downcase.intern

			line = $' # string after match
			line.lstrip!
			operand = line unless line.empty?
		end

		return [label, opcode, operand]

	end


	def self.expect_nil(operand)
		return nil if operand.nil?
		raise "bad operand: #{operand}"
	end

	def self.expect_mx(operand)
		return 'mx' if operand.nil? || operand == ''
		operand.downcase!
		return operand.gsub(/[^mx]/, '') if operand =~ /^[mx, ]+$/
		raise "bad operand #{operand}"
	end

	def self.expect_machine(operand)
		case operand.downcase
		when '6502' ; return M6502
		when '65c02' ; return M65C02
		when '65816' ; return M65816
		end
		raise "bad operand #{operand}"
	end

	def self.expect_number(operand, st = nil)
		case operand
		when /^\$([A-Fa-f0-9]+)$/ ; return $1.to_i(16)
		when /^0x([A-Fa-f0-9]+)$/ ; return $1.to_i(16)
		when /^%([01]+)$/ ; return $1.to_i(2)
		when /^[0-9]+$/ ; return operand.to_i(10)


		when /^[A-Za-z_][A-Za-z0-9_]*$/
			if st
				key = operand.downcase.intern
				return st[key] if st.has_key? key
				raise "Undefined symbol #{operand}"
			end

		end
		raise "bad operand #{operand}"
	end

	def self.expect_string(operand)
		case operand
		when /^'([^']+)'$/ ; return $1
		when /^"([^"]+)"$/ ; return $1
		end
		raise "bad operand #{operand}"
	end

	def self.expect_symbol(operand)

		return operand.downcase.intern if operand =~ /^[A-Za-z_][A-Za-z0-9_]*/
		raise "bad operand #{operand}"
	end

	def self.expect_number_list(operand, st = nil)

		return operand.split(',').map { |x| expect_number(x.strip, st) }
	end


	def self.expect_symbol_list(operand)

		return operand.split(',').map {|x| expect_symbol(x.strip) }

		#a = operand.split(',')
		#a.map! { |x| x.strip }

		#raise "bad operand #{operand}" unless a.all? {|x| x =~ /^[A-Za-z_][A-Za-z0-9_]*/ }

		#return a.map { |x| x.downcase.intern }
	end

	def self.expect_expr(operand)
		tt = tokenize(operand).reverse
		e = parse_expr(tt)
		raise "Syntax error" unless tt.empty?
		return e
	end

	def self.expect_expr_list(operand)
		rv = []
		tt = tokenize(operand).reverse

		rv.push parse_expr(tt)

		while !tt.empty?
			raise "Syntax error" unless tt.last == COMMA
			tt.pop
			rv.push parse_expr(tt)
		end
		return rv
	end

	def self.expect_string_list(operand)
		rv = []
		tt = tokenize(operand).reverse


		loop do
			case tt.last
			when String ; rv.push tt.pop
			else rv.push parse_expr(tt)
			end

			break if tt.empty?
			raise "Syntax error" unless tt.last == COMMA
			tt.pop
		end

		return rv
	end



	def self.expect_on_off(operand)
		return case operand
		when /^on$/i ; true
		when /^off$/i ; false
		else ; raise "bad operand #{operand}"
		end
	end


	def self.tokenize(x)

		rv = []
		while !x.empty?
			case x
			when /^(<<|>>)/
				rv.push $1.intern
				x = $'
			when /^([-+#~*,&()<>|\[\]])/
				rv.push $1.intern
				x = $'
			when /^0x([A-Fa-f0-9]+)/
				rv.push($1.to_i(16))
				x = $'
			when /^\$([A-Fa-f0-9]+)/
				rv.push($1.to_i(16))
				x = $'
			when /^([0-9]+)/
				rv.push($1.to_i(10))
				x = $'
			when /^([A-Za-z_][A-Za-z0-9_]*)/
				rv.push($1.downcase.intern)
				x = $'


			# string numeric - cmp #'.'
			when /^'([^']{1,2})'/
				tmp = 0
				$1.each_byte {|c| tmp <<= 8; tmp |= c }
				rv.push(tmp)
				x = $'

			#string
			when /^"([^"]+)"/
				rv.push($1)
				x = $'

			# poke literal - lda #{i} / lda #{peek(0)}
			when /^{([^{}]+)}/
				rv.push Literal.new($1)
				x = $'

			else
				raise "bad operand #{x}"
			end
			x.lstrip!
		end

		return rv;
	end

	def self.get_mod(tt)
		if [GT, LT, PIPE].include? tt.last
			return tt.pop
		end
		return nil
	end

	def self.parse_unary(tt)


		ops = []
		case tt.last
		when nil, COMMA, RPAREN, RBRACKET ; return nil
		when Integer; return tt.pop
		when *UNARY
			while UNARY.include? tt.last
				ops.push tt.pop
			end
		when Symbol ; return tt.pop
		else ; raise "Expression error"

		end

		e = case tt.last
		when Integer, Symbol ; tt.pop
		else ; raise "Expression error"
		end

		return ops.reverse.reduce(e) {|rv, op| UnaryExpression.new(op, rv)}

	end

	def self.parse_expr(tt)
		# literals are a full expression.
		return tt.pop if Literal === tt.last

		first = parse_unary(tt)
		raise "Expression expected" unless first
		case tt.last
		when nil, COMMA, RPAREN, RBRACKET ; return first
		end

		ops = []
		q = []

		q.push first

		loop do

			case tt.last
			when nil, COMMA, RPAREN, RBRACKET
				while !ops.empty?
					a = q.pop
					b = q.pop
					q.push BinaryExpression.new(ops.pop[0], b, a)
				end
				return q.first
			end

			op = tt.pop
			prec = PREC[op] or raise "Expression error"

			while !ops.empty? && ops.last[1] <= prec
				a = q.pop
				b = q.pop

				q.push BinaryExpression.new(ops.pop[0], b, a)
			end

			ops.push [op, prec]

			x = parse_unary(tt)
			raise "Expression error" unless x
			q.push x
		end

	end

	def self.expect_block_operand(operand)

		return { :mode => :implied, :explicit => true } if operand.nil? || operand.empty?

		tt = tokenize(operand)

		tt.reverse!

		a = parse_expr(tt)
		raise "syntax error #{operand}" unless tt.last == COMMA
		tt.pop
		b = parse_expr(tt)
		raise "syntax error #{operand}" unless tt.empty?

		return { :mode => :block, :explicit => true, :value => [a,b]}

	end

	def self.expect_operand(operand)

		mode = nil
		explicit = false


		return { :mode => :implied, :explicit => true } if operand.nil? || operand.empty?

		tt = tokenize(operand)

		tt.reverse!

		t = tt.last
		case t

			# # expr
		when POUND
			tt.pop
			e = parse_expr(tt)
			raise "syntax error #{operand}" unless tt.empty?
			explicit = true
			mode = :immediate

			# [expr]
			# [expr] , y
		when LBRACKET

			tt.pop
			modifier = get_mod(tt)
			explicit = !!modifier

			e = parse_expr(tt)

			case tt.reverse
			when [RBRACKET]
				case modifier
				when nil ; mode = :zp_indirect_long
				when LT ; mode = :zp_indirect_long
				when PIPE ; mode = :absolute_indirect_long
				end
			when [RBRACKET , COMMA , :y]
				case modifier
				when nil ; mode = :zp_indirect_long_y
				when LT ; mode = :zp_indirect_long_y
				end
			else
				raise "syntax error #{operand}"
			end

			# ( expr )
			# ( expr ) , y
			# ( expr , x )
			# ( expr , s) , y
		when LPAREN

			tt.pop
			modifier = get_mod(tt)
			explicit = !!modifier

			e = parse_expr(tt)

			case tt.reverse
			when [RPAREN]
				case modifier
				when nil ; mode = :zp_indirect
				when LT ; mode = :zp_indirect
				when PIPE ; mode = :absolute_indirect
				end
			when [RPAREN , COMMA, :y]
				case modifier
				when nil ; mode = :zp_indirect_y
				when LT ; mode = :zp_indirect_y
				end
			when [COMMA , :x, RPAREN]
				case modifier
				when nil ; mode = :zp_indirect_x
				when LT ; mode = :zp_indirect_x
				when PIPE ; mode = :absolute_indirect_x
				end
			when [COMMA , :s, RPAREN , COMMA , :y]
				case modifier
				when nil ; mode = :sr_indirect_y
				when LT ; mode = :sr_indirect_y
				end
			else
				raise "syntax error #{operand}"
			end


			# expr
			# expr , x
			# expr , y
			# expr , s
		else
			modifier = get_mod(tt)
			explicit = !!modifier
			e = parse_expr(tt)

			case tt.reverse
			when []
				case modifier
				when nil ; mode = :absolute
				when LT ; mode = :zp
				when PIPE ; mode = :absolute
				when GT ; mode = :absolute_long
				end

			when [ COMMA, :x]
				case modifier
				when nil ; mode = :absolute_x
				when LT ; mode = :zp_x
				when PIPE ; mode = :absolute_x
				when GT ; mode = :absolute_long_x
				end

			when [ COMMA, :y]
				case modifier
				when nil ; mode = :absolute_y
				when LT ; mode = :zp_y
				when PIPE ; mode = :absolute_y
				end

			when [ COMMA, :s]
				case modifier
				when nil ; mode = :sr
				when LT ; mode = :sr
				end

			else
				raise "syntax error #{operand}"
			end

		end

		raise "invalid address mode" unless mode
		return {:mode => mode, :value => e, :explicit => explicit}


	end

	def finish(code, st)

		# resolve symbols, etc.

		@symbols.delete :'*'
		@patches.each {|p|
			pc = p[:pc]
			size = p[:size]
			value = p[:value]
			mode = p[:mode]


			xvalue = reduce_operand(value)

			raise "Undefined symbol #{value}" unless Integer === xvalue


			offset = pc - @org
			if mode == :relative

				# fudge value...
				xvalue = xvalue - (pc + size)
				if size == 1
					if xvalue < -128 || xvalue > 127
						raise "relative branch out of range"
					end
				end
				xvalue = xvalue & 0xffff
			end

			size.times {
				@data[offset] = xvalue & 0xff
				xvalue = xvalue >> 8
				offset = offset + 1
			}
		}

		pc = @org
		while !@data.empty?


			prefix = @poke ? "& POKE #{pc}," : "DATA "

			tmp = @data.take CHUNK_SIZE

			code.push prefix + tmp.join(',')

			pc += tmp.length

			@data = @data.drop CHUNK_SIZE

		end

		@exports.each {|key, _value|

			st[key] = @symbols[key] if @symbols.has_key? key
		}

		reset
		true
	end


	
end
