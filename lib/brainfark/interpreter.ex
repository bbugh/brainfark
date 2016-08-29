defmodule Interpreter do
  @moduledoc """

  ## Examples
      iex> ",[.,]"
      ...> |> Lexer.lex
      ...> |> Parser.parse
      ...> |> Interpreter.interpret("what?")
      %CmdState{code: %ZipperList{cursor: nil,
        left: [:loop_end, :input, :output, :loop_begin, :input],
        right: []}, data: %ZipperList{cursor: 0, left: [], right: []},
        input: [], output: '?tahw', stack: []}
  """

  @doc """
  Interpret a parsed Brainfark program.

  See above for examples.

  To turn the output into text, pass the final state to
  `CmdState.render_output/1` and it will convert it into a string.
  """
  def interpret(program, input) do
    do_interpret(%CmdState{
      code: program |> ZipperList.from_list,
      data: %ZipperList{cursor: 0},
      input: String.codepoints(input),
      output: []
    })
  end

  # This happens when the code has finished executing, cursor will be nil
  defp do_interpret(state = %CmdState{code: %ZipperList{cursor: nil}}), do: state

  # If anything else is happening, then do_interpret will recurse
  defp do_interpret(state = %CmdState{}) do
    {action, state} = Command.command(state)

    # Act on the stack based on the command's control action
    state = case action do
      :continue -> continue(state)
      :continue_loop -> continue_loop(state)
      :restart_loop -> restart_loop(state)
      :end_loop -> end_loop(state)
      #:break -> break(state) # NoOp, but part of the spec
    end

    do_interpret(state)
  end

  # Just go to the next command
  defp continue(state = %CmdState{code: code}) do
    %{state | code: ZipperList.right(code)}
  end

  # NoOp - never seems to be called, but is supposedly correct...
  # # On break, pop the stack and go to the next item after the bracket
  # defp break(state = %CmdState{stack: stack}) do
  #   [end_bracket | stack] = stack
  #   %{state | code: end_bracket |> continue, stack: stack}
  # end

  # This is when a loop starts, or begins again after :restart_loop
  # If the last stack item was a :loop_end, it will pop the stack, otherwise,
  # it will add the current :loop_begin state onto the stack.
  defp continue_loop(state = %CmdState{code: code, stack: stack}) do
    stack = cond do
      Enum.empty?(stack) -> [code]
      List.first(stack).cursor == :loop_end -> [code | tl(stack)]
      true -> [code | stack]
    end

    continue(%{state | stack: stack})
  end

  # The loop is over, let's quit now and move on to the next item.
  defp end_loop(state = %CmdState{stack: stack}) do
    %{state | stack: tl(stack)} |> continue
  end

  # The loop should start again, go back to :loop_begin
  defp restart_loop(state = %CmdState{stack: stack, code: code}) do
    [new_code | stack] = stack
    %{state | code: new_code, stack: [code | stack]}
  end
end
