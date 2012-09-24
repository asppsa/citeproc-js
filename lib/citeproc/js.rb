if ENV['DEBUG']
  require 'ruby-debug'
  Debugger.start
end

require 'forwardable'
require 'pp'
require 'thread'

require 'citeproc'

require 'citeproc/js/version'
require 'citeproc/js/engine'
require 'citeproc/js/nokogiri_parser'
require 'citeproc/js/object_hash'
