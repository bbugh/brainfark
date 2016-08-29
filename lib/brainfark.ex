defmodule Brainfark do
  @moduledoc """
  Doesn't do anything yet except run some sample code.
  """

  def main(_args) do
    IO.write "'what' |> ,.,.,.,. -> "

    ",.,.,.,."
    |> Lexer.lex
    |> Parser.parse
    |> Interpreter.interpret("what")
    |> CmdState.render_output
    |> IO.puts

    IO.write "'what' |> ,[.,] -> "

    ",[.,]"
    |> Lexer.lex
    |> Parser.parse
    |> Interpreter.interpret("what")
    |> CmdState.render_output
    |> IO.puts

    IO.write "'Codewars' <> <<0>> |> ,[.[-],] -> "

    ",[.[-],]"
    |> Lexer.lex
    |> Parser.parse
    |> Interpreter.interpret("Codewars" <> <<0>>)
    |> CmdState.render_output
    |> IO.puts
  end
end
