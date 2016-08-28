defmodule InterpreterTest do
  use ExUnit.Case
  doctest Interpreter

  test "interpret" do
    program = [:input, :loop_begin, :output, :input, :loop_end]
    result = Interpreter.interpret(program, "what")

    assert result == %CmdState{code: %ZipperList{cursor: nil,
      left: [:loop_end, :input, :output, :loop_begin, :input], right: []},
      data: %ZipperList{cursor: 0, left: [], right: []}, input: [],
      output: ["t", "a", "h", "w"], stack: []}
  end
end
