Gem::Specification.new do |s|
  s.name         = 'authlogic_email_token'
  s.version      = '0.0.1'
  s.date         = '2014-08-30'
  s.summary      = 'Authlogic extension for email confirmation'
  s.description  = "Adds email_token and email_token_updated_at columns. Works like " +
                   "Authlogic's perishable_token, but doesn't reset on every request. " +
                   "Designed primarily for verifying users' email addresses."
  s.authors      = ['Jarrett Colby']
  s.email        = 'jarrett@madebyhq.com'
  s.files        = Dir.glob('lib/**/*')
  s.homepage     = 'https://github.com/jarrett/authlogic_email_token'
  s.license      = 'MIT'
  
  s.add_runtime_dependency 'authlogic', '~> 3'
  s.add_development_dependency 'minitest', '~> 5'
  s.add_development_dependency 'minitest-reporters', '~> 1'
  s.add_development_dependency 'timecop', '~> 0'
  s.add_development_dependency 'mocha', '~> 1'
  s.add_development_dependency 'database_cleaner', '~> 1'
end