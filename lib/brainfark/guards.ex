defmodule Guards do
  # defmacro pointer_in_range?(%{data: data, dataptr: dataptr} = state) do
  #   quote do
  #     unquote(dataptr) >= 0 and unquote(dataptr) < length(unquote(data))
  #   end
  # end
  #
  defmacro pointer_out_of_range?(_state = %{data: data, dataptr: dataptr}) do # = state) do
    quote do
      unquote(dataptr) < 0 or unquote(dataptr) >= length(unquote(data))
    end
  end

  # this doesn't work, not sure why yet.
  defmacro pointer_out_of_range?(data, dataptr) do
    quote do
      unquote(dataptr) < 0 or unquote(dataptr) >= length(unquote(data))
    end
  end
end
