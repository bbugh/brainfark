defmodule InterpreterTest do
  use ExUnit.Case
  doctest Interpreter

  # program: ,.,.,.,.
  test "interpret basic program without loop" do
    program = [:input, :output, :input, :output, :input, :output, :input,
      :output]
    result = Interpreter.interpret(program, "what")

    assert result == %CmdState{code: %ZipperList{cursor: nil,
      left: [:output, :input, :output, :input, :output, :input, :output, :input],
      right: []}, data: %ZipperList{cursor: 116, left: [], right: []}, input: [],
      output: [116, 97, 104, 119], stack: []}
  end

  # program: ,[.,]
  test "interpret with loop" do
    program = [:input, :loop_begin, :output, :input, :loop_end]
    result = Interpreter.interpret(program, "what")

    assert result == %CmdState{code: %ZipperList{cursor: nil,
      left: [:loop_end, :input, :output, :loop_begin, :input], right: []},
      data: %ZipperList{cursor: 0, left: [], right: []}, input: [],
      output: [116, 97, 104, 119], stack: []}
  end

  # program: ,[.[-],]
  test "interpret with nested loop" do
    program = [:input, :loop_begin, :output, :loop_begin, :decrement, :loop_end,
               :input, :loop_end]

    result = Interpreter.interpret(program, "Codewars" <> <<0>>)
  end

  # program: ,>,<[>[->+>+<<]>>[-<<+>>]<<<-]>>.
  test "interpret really tough one" do
    program = [:input, :move_right, :input, :move_left, :loop_begin,
      :move_right, :loop_begin, :decrement, :move_right, :increment,
      :move_right, :increment, :move_left, :move_left, :loop_end, :move_right,
      :move_right, :loop_begin, :decrement, :move_left, :move_left, :increment,
      :move_right, :move_right, :loop_end, :move_left, :move_left, :move_left,
      :decrement, :loop_end, :move_right, :move_right, :output]

    result = Interpreter.interpret(program, <<8, 9>>)
    assert %CmdState{data: %ZipperList{cursor: 72}} = result
  end
end
