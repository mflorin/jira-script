Gem::Specification.new do |s|
  s.name          = 'jira-script'
  s.version       = '1.0.1'
  s.date          = '2017-03-28'
  s.summary       = 'Jira DSL'
  s.description   = 'A Ruby DSL script implementation to automate creating and updating many Jira issues at once.'
  s.authors       = ['Florin Mihalache']
  s.email         = 'florin.mihalache@gmail.com'
  s.add_runtime_dependency 'typhoeus', '~> 1.1'
  s.files         = %w[lib/jira-script.rb lib/jira-script/request.rb]
  s.homepage      = 'http://github.com/mflorin/jira-script'
  s.license       = 'MIT'
 
end
