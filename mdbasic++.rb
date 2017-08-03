
require_relative 'MiniAssembler'

errors = 0

body = []
header = []
m = nil

ARGF.each_line {|line|
	line.chomp!

	if m
		if line =~ /^#\s*end\s*$/
			data = []
			st = {}
			m.finish(data, st)
			m = nil

			data.each {|x|
				body.push "\t#{x}"
			}

			st.each {| k, v |
				k = k.to_s.upcase 
				header.push "#define #{k} #{v}"
			}
		else
			begin
				m.process(line)
			rescue => e
				puts e
				errors = errors + 1
			end
		end
		next
	end

	case line
	when /^#\s*asm\s*$/
		m = MiniAssembler.new()
	else
		body.push line
	end


}

exit 1 if errors > 0

header.each { |x| puts x }
puts 
body.each { |x| puts x }