require 'optparse'
require 'time'

require_relative 'MiniAssembler'

now = Time.now
errors = 0

body = []
header = [
	"#define __MDBASICXX__",
	'#define __DATE__ "' + now.strftime("%b %e %Y") + '"',
	'#define __TIME__ "' + now.strftime("%H:%M:%S") + '"',
]
m = nil

options = { :verbose => false, :I => [], :o => nil }

op = OptionParser.new do |opts|
	opts.banner = "Usage: mdbasic++ [options] file"
	opts.version = '0.0.0'
	opts.release = nil


	opts.on("-D macroname[=value]", "Define a macro") do |x|
		k, v = x.split('=',2)
		if v
			header.push "#define #{k} #{v}"
		else
			header.push "#define #{k}"
		end
	end

	opts.on("-I directory", "Specify include path") do |x|
		options[:I].push x
	end

	opts.on("-o outfile", "Specify outfile") do |x|
		options[:o] = x
	end

	opts.on("-O level", OptionParser::DecimalInteger, "Specify optimization level") do |x|
		if x < 0 || x > 2
			warn "Invalid optimization level #{x}"
		else
			header.push "#pragma optimize #{x},2"
		end
	end

	opts.on("-v", "--verbose", "Be verbose") do
		options[:verbose] = true
		header.push "#pragma summary 1"
		header.push "#pragma xref 1,1"
	end

	opts.on('-V', "--version", "Display version") do
		puts opts.ver
		exit 0
	end


	opts.on("--[no-]declare", "Require declarations") do |x|
		header.push "#pragma declare #{x ? 1 : 0}"
	end

	opts.on("--[no-]summary", "Print summary") do |x|
		header.push "#pragma summary #{x ? 1 : 0}"
	end

	opts.on("--[no-]xref", "Print Cross References") do |x|
		header.push "#pragma xref #{x ? 1 : 0},#{x ? 1 : 0}"
	end




	opts.on_tail("-h", "--help", "Display help information") do
		puts opts
		exit 0
	end


end

begin
	op.parse!
rescue OptionParser::ParseError => e
	puts e
	puts op
	exit 1
end


ARGF.each_line {|line|
	line.chomp!

	if m
		if line =~ /^#\s*endasm\s*$/
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