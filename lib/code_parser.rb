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
    attr_reader :args, :block
    
    def initialize(args)
      @args = args
      @block = Code_parser::Block.new
    end
    
    def name
      return @args[:name]
    end
  end
  
  class Function_call
    attr_reader :args
    
    def initialize(args)
      @args = args
    end
  end
  
  class Class_definition
    attr_reader :args, :block
    
    def initialize(args)
      @args = args
      @block = Code_parser::Block.new
    end
  end
  
  class Class_spawn
    attr_reader :args
    
    def initialize(args)
      @args = args
    end
  end
  
  class Class_object_function_call
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
    
    def type
      return @args[:type]
    end
    
    def name
      return @args[:name]
    end
  end
  
  class Argument_grouping
    attr_reader :args
    
    def initialize(args = {:arguments => []})
      @args = args
    end
    
    def contains_groupings?
      @args[:arguments].each do |arg|
        return true if arg[:arg].is_a?(Argument_grouping)
      end
      
      return false
    end
    
    def grouping_type
      @args[:arguments].each do |arg|
        return :string if arg[:arg].args[:type] == :string
      end
      
      return false
    end
  end
  
  class String_definition
    attr_reader :args
    
    def initialize(args)
      @args = args
    end
  end
  
  class Variable_definition
    attr_reader :args
    
    def initialize(args)
      @args = args
    end
  end
  
  class Condition
    attr_reader :args
    
    def initialize(args)
      @args = args
    end
  end
  
  class Condition_group
    attr_reader :args
    
    def initialize(args)
      @args = args
    end
  end
  
  class Condition_if
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