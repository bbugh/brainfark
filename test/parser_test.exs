defmodule ParserTest do
  use ExUnit.Case
  doctest Parser

  describe "build_tree" do
    test "it works with no loops loop" do
      program = [:input,  :output, :input, :output]

      assert program == Parser.build_tree(program)
    end

    test "it works with one loop" do
      program = [:input, [:loop_begin, :output, :input, :loop_end]]

      assert program == Parser.build_tree(List.flatten(program))
    end

    test "it works with nested loops" do
      tokens = [:input, :loop_begin, :output, :loop_begin, :decrement, :loop_end, :input, :loop_end]
      program = [:input, [:loop_begin, :output, [:loop_begin, :decrement, :loop_end], :input, :loop_end]]

      assert program == Parser.build_tree(tokens)
    end
  end

  describe "parse" do
    test "passes valid programs" do
      assert [:input, :output] = Parser.parse([:input, :output])
    end

    test "fails empty programs" do
      assert_raise SyntaxError, ~r/empty program/, fn ->
        Parser.parse([])
      end
    end

    test "fails missing loop ending" do
      assert_raise SyntaxError, ~r/unmatched ending/, fn ->
        Parser.parse([:loop_begin, :input])
      end
    end

    test "fails missing loop beginning" do
      assert_raise SyntaxError, ~r/unmatched beginning/, fn ->
        Parser.parse([:input, :loop_end])
      end
    end

    test "catches multiple missing beginnings" do
      assert_raise SyntaxError, ~r/unmatched beginning/, fn ->
        Parser.parse([:loop_begin, :loop_begin, :loop_end, :loop_end, :loop_end, :input])
      end
    end

    test "catches multiple missing ends" do
      assert_raise SyntaxError, ~r/unmatched ending/, fn ->
        Parser.parse([:loop_begin, :loop_begin, :loop_begin, :loop_end, :loop_end, :input])
      end
    end

    test "catches out of order loops" do
      assert_raise SyntaxError, ~r/unmatched beginning/, fn ->
        Parser.parse([:loop_begin, :loop_end, :loop_end, :loop_begin, :loop_end])
      end
    end
  end
end
