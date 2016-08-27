defmodule Lexer do
  @moduledoc """
  Lexer for the Brainfark language.

  The primary function is `Lexer.lex/1`, which turns a string or list of
  codepoints into a parsable Brainfark program. Invalid characters (including
  whitespace) are ignored.

  """

  @doc """
  Tokenizes a Brainfark program from a string or a list of codepoints.

  This ignores anything that isn't valid Brainfark syntax.

  ## Examples

      iex> Lexer.lex(",[.,]")
      [:input, :loop_begin, :output, :input, :loop_end]
  """
  @spec lex(code :: String.t) :: list
  def lex(code) when is_binary(code) do
    code
    |> String.codepoints()
    |> lex
  end

  @spec lex(code :: list) :: list
  def lex(code) when is_list(code) do
    code
    |> Enum.reduce([], &filter_token/2)
    |> Enum.reverse
  end

  # Filters any items that aren't commands
  defp filter_token(cmd, list) do
    if token = tokenize(cmd) do
      [token | list]
    else
      list
    end
  end

  @tokens %{
    "," => :input,
    "." => :output,
    "[" => :loop_begin,
    "]" => :loop_end,
    "<" => :move_left,
    ">" => :move_right,
    "-" => :decrement,
    "+" => :increment
  }

  @doc """
  Turns a Brainfark command into a parseable token atom.

  ## Examples

      iex> Lexer.tokenize(",")
      :input

      iex> Lexer.tokenize("[")
      :loop_begin

      iex> Lexer.tokenize("a")
      nil
  """
  @spec tokenize(binary()) :: atom()
  def tokenize(<<cmd :: binary-size(1)>>) do
    @tokens[cmd]
  end
end
