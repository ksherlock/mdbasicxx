class Expression

	# beta reduction ? substitution?
	def reduce(st)
	end

	# generate a list of symbols
	def collect()
	end

	def to_s()
	end

	def self.reduce(e, st)

		return case e
		when Expression ; e.reduce(st) || e
		when Symbol ; st[e] || e
		else ; e
		end
	end

	def self.collect(e)

		return case e
		when Expression ; e.collect
		when Symbol ; [e]
		else nil
		end

	end


end

class UnaryExpression < Expression
	def initialize(op, first)
		@op = op
		@first = first
	end
	
	def reduce(st)

		first = Expression.reduce(@first, st)

		if Integer === first
			return case @op
			when :'+' ; first
			when :'-' ; -first
			when :'^' ; first >> 16
			when :'~' ; ~first
			when :'!' ; first == 0 ? 1 : 0
			end & 0xffffffff
		end

		return self if @first == first
		return UnaryExpression.new(@op, first)
	end

	def collect()
		return Expression.collect(@first)
	end

	def to_s
		return "#{@op} #{@first.to_s}"
	end

	
end

class BinaryExpression < Expression
	def initialize(op, first, second)
		@op = op
		@first = first
		@second = second
	end

	def reduce(st)

		first = Expression.reduce(@first, st)
		second = Expression.reduce(@second, st)



		if Integer === first && Integer === second
			return case @op
			when :'+' ; first + second
			when :'-' ; first - second
			when :'^' ; first ^ second
			when :'|' ; first | second
			when :'&' ; first & second
			when :'*' ; first * second
			when :'/' ; first / second
			when :'%' ; first % second
			when :'>>' ; first >> second
			when :'<<' ; first << second

			when :'<' ; first < second ? 1 : 0
			when :'<=' ; first <= second ? 1 : 0
			when :'>' ; first > second ? 1 : 0
			when :'>=' ; first >= second ? 1 : 0
			when :'||' ; first || second ? 1 : 0
			when :'&&' ; first && second ? 1 : 0

			end & 0xffffffff
		end
		return self if first == @first && second == @second
		return BinaryExpression.new(@op, first, second)
	end

	def collect()

		a = Expression.collect(@first)
		b = Expression.collect(@second)

		return a + b if a && b
		return a || b
	end

	def to_s
		return "#{@first.to_s} #{@op} #{@second.to_s}"
	end	

end