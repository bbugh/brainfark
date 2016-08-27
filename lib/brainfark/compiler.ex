defmodule Compiler do
  # @doc """
  # Tokenizes the input code
  #
  # ## Examples
  #
  #     iex> Compiler.parse(",[.,]")
  #     [:input, :loop_begin, :output, :input, :loop_end]
  # """
  # def parse(code) do
  #   zc = ZipperList.from_list(String.codepoints(code))
  #   ZipperList.foldl zc, [], fn c, acc ->
  #     case c do
  #       "-" -> [{:decrement, nil} | acc]
  #       "+" -> [{:increment, nil} | acc]
  #       "," -> [{:input, nil} | acc]
  #       "." -> [{:output, nil} | acc]
  #       "<" -> [{:move_left, nil} | acc]
  #       ">" -> [{:move_right, nil} | acc]
  #       "[" -> [{:loop_begin, z} | acc]
  #       "]" -> [{:loop_end, nil} | acc]
  #       _ -> [{:error, nil} | acc]
  #     end
  #   end
  # end
  # def run(code = ",.,.,.,.", input = "what") do
  #   initial_state = CmdState.new(code, input)
  #
  #   require IEx
  #   IEx.pry
  #   result = Command.command2(ZipperList.cursor(initial_state.code), initial_state)
  #
  #   CmdState.compile_output(result)
  # end

  # ,[.,]
  # {:input, state}
  # {:start_loop, state}
  # {:output, state}


  # code = ",[.,]"
  # ,[.,]
  #
  #
  # tree(",", tree("[", ".", ",", "]"))

  # def parse(code) do
  #   # Enum.reduce_while(code, 0, fn c, acc ->
  #   #
  #   # end)
  #   Stream.transform(code, [], fn c, acc ->
  #     if c == "[" do
  #       parse(
  #     else
  #       {[c], [c | acc]}
  #     end
  #   end)
  # end

  def run(code = ",.,.,.,.", input = "what") do
    initial = %{
      code: code |> String.codepoints |> ZipperList.from_list,
      input: String.codepoints(input),
      output: [],
      data: [0],
      codeptr: 0,
      dataptr: 0
    }

    state = run_state(initial)

    state[:output] |> Enum.reverse |> Enum.join
  end

  def run_state(state = %{code: code}) do
    if ZipperList.end?(code) do
      state
    else
      {:ok, state} = Command.command(code.cursor, state)
      run_state(%{state | code: ZipperList.right(state.code)})
    end
  end


  # def run_state(state = %{code: code, codeptr: codeptr}) do
  #   cmd = Enum.at(code, codeptr)
  #
  #   {:ok, state} = Command.command(cmd, state)
  #
  #   state = %{state | codeptr: codeptr + 1}
  #
  #   run_state(state)
  # end
end
