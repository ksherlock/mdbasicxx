

TOKENS = [
	#80
	"END",
	"FOR",
	"NEXT",
	"DATA",
	"INPUT",
	"DEL",
	"DIM",
	"READ",
	"GR",
	"TEXT",
	"PR#",
	"IN#",
	"CALL",
	"PLOT",
	"HLIN",
	"VLIN",
	"HGR2",
	"HGR",
	"HCOLOR=",
	"HPLOT",
	"DRAW",
	"XDRAW",
	"HTAB",
	"HOME",
	"ROT=",
	"SCALE-",
	"SHLOAD",
	"TRACE",
	"NOTRACE",
	"NORMAL",
	"INVERSE",
	"FLASH",
	"COLOR ",
	"POP",
	"VTAB",
	"HIMEM=",
	"LOMEM=",
	"ONERR",
	"RESUME",
	"RECALL",
	"STORE",
	"SPEED=",
	"LET",
	"GOTO",
	"RUN",
	"IF",
	"RESTORE",
	"&",
	#B0
	"GOSUB",
	"RETURN",
	"REM",
	"STOP",
	"ON",
	"WAIT",
	"LIST",
	"SAVE",
	"DEF",
	"POKE",	
	"PRINT",
	"CONT",
	"LIST",
	"CLEAR",
	"GET",
	"NEW",
	"TAB(",
	"TO",
	"FN",
	"SPC(",
	"THEN",
	"AT",
	"NOT",
	"STEP",
	"+",
	"-",
	"*",
	"/",
	"^",
	"AND",
	"OR",
	">",
	"=",
	"<",
	"SGN",
	"INT",
	"ABS",
	"USR",
	"FRE",
	"SCRN(",
	"PDL",
	"POS",
	"SQR",
	"RND",
	"LOG",
	"EXP",
	"COS",
	"SIN",
	"TAN",
	"ATN",
	"PEEK",
	"LEN",
	"STR$",
	"VAL",
	"ASC",
	"CHR$",
	"LEFT$",
	"RIGHT$",
	"MID$",
]

# uint16_t uint16_t bytes 0x00
# |        |        |     |- end of line marker.
# |        |        | 0x80+ = token, otherwise char
# |        |- line #
# |- offset to next line, 0 for end
def list(infile, outfile = nil, options = nil)


#
# print depends on the $\ and $, global variables.
#

	outfile = $stdout if outfile == nil
	compact = options ? options[:compact] : false
 	lowercase = options ? options[:lowercase] : false

	state = 0
	offset = 0
	line = 0

	infile.each_byte {|x|

		case state
		when 0
			offset = x;
			state = state + 1
		when 1
			offset |= x << 16
			state = state + 1
		when 2
			line = x
			state = state + 1
		when 3
			line |= x << 16

			if !compact then
				outfile.printf("% 5d ", line)
			else
				outfile.print(line)
			end
			state = state + 1

		when 4
			if x == 0 then
				outfile.print("\n")
				state = 0
				line = 0
				offset = 0
				next
			end
			if x >= 0xeb then
				raise RuntimeError.new("Bad token: %02x " % x)
				next
			end
			if x >= 0x80 then
				t = TOKENS[x - 0x80]
				t = t.downcase() if lowercase
				if !compact then
					outfile.printf(" %s ", t)
				else
					outfile.print(t)
				end
				next
			end
			if x < 0x20 then
				outfile.print("^")
				x += 0x40
			end
			outfile.putc(x)
			
		end
	}

	if state != 2 or offset != 0 then
		raise EOFError.new()
	end


end
