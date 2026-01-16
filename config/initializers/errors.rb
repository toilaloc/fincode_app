# frozen_string_literal: true

# Require base error class first
require Rails.root.join('lib', 'errors', 'base_error.rb')

# Then require all other error classes
Dir[Rails.root.join('lib', 'errors', '*.rb')].sort.each do |file|
  require file unless file.end_with?('base_error.rb')
end

# Make error classes available globally
Object.const_set(:ActionFailed, Errors::ActionFailed)
Object.const_set(:ServiceFailed, Errors::ServiceFailed)
Object.const_set(:Runtime, Errors::Runtime)
