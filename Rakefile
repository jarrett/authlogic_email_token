require 'rake/testtask'

# To run one test: rake test TEST=just_one_file.rb
Rake::TestTask.new do |t|
  t.test_files = FileList['test/*_test.rb']
  t.libs << 'test'
end

def built_gem_name
  Dir.glob('authlogic_email_token-*.*.*.gem').first
end

task :build do
  `rm *.gem`
  puts `gem build authlogic_email_token.gemspec`
end

task :install do
  puts `gem install --no-document #{built_gem_name}`
end

task :release do
  puts `gem push #{built_gem_name}`
end