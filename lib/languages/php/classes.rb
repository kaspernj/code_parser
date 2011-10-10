class Code_parser::Language::Php
  def class_parse(class_name)
    class_def = Code_parser::Class_definition.new(
      :name => class_name
    )
    
    @blocks.last.actions << class_def
    @blocks << class_def.block
    @cur_block = class_def.block
    
    self.class_parse_block
  end
  
  def class_parse_block
    
  end
  
  def class_spawn(class_name, var_name)
    args = self.func_args_given
    
    class_spawn = Code_parser::Class_spawn.new(
      :class_name => class_name,
      :var_name => var_name,
      :args => args
    )
    
    @cur_block.actions << class_spawn
  end
  
  def class_obj_func_call(func_name, var_name)
    args = self.func_args_single_given
    
    class_obj_func_call = Code_parser::Class_object_function_call.new(
      :func_name => func_name,
      :args => args,
      :var_name => var_name
    )
    
    @cur_block.actions << class_obj_func_call
  end
end