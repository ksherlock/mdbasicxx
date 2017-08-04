lib = File.expand_path('../lib/', __FILE__)  
$:.unshift lib unless $:.include? lib

require "version"

Gem::Specification.new do |s|  
	s.name         = 'mdbasic++'
	s.version      = VERSION
	s.platform     = Gem::Platform::RUBY

	s.description  = "MD-BASIC++"
	s.summary      = "MD-BASIC++"
	s.authors      = ['Kelvin W Sherlock']
	s.email        = ['ksherlock@gmail.com']
	s.licenses     = []


	s.files        = Dir.glob("{bin,lib}/*")
	s.executables  = ['mdbasic++']
	s.require_path = 'lib'
end

