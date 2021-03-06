defmodule Command do
  @moduledoc """
  Runs Brainfark command tokens on the current state.
  """

  @doc """
  Runs the current state's command on the current state and returns a tuple
  containing the next action and new state.

  ## Example

      iex> state = %CmdState{code: %ZipperList{cursor: :loop_begin},
      ...>                   data: %ZipperList{cursor: 97}}
      iex> Command.command(state)
      {:continue, %CmdState{code: %ZipperList{cursor: :loop_begin},
                                 data: %ZipperList{cursor: 97}}}
  """
  def command(state = %CmdState{code: code}) do
    case code.cursor do
      :input -> input(state)
      :output -> output(state)
      :decrement -> decrement(state)
      :increment -> increment(state)
      :move_left -> move_left(state)
      :move_right -> move_right(state)
      :loop_begin -> loop_begin(state)
      :loop_end -> loop_end(state)
    end
  end


  # This implementation uses the "leave the cell unchanged" option.
  #
  # "Note: It is strongly recommended that an interpreter be configurable to all
  # three normal form of EOF (Zero, minus one and unchanged)."
  # See https://esolangs.org/wiki/brainfuck#EOF
  #
  # TODO: Added the three different EOF modes as an option
  defp input(state = %CmdState{input: []}) do
    {:continue, state}
  end

  # If input has data, unshift the front and replace the current data position
  # with the value of the character
  defp input(state = %CmdState{input: [<<char::utf8>> | input]}) do
    {:continue,
      %{state | input: input, data: ZipperList.replace(state.data, char)}}
  end

  # Adds the current data's value to the output array. Does not modify the
  # data itself.
  defp output(state = %CmdState{data: data, output: output}) do
    [data.cursor] |> to_string |> IO.write
    {:continue, %{state | output: [data.cursor | output]}}
  end

  # Decrement the current data value by 1. Safe to call when there is no data.
  defp decrement(state = %CmdState{data: data}) do
    data = ZipperList.safe_cursor(data, 0)
    new_value = wrap_decrement(data.cursor)
    {:continue, %{state | data: ZipperList.replace(data, new_value)}}
  end

  # Increment the current data value by 1. Safe to call when there is no data.
  defp increment(state = %CmdState{data: data}) do
    data = ZipperList.safe_cursor(data, 0)
    new_value = wrap_increment(data.cursor)
    {:continue, %{state | data: ZipperList.replace(data, new_value)}}
  end

  # Move "left" down the data list. Raises an error if going left too far.
  defp move_left(state = %CmdState{data: data}) do
    if ZipperList.beginning?(data) do
      raise RuntimeError, message: "Memory border underflow"
    end

    data = data |> ZipperList.left |> ZipperList.safe_cursor(0)
    {:continue, %{state | data: data}}
  end

  # Move "right" down the data list. Expands as necessary.
  defp move_right(state = %CmdState{data: data}) do
    data = data |> ZipperList.right |> ZipperList.safe_cursor(0)
    {:continue, %{state | data: data}}
  end

  # If the data is 0, break from the loop and go to the matching ]. If data is
  # not zero, continue to run the loop.
  defp loop_begin(state = %CmdState{data: data}) do
    if data.cursor == 0 do
      {:break, state}
    else
      {:continue, state}
    end
  end

  # If the data is non-zero, restart the loop. If the data is 0, end the loop
  # and run the next command.
  defp loop_end(state = %CmdState{data: data}) do
    if data.cursor != 0 do
      {:restart, state}
    else
      {:continue, state}
    end
  end

  # Brainfark requires the values of the data cursor to be 0 <= x < 256, and
  # expects it to wrap around.
  defp wrap_increment(value) when value >= 255, do: 0
  defp wrap_increment(value), do: value + 1

  # Brainfark requires the values of the data cursor to be 0 <= x < 256, and
  # expects it to wrap around.
  defp wrap_decrement(value) when value <= 0, do: 255
  defp wrap_decrement(value), do: value - 1
end
