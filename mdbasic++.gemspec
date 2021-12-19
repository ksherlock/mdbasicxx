lib = File.expand_path('../lib/', __FILE__)  
$:.unshift lib unless $:.include? lib


Gem::Specification.new do |s|  
	s.name         = 'mdbasicxx'
	s.version      = "0.0.7"
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

