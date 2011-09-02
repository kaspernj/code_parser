require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "CodeParser" do
  it "should initialize" do
    $code_parser = Code_parser.new
  end
  
  it "should start a php parser and parse a sample-file" do
    $parser = $code_parser.language("php", {"file" => "#{File.dirname(__FILE__)}/testfiles/test_function.php"})
    $block = $parser.parse
  end
  
  it "should be able to generate ruby source code from that block" do
    writer = $code_parser.writer("ruby", {:block => $block})
    print writer.to_s
  end
end
