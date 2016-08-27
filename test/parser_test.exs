defmodule ParserTest do
  use ExUnit.Case
  doctest Parser

  describe "parse" do
    test "passes valid programs" do
      assert [:input, :output] = Parser.parse([:input, :output])
    end

    test "fails empty programs" do
      assert_raise CompileError, ~r/empty program/, fn ->
        Parser.parse([])
      end
    end

    test "fails missing loop ending" do
      assert_raise CompileError, ~r/unmatched ending/, fn ->
        Parser.parse([:loop_begin, :input])
      end
    end

    test "fails missing loop beginning" do
      assert_raise CompileError, ~r/unmatched beginning/, fn ->
        Parser.parse([:input, :loop_end])
      end
    end

    test "catches multiple missing beginnings" do
      assert_raise CompileError, ~r/unmatched beginning/, fn ->
        Parser.parse([:loop_begin, :loop_begin, :loop_end, :loop_end, :loop_end, :input])
      end
    end

    test "catches multiple missing ends" do
      assert_raise CompileError, ~r/unmatched ending/, fn ->
        Parser.parse([:loop_begin, :loop_begin, :loop_begin, :loop_end, :loop_end, :input])
      end
    end

    test "catches out of order loops" do
      assert_raise CompileError, ~r/unmatched beginning/, fn ->
        Parser.parse([:loop_begin, :loop_end, :loop_end, :loop_begin, :loop_end])
      end
    end
  end
end
