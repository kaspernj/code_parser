class Code_parser::Writer::Ruby
  attr_reader :args, :tabs
  
  def initialize(args)
    @args = args
    raise "No block was given." if !@args[:block]
    
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
    @str = ""
    
    @args[:block].actions.each do |action|
      if action.is_a?(Code_parser::Function_definition)
        name = action.args[:name]
        name = "initialize" if name == "__construct"
        
        @str += "#{tabs_str}def #{name}("
        
        first = true
        action.args[:args].each do |func_argument|
          @str +=  ", " if !first
          first = false if first
          @str += func_argument[:name]
          
          if func_argument[:default_value_has]
            @str += " = \"#{func_argument[:default_value]}\""
          end
        end
        
        @str += ")\n"
        @str += Code_parser::Writer::Ruby.new(:block => action.block, :tabs => @tabs + 1).to_s
        @str += "#{tabs_str}end\n#{tabs_str}\n"
      elsif action.is_a?(Code_parser::Function_call)
        if action.args[:parsed_meaning] == :unset
          action.args[:args].each do |arg|
            if arg.type == :variable
              @str += "#{tabs_str}#{arg.name} = nil\n"
            else
              raise "Unknown type: '#{arg.type}'."
            end
          end
        else
          @str += "#{tabs_str}#{action.args[:name]}"
          
          if action.args[:args].length > 1
            @str += "("
          else
            @str += " "
          end
          
          @str += self.arguments_to_ruby(action.args[:args])
          
          if action.args[:args].length > 1
            @str += ")"
          end
          
          @str += "\n"
        end
      elsif action.is_a?(Code_parser::Class_definition)
        @str += "#{tabs_str}class #{self.ruby_class_name(action.args[:name])}\n"
        @str += Code_parser::Writer::Ruby.new(:block => action.block, :tabs => @tabs + 1).to_s
        @str += "#{tabs_str}end\n#{tabs_str}\n"
      elsif action.is_a?(Code_parser::Class_spawn)
        @str += "#{tabs_str}#{action.args[:var_name]} = #{self.ruby_class_name(action.args[:class_name])}.new"
        
        if !action.args[:args].empty?
          @str += "("
          @str += self.arguments_to_ruby(action.args[:args])
          @str += ")"
        end
        
        @str += "\n"
      elsif action.is_a?(Code_parser::Class_object_function_call)
        @str += "#{tabs_str}#{action.args[:var_name]}.#{action.args[:func_name]}"
        
        if !action.args[:args].empty?
          @str += "("
          @str += self.arguments_to_ruby(action.args[:args])
          @str += ")"
        end
        
        @str += "\n"
      elsif action.is_a?(Code_parser::Variable_definition)
        if action.args[:value].is_a?(Code_parser::String_definition)
          @str += "#{tabs_str}#{action.args[:var_name]} = "
          self.string_definition(action.args[:value])
          @str += "\n"
        else
          raise "Unknown class for variable definition: #{action[:value]}"
        end
      elsif action.is_a?(Code_parser::Condition_if)
        @str += "#{tabs_str}if "
        
        self.condition_group_write(action.args[:group])
        
        @str += "\n"
        @tabs += 1
        @str += Code_parser::Writer::Ruby.new(:block => action.args[:block], :tabs => @tabs + 1).to_s
        @tabs += -1
        @str += "#{tabs_str}end\n"
      else
        raise "Unknown action: '#{action.class.name}'."
      end
    end
    
    return @str
  end
  
  def condition_group_write(grp)
    @str += "("
    
    raise "No conditions?" if !grp.args[:conditions] or grp.args[:conditions].empty?
    
    first = true
    grp.args[:conditions].each do |cond|
      if first
        first = false
      else
        raise "Second string?"
      end
      
      if cond.args[:from][:type] == :var
        @str += "#{cond.args[:from][:var_name]}"
      else
        raise "Unknown from-type: #{cond.args[:from][:type]}"
      end
      
      if cond.args[:type] == :equals and cond.args[:to][:type] == :string
        @str += ".to_s == "
      else
        Knj::Php.print_r(cond.args)
        raise "Unknown condition type: #{cond[:type]}"
      end
      
      if cond.args[:to][:type] == :string
        self.string_definition(cond.args[:to][:str])
      end
    end
    
    @str += ")"
  end
  
  def arguments_to_ruby(arguments, args = {})
    str = ""
    first = true
    arguments.each do |argument|
      if argument.args[:and] and !first
        str += " + "
      else
        str += ", " if !first
        first = false if first
      end
      
      if argument.is_a?(Code_parser::Argument_grouping)
        str += "(" if argument.contains_groupings?
        
        first_g = true
        argument.args[:arguments].each do |arg_g|
          if arg_g[:type] == :first
            #ignore.
          elsif arg_g[:type] == :and
            str += " + "
          else
            raise "Unknown grouping type: '#{arg_g[:type]}'."
          end
          
          atr_args = {}
          gtype = argument.grouping_type
          atr_args[:typecast] = gtype if gtype
          
          str += self.arguments_to_ruby([arg_g[:arg]], atr_args)
        end
        
        str += ")" if argument.contains_groupings?
      elsif argument.args[:type] == :string
        str += "\"#{argument.args[:value]}\""
      elsif argument.args[:type] == :variable
        str += "#{argument.args[:name]}"
        
        if args[:typecast]
          if args[:typecast] == :string
            str += ".to_s"
          else
            raise "Unknown typecast: '#{args[:typecast]}'."
          end
        end
      else
        raise "Unknown argument-type: '#{argument.class.name}', '#{argument.args[:type]}'."
      end
    end
    
    return str
  end
  
  def string_definition(str_def)
    @str += "#{str_def.args[:sign]}#{str_def.args[:str]}#{str_def.args[:sign]}"
  end
  
  def ruby_class_name(str)
    return "#{str.slice(0, 1).upcase}#{str.slice(1, 999)}"
  end
end