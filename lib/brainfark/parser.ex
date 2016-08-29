defmodule Parser do
  @moduledoc """
  Parser for the Brainfark language.

  The primary function is `Parser.parse/1`, which takes a list of tokens and
  validates that it is a plausible program. This will only catch syntax
  errors, not runtime errors.

  """

  @doc """
  Parses a list of Brainfark tokens to check for syntax errors. Raises
  SyntaxError for any issues.

  ## Examples

      iex> Parser.parse([:input, :loop_begin, :input, :output, :loop_end])
      [:input, :loop_begin, :input, :output, :loop_end]
  """
  @spec parse(list(atom())) :: list()
  def parse([]) do
    raise SyntaxError, description: "Invalid syntax: empty program"
  end

  def parse(tokens) do
    remaining = tokens |> Enum.reduce(0, &count_loops/2)

    if remaining > 0 do
      raise SyntaxError, description: "Invalid syntax: Loop beginning with unmatched ending"
    else
      tokens
    end
  end

  # def parse2(tokens) do
  #    tokens |> parse |> build_tree
  # end

  @doc """
  Create a tree out of tokens. Currently not used by the interpreter, but
  it's here because it was a hell of a lot of work to get this to happen.

  ## Examples

      iex> Parser.build_tree([:input, :loop_begin, :input, :output, :loop_end])
      [:input, [:loop_begin, :input, :output, :loop_end]]
  """
  def build_tree(tokens), do: do_tree(tokens, [])

  defp do_tree([], acc), do: Enum.reverse(acc)

  defp do_tree([:loop_begin|rest], acc) do
    {rest, new_acc} = do_tree(rest, [:loop_begin])
    do_tree(rest, [new_acc | acc])
  end

  defp do_tree([:loop_end|rest], acc) do
    {rest, Enum.reverse([:loop_end | acc])}
  end

  defp do_tree([t|rest], acc), do: do_tree(rest, [t | acc])

  # Increments or decrements the loop count based on the tokens, with awareness
  # of mismatched and out of order loop tokens.
  @spec count_loops(atom(), integer()) :: integer()
  defp count_loops(token, count) do
    case token do
      :loop_begin -> count + 1
      :loop_end when count > 0 -> count - 1
      :loop_end -> raise SyntaxError, description: "Invalid syntax: Loop ending with unmatched beginning"
      _ -> count
    end
  end
end
