require "knj/autoload"

class Code_parser
  class Language
    Dir.foreach("#{File.dirname(__FILE__)}/languages") do |file|
      next if file == "." or file == ".."
      autoload Knj::Php.ucwords(file).to_sym, "#{File.dirname(__FILE__)}/languages/#{file}/lang.rb"
    end
  end
  
  class Writer
    Dir.foreach("#{File.dirname(__FILE__)}/writers") do |file|
      next if file == "." or file == ".."
      autoload Knj::Php.ucwords(file).to_sym, "#{File.dirname(__FILE__)}/writers/#{file}/writer.rb"
    end
  end
  
  class Block
    attr_reader :args, :actions
    
    def initialize(args = {})
      @args = args
      @actions = []
    end
  end
  
  class Function_definition
    attr_reader :block
    
    def initialize(args)
      @args = args
      @block = Code_parser::Block.new
    end
  end
  
  class Function_call
    attr_reader :args
    
    def initialize(args)
      @args = args
    end
  end
  
  class Argument
    attr_reader :args
    
    def initialize(args)
      @args = args
    end
  end
  
  def initialize(args = {})
    
  end
  
  def language(lang_str, *args)
    return Code_parser::Language.const_get(Knj::Php.ucwords(lang_str).to_sym).new(*args)
  end
  
  def writer(lang_str, *args)
    return Code_parser::Writer.const_get(Knj::Php.ucwords(lang_str).to_sym).new(*args)
  end
end