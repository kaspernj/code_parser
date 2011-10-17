require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "CodeParser" do
  Dir.foreach("#{File.dirname(__FILE__)}/testfiles") do |file|
    if file.match(/\.php$/)
      it "parse and write ruby for #{file}" do
        code_parser = Code_parser.new
        parser = code_parser.language("php", {"file" => "#{File.dirname(__FILE__)}/testfiles/#{file}"})
        block = parser.parse
        
        writer = code_parser.writer("ruby", {:block => block})
        print writer.to_s
      end
    end
  end
end
