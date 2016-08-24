defmodule Compiler do
  def run(code = ",.,.,.,.", input = "what") do
    initial = %{
      code: String.codepoints(code),
      input: String.codepoints(input),
      output: [],
      data: [0],
      codeptr: 0,
      dataptr: 0
    }

    state = run_state(initial)

    state[:output] |> Enum.reverse |> Enum.join
  end

  def run_state(state = %{code: code, codeptr: codeptr})
    when codeptr >= length(code), do: state

  def run_state(state = %{code: code, codeptr: codeptr}) do
    cmd = Enum.at(code, codeptr)

    {:ok, state} = Command.command(cmd, state)

    state = %{state | codeptr: codeptr + 1}

    run_state(state)
  end
end
