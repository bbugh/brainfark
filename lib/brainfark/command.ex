require IEx

defmodule Command do
  import Guards

  def command(_, state = %{data: []}), do: {:error, state}

  def command(">", state = %{data: data, dataptr: dataptr})
    when is_list(data) and is_integer(dataptr) and dataptr >= 0 do

    dataptr = dataptr + 1

    # data list is assumed to be infinite, so if we passed the end, we have to
    # add a char to the end of the data to pretend
    data = if dataptr > (length(data) - 1) do
      data ++ [0]
    else
      data
    end

    {:ok, %{state | dataptr: dataptr, data: data}}
  end

  def command("<", state = %{data: data, dataptr: dataptr})
    when is_list(data)
    and is_integer(dataptr)
    and dataptr >= 0, do: do_left_move(state)

  # BF assumes the data buffer is infinite, so if we are past the beginning,
  # we have to add a char to the beginning of the data to pretend that
  defp do_left_move(state = %{data: data, dataptr: 0}) do
    {:ok, %{state | data: [0 | data]}}
  end

  defp do_left_move(state = %{dataptr: dataptr}) do
    {:ok, %{state | dataptr: dataptr - 1}}
  end

  def command(",", state = %{data: data, dataptr: dataptr, input: [char | input]}) do
    data = List.replace_at(data, dataptr, char)

    {:ok, %{state | data: data, input: input}}
  end

  def command("+", %{data: data, dataptr: dataptr} = state),
    do: do_add_command(state, data, dataptr)

  defp do_add_command(state, data, dataptr)
    when pointer_out_of_range?(data, dataptr), do: {:error, state}

  defp do_add_command(state, data, dataptr) do
    data = List.update_at(data, dataptr, &wrap_increment/1)
    {:ok, %{state | data: data}}
  end

  def command("-", %{data: data, dataptr: dataptr} = state)
    when pointer_out_of_range?(data, dataptr), do: {:error, state}

  def command("-", state = %{data: data, dataptr: dataptr}) do
    data = List.update_at(data, dataptr, &wrap_decrement/1)
    {:ok, %{state | data: data}}
  end

  def command(".", state = %{data: data, dataptr: dataptr, output: output}) do
    {:ok, %{state | output: [Enum.at(data, dataptr) | output]}}
  end

  def command("[", state = %{data: data, dataptr: dataptr}) do
    if Enum.at(data, dataptr) == 0 do
      #ZipperTree.right
      {:skip, state}
    else
      #ZipperTree.up |> ZipperTree.right
      {:ok, state}
    end
  end

  def command("]", state = %{data: data, dataptr: dataptr}) do
    if Enum.at(data, dataptr) == 0 do
      {:loop, state}
    else
      {:ok, state}
    end
  end

  defp wrap_increment(value) when value >= 255, do: 0
  defp wrap_increment(value), do: value + 1

  defp wrap_decrement(value) when value <= 0, do: 255
  defp wrap_decrement(value), do: value - 1
end
