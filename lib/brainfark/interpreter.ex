defmodule Interpreter do
  @moduledoc """
  Interprets a Brainfark program.

  To turn the output into text, pass the final state to
  `CmdState.render_output/1` and it will convert it into a string.
  """

  @doc """
  Interpret a parsed Brainfark program.
  """
  def interpret(program), do: interpret(program, "")

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
    # IO.inspect action

    # Act on the stack based on the command's control action
    state = case action do
      :continue -> continue(state)
      :break -> find_loop_end(state)
      :restart -> find_loop_begin(state)
    end

    do_interpret(state)
  end

  # Just go to the next command
  defp continue(state = %CmdState{code: code}) do
    %{state | code: ZipperList.right(code)}
  end

  # Traverses backwards to find the current loop's beginning
  defp find_loop_begin(state = %CmdState{code: code}) do
    code = code
      |> ZipperList.reverse
      |> do_find_loop(:loop_end, :loop_begin)
      |> ZipperList.reverse
    %{state | code: code}
  end

  # traverse forward to find the current loop's ending
  defp find_loop_end(state = %CmdState{code: code}) do
    code = do_find_loop(code, :loop_begin, :loop_end)
    %{state | code: code}
  end

  # traverse to find the matching end token
  defp do_find_loop(code, start_token, end_token) do
    Enum.reduce_while(code, 0, fn(z, i) ->
      case {z.cursor, i} do
        {^start_token, _} -> {:cont, i + 1}
        {^end_token, 1} -> {:halt, z}
        {^end_token, _} -> {:cont, i - 1}
        _ -> {:cont, i}
      end
    end)
  end
end
