defmodule Brainfark do
  @moduledoc """
  Doesn't do anything yet except run some sample code.

  run_program(",.,.,.,.", "what")
  run_program(",[.[-],]", "Codewars" <> <<0>>)
  """

  @doc """
  Run some Brainfark code with the given input.

  ## Examples

      Brainfark.run(",[.[-],]", "Codewars" <> <<0>>)
  """
  def run(code, input) do
    code
    |> Lexer.lex
    |> Parser.parse
    |> Interpreter.interpret(input)
  end

  @doc """
  Runs the command line input.
  """
  def main(args) do
    args |> parse_args |> process
  end

  # if --help is specified on the command line, drop everything and help them,
  # you never know what could be going terribly wrong for them.
  defp process(:help) do
    IO.puts @moduledoc
    System.halt(1)
  end

  # Process the other options
  defp process({options, files}) do
    input = Map.get(options, :input, "")

    code = if options[:run] do
      options[:run]
    else
      files |> List.first |> open_file
    end

    run(code, input)
  end

  # TODO: Handle invalid file names
  defp open_file(name) do
    {:ok, code} = File.read(name)
    code
  end

  # parse the args
  defp parse_args(args) do
    {options, rest, _} = OptionParser.parse(args, switches: [
      run: :string,
      input: :string,
      help: :boolean
    ], aliases: [
      r: :run,
      i: :input,
      h: :help
    ])

    if options[:help] do
      :help
    else
      {Map.new(options), rest}
    end
  end
end
