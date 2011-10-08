class Code_parser::Writer::Ruby
  attr_reader :args, :tabs
  
  def initialize(args)
    @args = args
    
    if !@args.has_key?(:tabs)
      @tabs = 0
    else
      @tabs = @args[:tabs].to_i
    end
  end
  
  def tabs_str
    str = ""
    0.upto(@tabs - 1) do
      str += "  "
    end
    
    return str
  end
  
  def to_s
    str = ""
    @args[:block].actions.each do |action|
      if action.is_a?(Code_parser::Function_definition)
        str += "#{tabs_str}def #{action.args[:name]}("
        
        first = true
        action.args[:args].each do |func_argument|
          str += ", " if !first
          first = false if first
          str += func_argument[:name]
        end
        
        str += ")\n"
        str += Code_parser::Writer::Ruby.new(:block => action.block, :tabs => @tabs + 1).to_s
        str += "#{tabs_str}end\n#{tabs_str}\n"
      elsif action.is_a?(Code_parser::Function_call)
        str += "#{tabs_str}#{action.args[:name]}("
        str += self.arguments_to_ruby(action.args[:args])
        str += ")\n"
      else
        raise "Unknown action: '#{action.class.name}'."
      end
    end
    
    return str
  end
  
  def arguments_to_ruby(args)
    str = ""
    first = true
    args.each do |argument|
      str += ", " if !first
      first = false if first
      
      if argument.args[:type] == :string
        str += "\"#{argument.args[:value]}\""
      elsif argument.args[:type] == :variable
        str += "#{argument.args[:name]}"
      else
        raise "Unknown argument-type: '#{argument.args[:type]}'."
      end
    end
    
    return str
  end
end