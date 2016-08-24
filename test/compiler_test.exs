defmodule CompilerTest do
  use ExUnit.Case
  doctest Compiler

  test "run" do
    assert Compiler.run(",.,.,.,.", "what") == "what"
  end
end
