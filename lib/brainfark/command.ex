require IEx

defmodule Command do
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
    when is_list(data) and is_integer(dataptr) and dataptr >= 0 do

    dataptr = dataptr - 1

    # data list is assumed by BF to be infinite, so if we pass the beginning,
    # we have to add a char to the beginning of the data to pretend
    {dataptr, data} = if dataptr < 0 do
      {0, [0 | data]}
    else
      {dataptr, data}
    end

    {:ok, %{state | dataptr: dataptr, data: data}}
  end

  def command(",", state = %{data: data, dataptr: dataptr, input: input}) do
    [char | input] = input

    data = if length(data) > 0 do
      List.replace_at(data, dataptr, char)
    else
      [char]
    end

    {:ok, %{state | data: data, input: input}}
  end

  def command("+", state = %{data: data, dataptr: dataptr}) do
    cond do
      !pointer_in_range(state) ->
        {:error, state}
      true ->
        data = List.update_at(data, dataptr, &wrap_increment/1)
        {:ok, %{state | data: data}}
    end
  end

  defp wrap_increment(value) do
    rem(value + 1, 256)
  end

  defp pointer_in_range(%{data: data, dataptr: dataptr}) do
    dataptr >= 0 and dataptr < length(data)
  end
end
