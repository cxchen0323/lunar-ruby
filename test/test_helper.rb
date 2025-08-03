require 'minitest/autorun'
require 'minitest/spec'

# Ensure we're loading our library files
$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

# Require base lunar module
require 'lunar'