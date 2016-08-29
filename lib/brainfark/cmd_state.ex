defmodule CmdState do
  @moduledoc """
  The structure for keeping state of the interpreter.
  """
  @type t :: %CmdState{code: ZipperList.t, data: ZipperList.t, stack: [],
    input: list, output: list}

  defstruct code: %ZipperList{},
            data: %ZipperList{},
            stack: [],
            input: [],
            output: []

  @doc """
  Create a new CmdState structure from a code set and input.

  ## Examples

      iex> CmdState.new(",.,.", "hi")
      %CmdState{data: %ZipperList{cursor: nil, left: [], right: []},
       code: %ZipperList{cursor: ",", left: [], right: [".", ",", "."]},
       input: ["h", "i"], output: [], stack: []}
  """
  @spec new(String.t, String.t) :: CmdState.t
  def new(code, input) do
    %CmdState{
      code: code |> String.codepoints |> ZipperList.from_list,
      input: String.codepoints(input)
    }
  end

  @doc """
  Turns the output array from a command state into a readable string.

  ## Examples

      iex> CmdState.render_output(%CmdState{output: 'krafniarB'})
      "Brainfark"
  """
  @spec render_output(CmdState.t) :: String.t
  def render_output(%CmdState{output: output}) do
    output |> to_string |> String.reverse
  end
end
