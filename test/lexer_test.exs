defmodule LexerTest do
  use ExUnit.Case
  doctest Lexer

  describe "lex" do
    test "ignores newline chars" do
      assert Lexer.lex("\n,\t.\b") == [:input, :output]
    end

    test "ignores invalid chars" do
      assert Lexer.lex("a,$.") == [:input, :output]
    end

    test "parses all tokens" do
      assert Lexer.lex(",.[]<>-+") == [:input, :output, :loop_begin, :loop_end,
        :move_left, :move_right, :decrement, :increment]
    end

    test "can take a list or a string" do
      assert Lexer.lex(",.") == [:input, :output]
      assert Lexer.lex([",", "."]) == [:input, :output]
    end
  end

  describe "tokenize" do
    test "it returns nil for unexpected tokens" do
      assert Lexer.tokenize("a") == nil
      assert Lexer.tokenize("$") == nil
    end

    test "it rejects items longer than single tokens" do
      assert_raise FunctionClauseError, fn ->
        Lexer.tokenize("asdf")
      end
    end

    test "it returns :input for ','" do
    	assert Lexer.tokenize(",") == :input
    end

    test "it returns :output for '.'" do
    	assert Lexer.tokenize(".") == :output
    end

    test "it returns :loop_begin for '['" do
    	assert Lexer.tokenize("[") == :loop_begin
    end

    test "it returns :loop_end for ']'" do
    	assert Lexer.tokenize("]") == :loop_end
    end

    test "it returns :move_left for '<'" do
    	assert Lexer.tokenize("<") == :move_left
    end

    test "it returns :move_right for '>'" do
    	assert Lexer.tokenize(">") == :move_right
    end

    test "it returns :decrement for '-'" do
    	assert Lexer.tokenize("-") == :decrement
    end

    test "it returns :increment for '+'" do
    	assert Lexer.tokenize("+") == :increment
    end
  end
end
