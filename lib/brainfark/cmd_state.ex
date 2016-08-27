defmodule CmdState do
  @moduledoc """
  The structure for keeping state of the interpreter.
  """
  @type t :: %CmdState{code: ZipperList.t, data: ZipperList.t, input: list, output: list}
  defstruct code: %ZipperList{},
            data: %ZipperList{},
            input: [],
            output: []

  @doc """
  Create a new CmdState structure from a code set and input.

  ## Examples

      iex> CmdState.new(",.,.", "hi")
      %CmdState{code: %ZipperList{left: [], right: [",", ".", ",", "."]},
        data: %ZipperList{left: [], right: []}, input: ["h", "i"], output: []}
  """
  @spec new(String.t, String.t) :: ZipperList.t
  def new(code, input) do
    %CmdState{
      code: code |> String.codepoints |> ZipperList.from_list,
      input: String.codepoints(input)
    }
  end

  def compile_output(%CmdState{output: output}) do
    output |> Enum.reverse |> Enum.join
  end
end
