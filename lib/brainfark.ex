defmodule Brainfark do
  def main(_args) do
    ",.,.,.,."
    |> Lexer.lex
    |> Parser.parse
    |> Interpreter.interpret("what")
    |> IO.inspect

    ",[.,]"
    |> Lexer.lex
    |> Parser.parse
    |> Interpreter.interpret("what")
    |> IO.inspect
  end
end
