require "#{File.dirname(__FILE__)}/functions.rb"

class Code_parser::Language::Php
  def initialize(args = {})
    @cur_block = Code_parser::Block.new
    @blocks = [@cur_block]
    
    @args = args
    @cont = File.read(@args["file"])
    
    @regex_funcname = "([A-z][A-z\d_]*)"
    @regex_varname = "([A-z][A-z\d]*)"
    
    @tabs = 0
    @funcs_started = 0
  end
  
  def parse
    self.search_starttag
    return @blocks.first
  end
  
  def search_starttag
    match = self.matchclear(/\A([\s\S]*?<\?(php|))/)
    if !match
      return nil
    end
    
    self.clear_whitespace
    self.search_newstuff
  end
  
  def tabs
    cont = ""
    0.upto(@tabs - 1) do |count|
      cont += "\t"
    end
    
    return cont
  end
  
  def clear_regex(regex)
    @cont = @cont.gsub(regex, "")
  end
  
  def clear_whitespace
    @cont = @cont.gsub(/\A\s+/, "")
  end
  
  def matchclear(regex, debug = false)
    if match = @cont.match(regex)
      print "Before (#{debug}):\n#{@cont}\n\n" if debug
      @cont = @cont.gsub(regex, "")
      self.clear_whitespace
      print "After (#{debug}):\n#{@cont}\n\n\n" if debug
      
      return match
    end
    
    return false
  end
  
  def search_newstuff
    loop do
      if match = self.matchclear(/\Afunction\s+#{@regex_funcname}\(/)
        self.func_args(match[1])
      elsif match = self.matchclear(/\A(print|echo)\s+/)
        @cur_block.actions << Code_parser::Function_call.new(
          :name => match[1],
          :args => self.func_args_single_given
        )
      elsif match = self.matchclear(/\A\}/)
        @blocks.delete(@blocks.last)
        @cur_block = @blocks.last
      elsif match = self.matchclear(/\A([A-z][A-z\d_]*)\(/)
        @cur_block.actions << Code_parser::Function_call.new(
          :name => match[1],
          :args => self.func_args_given
        )
      elsif match = self.matchclear(/\A\?>/)
        self.search_starttag
      elsif @cont.length <= 0
        break
      else
        raise "Could not find out whats next."
      end
    end
  end
end