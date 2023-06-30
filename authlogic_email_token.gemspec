Gem::Specification.new do |s|
  s.name         = 'authlogic_email_token'
  s.version      = '0.0.6'
  s.date         = '2016-10-02'
  s.summary      = 'Authlogic extension for email confirmation'
  s.description  = "Adds email_token and email_token_updated_at columns. Works like " +
                   "Authlogic's perishable_token, but doesn't reset on every request. " +
                   "Designed primarily for verifying users' email addresses."
  s.authors      = ['Jarrett Colby']
  s.email        = 'jarrett@madebyhq.com'
  s.files        = Dir.glob('lib/**/*')
  s.homepage     = 'https://github.com/jarrett/authlogic_email_token'
  s.license      = 'MIT'
  
  s.add_runtime_dependency 'authlogic', '~> 6'
  s.add_development_dependency 'rails', '>= 4.2'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'minitest', '~> 5'
  s.add_development_dependency 'minitest-reporters', '~> 1'
  s.add_development_dependency 'timecop', '~> 0'
  s.add_development_dependency 'mocha', '~> 2'
  s.add_development_dependency 'database_cleaner', '~> 2'
end
