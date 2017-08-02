#!/usr/bin/env ruby -w

#
# generate instruction table.
#

require('rubygems')
require('sqlite3')


db = SQLite3::Database.new("instructions.db")
db.results_as_hash = true

# Modes = {
# 	"(ABS)"         => 1 << 0,
# 	"(ABS,X)"       => 1 << 1,
# 	"(SR,S),Y"      => 1 << 2,
# 	"(ZP)"          => 1 << 3,
# 	"(ZP),Y"        => 1 << 4,
# 	"(ZP,X)"        => 1 << 5,
# 	"ABS"           => 1 << 6,
# 	"ABS,X"         => 1 << 7,
# 	"ABS,Y"         => 1 << 8,
# 	"ABSLONG"       => 1 << 9,
# 	"ABSLONG,X"     => 1 << 10,
# 	"BLOCK"         => 1 << 11,
# 	"IMMEDIATE"     => 1 << 12,
# 	"IMPLIED"       => 1 << 13,
# 	"INTERRUPT"     => 1 << 14,
# 	"RELATIVE"      => 1 << 15,
# 	"RELATIVE_LONG" => 1 << 15, # same
# 	"SR,S"          => 1 << 16,
# 	"ZP"            => 1 << 17,
# 	"ZP,X"          => 1 << 18,
# 	"ZP,Y"          => 1 << 19,
# 	"[ABS]"         => 1 << 20,
# 	"[ZP]"          => 1 << 21,
# 	"[ZP],Y"        => 1 << 22,
# }

Modes = {
	"(ABS)"         => :absolute_indirect,
	"(ABS,X)"       => :absolute_indirect_x,
	"(SR,S),Y"      => :sr_indirect_y,
	"(ZP)"          => :zp_indirect,
	"(ZP),Y"        => :zp_indirect_y,
	"(ZP,X)"        => :zp_indirect_x,
	"ABS"           => :absolute,
	"ABS,X"         => :absolute_x,
	"ABS,Y"         => :absolute_y,
	"ABSLONG"       => :absolute_long,
	"ABSLONG,X"     => :absolute_long_x,
	"BLOCK"         => :block,
	"IMMEDIATE"     => :immediate,
	"IMPLIED"       => :implied,
	"INTERRUPT"     => :interrupt,
	"RELATIVE"      => :relative,
	"RELATIVE_LONG" => :relative,
	"SR,S"          => :sr,
	"ZP"            => :zp,
	"ZP,X"          => :zp_x,
	"ZP,Y"          => :zp_y,
	"[ABS]"         => :absolute_indirect_long,
	"[ZP]"          => :zp_indirect_long,
	"[ZP],Y"        => :zp_indirect_long_y,
}


Machines = {
	'6502' => 1 << 0,
	'65C02' => 1 << 1,
	'65816' => 1 << 2,
}

sql = %{
	select * from instructions
	where machine = '65816'
	order by opcode
}


table = []

db.execute(sql) {|row|

	opcode = row['opcode']
	mnemonic = row['mnemonic'].downcase.intern
	machine = 1 << 2 # Machines[row['machine']]
	mode = Modes[row['mode']]
	size = row['bytes'] - 1
	table[opcode] = [ mnemonic, opcode, machine, mode, size ] 
}

sql = %{
	select * from instructions
	where machine = '65C02'
	order by opcode
}

db.execute(sql) {|row|

	opcode = row['opcode']
	machine = 1 << 1 # Machines[row['machine']]

	x = table[opcode]
	x[2] = x[2] | machine
}


sql = %{
	select * from instructions
	where machine = '6502'
	order by opcode
}

db.execute(sql) {|row|

	opcode = row['opcode']
	machine = 1 << 0 # Machines[row['machine']]

	x = table[opcode]
	x[2] = x[2] | machine
}

# now re-assemble.

hash = {}
table.each { |x| 
	mnemonic, opcode, machine, mode, size = x

	xx = hash[mnemonic]
	xx = hash[mnemonic] = [] if xx.nil?

	xx.push [opcode | (machine << 8) | (size << 16), mode]
}


puts "# make_instr.rb #{Time.now.asctime}"
puts
puts "INSTRUCTIONS = {"
hash.sort.each {|x|
	mnemonic, data = x 

	data = '[' + data.map {|xx| a,b = xx ; a = "0x%06x" % a ; "[#{a}, :#{b}]"  }.join(",\n\t\t ") + ']'	

	puts "\t:#{mnemonic} => #{data},"
}
puts "}"
