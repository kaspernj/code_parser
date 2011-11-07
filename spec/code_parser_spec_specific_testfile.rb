#!/usr/bin/env ruby

require "knj/autoload"
require "#{File.dirname(__FILE__)}/../lib/code_parser.rb"

begin
  args = {}
  
  OptionParser.new do |opts|
    opts.banner = "Usage: code_parser_spec_specific_testfile. [options]"
    
    opts.on("-f FILENAME", "--file FILENAME", "The file that should be testet.") do |fn|
      args[:file] = fn
    end
  end.parse!
rescue OptionParser::InvalidOption => e
  print "#{e.message}\n"
  exit
end

if !args[:file]
  print "No --file was given.\n"
  exit
end

Dir.foreach("#{File.dirname(__FILE__)}/testfiles") do |file|
  if file.match(/\.php$/) and file == args[:file]
    code_parser = Code_parser.new
    parser = code_parser.language("php", {"file" => "#{File.dirname(__FILE__)}/testfiles/#{file}"})
    block = parser.parse
    
    writer = code_parser.writer("ruby", {:block => block})
    print writer.to_s
  end
end