defmodule Parser do
  @moduledoc """
  Parser for the Brainfark language.

  The primary function is `Parser.parse/1`, which takes a list of tokens and
  validates that it is a plausible program. This will only catch compiler
  errors, not runtime errors.

  """

  @doc """
  Parses a list of Brainfark tokens to check for syntax errors. Raises
  CompileError for any issues.

  ## Examples

      iex> Parser.parse([:input, :loop_begin, :input, :output, :loop_end])
      [:input, :loop_begin, :input, :output, :loop_end]
  """
  @spec parse(list(atom())) :: list()
  def parse([]) do
    raise CompileError, description: "Can't run an empty program."
  end

  def parse(tokens) do
    remaining = tokens |> Enum.reduce(0, &count_loops/2)

    if remaining > 0 do
      raise CompileError, description: "Loop beginning with unmatched ending."
    else
      tokens
    end
  end

  @spec count_loops(atom(), integer()) :: integer()
  defp count_loops(token, count) do
    case token do
      :loop_begin -> count + 1
      :loop_end when count > 0 -> count - 1
      :loop_end -> raise CompileError, description: "Loop ending with unmatched beginning."
      _ -> count
    end
  end
end
