<?
	function my_function($arg){
		print "Hejsa.\n";
		print $arg . "\n";
	}
	
	class my_class{
    function __construct($arg1, $arg2){
      print "Constructed! " . $arg1 . " - " . $arg2 . "\n";
    }
    
    function test_func($arg, $arg2){
      print "Test: " . $arg . "\n";
      print "Test 2: " . $arg2 . $arg . "\n";
    }
	}
	
	my_function("Hello world.");
	
	$obj = new my_class("test 1", "test 2");
	$obj->test_func("test 1", "test 2");
	
	unset($obj);
?>