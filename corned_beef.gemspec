Gem::Specification.new do |gem|
  gem.name            = 'corned_beef'
  gem.version         = '0.0.3'

  gem.summary         = 'Support ActiveRecord models based on YAML files, JSON object, ... and Hash!'
  gem.email           = 'semmons@numerex.com'
  gem.homepage        = 'http://github.com/spemmons/corned_beef'

  gem.authors         = %w(spemmons)
  gem.files           = Dir['{app,lib,config}/**/*'] + ['MIT-LICENSE', 'Rakefile', 'Gemfile', 'README.rdoc']

  gem.add_dependency  'rails'
end
