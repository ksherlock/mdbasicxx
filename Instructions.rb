
class Instructions

# make_instr.rb Wed Aug  2 12:42:54 2017

INSTRUCTIONS = {
	:adc => [[0x010761, :zp_indirect_x],
		 [0x010463, :sr],
		 [0x010765, :zp],
		 [0x010467, :zp_indirect_long],
		 [0x010769, :immediate],
		 [0x02076d, :absolute],
		 [0x03046f, :absolute_long],
		 [0x010771, :zp_indirect_y],
		 [0x010672, :zp_indirect],
		 [0x010473, :sr_indirect_y],
		 [0x010775, :zp_x],
		 [0x010477, :zp_indirect_long_y],
		 [0x020779, :absolute_y],
		 [0x02077d, :absolute_x],
		 [0x03047f, :absolute_long_x]],
	:and => [[0x010721, :zp_indirect_x],
		 [0x010423, :sr],
		 [0x010725, :zp],
		 [0x010427, :zp_indirect_long],
		 [0x010729, :immediate],
		 [0x02072d, :absolute],
		 [0x03042f, :absolute_long],
		 [0x010731, :zp_indirect_y],
		 [0x010632, :zp_indirect],
		 [0x010433, :sr_indirect_y],
		 [0x010735, :zp_x],
		 [0x010437, :zp_indirect_long_y],
		 [0x020739, :absolute_y],
		 [0x02073d, :absolute_x],
		 [0x03043f, :absolute_long_x]],
	:asl => [[0x010706, :zp],
		 [0x00070a, :implied],
		 [0x02070e, :absolute],
		 [0x010716, :zp_x],
		 [0x02071e, :absolute_x]],
	:bcc => [[0x010790, :relative]],
	:bcs => [[0x0107b0, :relative]],
	:beq => [[0x0107f0, :relative]],
	:bit => [[0x010724, :zp],
		 [0x02072c, :absolute],
		 [0x010634, :zp_x],
		 [0x02063c, :absolute_x],
		 [0x010689, :immediate]],
	:bmi => [[0x010730, :relative]],
	:bne => [[0x0107d0, :relative]],
	:bpl => [[0x010710, :relative]],
	:bra => [[0x010680, :relative]],
	:brk => [[0x010700, :interrupt]],
	:brl => [[0x020482, :relative]],
	:bvc => [[0x010750, :relative]],
	:bvs => [[0x010770, :relative]],
	:clc => [[0x000718, :implied]],
	:cld => [[0x0007d8, :implied]],
	:cli => [[0x000758, :implied]],
	:clv => [[0x0007b8, :implied]],
	:cmp => [[0x0107c1, :zp_indirect_x],
		 [0x0104c3, :sr],
		 [0x0107c5, :zp],
		 [0x0104c7, :zp_indirect_long],
		 [0x0107c9, :immediate],
		 [0x0207cd, :absolute],
		 [0x0304cf, :absolute_long],
		 [0x0107d1, :zp_indirect_y],
		 [0x0106d2, :zp_indirect],
		 [0x0104d3, :sr_indirect_y],
		 [0x0107d5, :zp_x],
		 [0x0104d7, :zp_indirect_long_y],
		 [0x0207d9, :absolute_y],
		 [0x0207dd, :absolute_x],
		 [0x0304df, :absolute_long_x]],
	:cop => [[0x010402, :interrupt]],
	:cpx => [[0x0107e0, :immediate],
		 [0x0107e4, :zp],
		 [0x0207ec, :absolute]],
	:cpy => [[0x0107c0, :immediate],
		 [0x0107c4, :zp],
		 [0x0207cc, :absolute]],
	:dec => [[0x00063a, :implied],
		 [0x0107c6, :zp],
		 [0x0207ce, :absolute],
		 [0x0107d6, :zp_x],
		 [0x0207de, :absolute_x]],
	:dex => [[0x0007ca, :implied]],
	:dey => [[0x000788, :implied]],
	:eor => [[0x010741, :zp_indirect_x],
		 [0x010443, :sr],
		 [0x010745, :zp],
		 [0x010447, :zp_indirect_long],
		 [0x010749, :immediate],
		 [0x02074d, :absolute],
		 [0x03044f, :absolute_long],
		 [0x010751, :zp_indirect_y],
		 [0x010652, :zp_indirect],
		 [0x010453, :sr_indirect_y],
		 [0x010755, :zp_x],
		 [0x010457, :zp_indirect_long_y],
		 [0x020759, :absolute_y],
		 [0x02075d, :absolute_x],
		 [0x03045f, :absolute_long_x]],
	:inc => [[0x00061a, :implied],
		 [0x0107e6, :zp],
		 [0x0207ee, :absolute],
		 [0x0107f6, :zp_x],
		 [0x0207fe, :absolute_x]],
	:inx => [[0x0007e8, :implied]],
	:iny => [[0x0007c8, :implied]],
	:jml => [[0x03045c, :absolute_long],
		 [0x0204dc, :absolute_indirect_long]],
	:jmp => [[0x02074c, :absolute],
		 [0x02076c, :absolute_indirect],
		 [0x02067c, :absolute_indirect_x]],
	:jsl => [[0x030422, :absolute_long]],
	:jsr => [[0x020720, :absolute],
		 [0x0204fc, :absolute_indirect_x]],
	:lda => [[0x0107a1, :zp_indirect_x],
		 [0x0104a3, :sr],
		 [0x0107a5, :zp],
		 [0x0104a7, :zp_indirect_long],
		 [0x0107a9, :immediate],
		 [0x0207ad, :absolute],
		 [0x0304af, :absolute_long],
		 [0x0107b1, :zp_indirect_y],
		 [0x0106b2, :zp_indirect],
		 [0x0104b3, :sr_indirect_y],
		 [0x0107b5, :zp_x],
		 [0x0104b7, :zp_indirect_long_y],
		 [0x0207b9, :absolute_y],
		 [0x0207bd, :absolute_x],
		 [0x0304bf, :absolute_long_x]],
	:ldx => [[0x0107a2, :immediate],
		 [0x0107a6, :zp],
		 [0x0207ae, :absolute],
		 [0x0107b6, :zp_y],
		 [0x0207be, :absolute_y]],
	:ldy => [[0x0107a0, :immediate],
		 [0x0107a4, :zp],
		 [0x0207ac, :absolute],
		 [0x0107b4, :zp_x],
		 [0x0207bc, :absolute_x]],
	:lsr => [[0x010746, :zp],
		 [0x00074a, :implied],
		 [0x02074e, :absolute],
		 [0x010756, :zp_x],
		 [0x02075e, :absolute_x]],
	:mvn => [[0x020454, :block]],
	:mvp => [[0x020444, :block]],
	:nop => [[0x0007ea, :implied]],
	:ora => [[0x010701, :zp_indirect_x],
		 [0x010403, :sr],
		 [0x010705, :zp],
		 [0x010407, :zp_indirect_long],
		 [0x010709, :immediate],
		 [0x02070d, :absolute],
		 [0x03040f, :absolute_long],
		 [0x010711, :zp_indirect_y],
		 [0x010612, :zp_indirect],
		 [0x010413, :sr_indirect_y],
		 [0x010715, :zp_x],
		 [0x010417, :zp_indirect_long_y],
		 [0x020719, :absolute_y],
		 [0x02071d, :absolute_x],
		 [0x03041f, :absolute_long_x]],
	:pea => [[0x0204f4, :absolute]],
	:pei => [[0x0104d4, :zp_indirect]],
	:per => [[0x020462, :relative]],
	:pha => [[0x000748, :implied]],
	:phb => [[0x00048b, :implied]],
	:phd => [[0x00040b, :implied]],
	:phk => [[0x00044b, :implied]],
	:php => [[0x000708, :implied]],
	:phx => [[0x0006da, :implied]],
	:phy => [[0x00065a, :implied]],
	:pla => [[0x000768, :implied]],
	:plb => [[0x0004ab, :implied]],
	:pld => [[0x00042b, :implied]],
	:plp => [[0x000728, :implied]],
	:plx => [[0x0006fa, :implied]],
	:ply => [[0x00067a, :implied]],
	:rep => [[0x0104c2, :immediate]],
	:rol => [[0x010726, :zp],
		 [0x00072a, :implied],
		 [0x02072e, :absolute],
		 [0x010736, :zp_x],
		 [0x02073e, :absolute_x]],
	:ror => [[0x010766, :zp],
		 [0x00076a, :implied],
		 [0x02076e, :absolute],
		 [0x010776, :zp_x],
		 [0x02077e, :absolute_x]],
	:rti => [[0x000740, :implied]],
	:rtl => [[0x00046b, :implied]],
	:rts => [[0x000760, :implied]],
	:sbc => [[0x0107e1, :zp_indirect_x],
		 [0x0104e3, :sr],
		 [0x0107e5, :zp],
		 [0x0104e7, :zp_indirect_long],
		 [0x0107e9, :immediate],
		 [0x0207ed, :absolute],
		 [0x0304ef, :absolute_long],
		 [0x0107f1, :zp_indirect_y],
		 [0x0106f2, :zp_indirect],
		 [0x0104f3, :sr_indirect_y],
		 [0x0107f5, :zp_x],
		 [0x0104f7, :zp_indirect_long_y],
		 [0x0207f9, :absolute_y],
		 [0x0207fd, :absolute_x],
		 [0x0304ff, :absolute_long_x]],
	:sec => [[0x000738, :implied]],
	:sed => [[0x0007f8, :implied]],
	:sei => [[0x000778, :implied]],
	:sep => [[0x0104e2, :immediate]],
	:sta => [[0x010781, :zp_indirect_x],
		 [0x010483, :sr],
		 [0x010785, :zp],
		 [0x010487, :zp_indirect_long],
		 [0x02078d, :absolute],
		 [0x03048f, :absolute_long],
		 [0x010791, :zp_indirect_y],
		 [0x010692, :zp_indirect],
		 [0x010493, :sr_indirect_y],
		 [0x010795, :zp_x],
		 [0x010497, :zp_indirect_long_y],
		 [0x020799, :absolute_y],
		 [0x02079d, :absolute_x],
		 [0x03049f, :absolute_long_x]],
	:stp => [[0x0006db, :implied]],
	:stx => [[0x010786, :zp],
		 [0x02078e, :absolute],
		 [0x010796, :zp_y]],
	:sty => [[0x010784, :zp],
		 [0x02078c, :absolute],
		 [0x010794, :zp_x]],
	:stz => [[0x010664, :zp],
		 [0x010674, :zp_x],
		 [0x02069c, :absolute],
		 [0x02069e, :absolute_x]],
	:tax => [[0x0007aa, :implied]],
	:tay => [[0x0007a8, :implied]],
	:tcd => [[0x00045b, :implied]],
	:tcs => [[0x00041b, :implied]],
	:tdc => [[0x00047b, :implied]],
	:trb => [[0x010614, :zp],
		 [0x02061c, :absolute]],
	:tsb => [[0x010604, :zp],
		 [0x02060c, :absolute]],
	:tsc => [[0x00043b, :implied]],
	:tsx => [[0x0007ba, :implied]],
	:txa => [[0x00078a, :implied]],
	:txs => [[0x00079a, :implied]],
	:txy => [[0x00049b, :implied]],
	:tya => [[0x000798, :implied]],
	:tyx => [[0x0004bb, :implied]],
	:wai => [[0x0006cb, :implied]],
	:wdm => [[0x010442, :interrupt]],
	:xba => [[0x0004eb, :implied]],
	:xce => [[0x0004fb, :implied]],
}




	def initialize(args)
		
	end

	def self.rehydrate(mnemonic, data)

		m = x = false
		a , mode = data

		if mode == :immediate
			case mnemonic
			when :adc, :and, :bit, :cmp, :eor, :lda, :ora, :sbc
				m = true
			when :ldx, :ldy, :cpx, :cpy
				x = true
			end
		end

		return { :mnemonic => mnemonic, :opcode => a & 0xff, :size => (a >> 16) & 0xff, :mode => mode, :m => m, :x => x }
	end

	def self.lookup(mnemonic, mode, explicit, machine)

		xmachine = (1 << machine) << 8

		case mnemonic
		when :brk, :cop, :wdm
			raise "invalid address mode" if explicit && mode != :immediate
			mode = :interrupt
			explicit = true
		# when :mvp, :mvn
		# 	raise "invalid address mode" if explicit
		# 	mode = :block
		# 	explicit = true
		when :bcc, :bcs, :beq, :bmi, :bne, :bpl, :bra, :bvc, :bvs, :brl
			raise "invalid address mode" if explicit && mode != :absolute
			mode = :relative
			explicit = true

		when :pea
			mode = :absolute if mode == :immediate

		when :pei
			mode = :zp_indirect if mode == :zp
			mode = :zp_indirect if mode == :absolute && !explicit

		end


		instrs = INSTRUCTIONS[mnemonic]
		raise "invalid instruction" unless instrs


		instrs = instrs.select {|x| x[0] & xmachine == xmachine }

		raise "invalid instruction for this machine" if instrs.empty?

		instr = instrs.select {|x| x[1] == mode }

		return rehydrate(mnemonic, instr.first) unless instr.empty?

		raise "invalid address mode" if explicit

		# try other modes...

		modes = case mode
		when :zp ; [:absolute, :absolute_long]
		when :absolute ; [:zp, :absolute_long]
		when :zp_x ; [:absolute_x, :absolute_long_x]
		when :absolute_x ; [zp_x, :absolute_long_x]
		when :zp_y ; [absolute_y]
		when :absolute_y ; [:zp_y]
		when :zp_indirect ; [:absolute_indirect]
		when :absolute_indirect ; [:zp_indirect]
		when :zp_indirect_x ; [:absolute_indirect_x]
		when :absolute_indirect_x ; [zp_indirect_x]
		when :zp_indirect_long ; [:absolute_indirect_long]
		when :absolute_indirect_long ; [:zp_indirect_long]
		else
			[]
		end


		modes.each {|xmode|

			instr = instrs.select {|x| x[1] == xmode }
			return rehydrate(mnemonic, instr.first) unless instr.empty?
		}

		raise "invalid address mode"

	end
	

end
