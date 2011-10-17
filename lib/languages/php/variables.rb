class Code_parser::Language::Php
  def variable_definition(args)
    #Try to match string definitions.
    if self.match(/\A\s*("|')/)
      str_def = self.variable_match_string
      
      loop do
        if self.matchclear(/\A\s*;\s*/)
          break
        else
          raise "Could not figure out what is next in the variable definition: #{@cont}"
        end
      end
      
      var_def = Code_parser::Variable_definition.new(
        :value => str_def,
        :var_name => args[:var_name]
      )
      
      @cur_block.actions << var_def
    else
      raise "Could not match from: #{@cont}"
    end
  end
  
  def variable_match_string
    if match = self.matchclear(/\A\s*"/)
      str_holder = ""
      
      loop do
        char = @cont.slice(0, 1)
        n_char = @cont.slice(1, 1)
        
        if char == "\\" and n_char == "\""
          str_holder += "\\\""
          @cont = @cont.slice(2, @cont.length)
        elsif char == "\""
          @cont = @cont.slice(1, @cont.length)
          break
        else
          str_holder += char
          @cont = @cont.slice(1, @cont.length)
        end
      end
      
      str_def = Code_parser::String_definition.new(
        :str => str_holder,
        :sign => "\""
      )
    else
      raise "Could not match a string from: #{@cont}"
    end
  end
end