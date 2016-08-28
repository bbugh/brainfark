defmodule Interpreter do
  # @doc """
  # Tokenizes the input code
  #
  # ## Examples
  #
  #     iex> Interpreter.parse(",[.,]")
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

  # ",[.,]" |> Lexer.lex |> Parser.parse |> Interpreter.interpret("what")

  def interpret(program, input) do
    # initial_state = %CmdState{
    #   code: program |> ZipperList.from_list,
    #   data: %ZipperList{cursor: 0},
    #   input: String.codepoints(input),
    #   output: []
    # }

    # stack = do_interpret(initial_state)

    # result = %CmdState{output: output} = hd(stack)

    do_interpret(%CmdState{
      code: program |> ZipperList.from_list,
      data: %ZipperList{cursor: 0},
      input: String.codepoints(input),
      output: []
    })

    # {:ok, output |> Enum.reverse |> Enum.join, result, stack}
  end

  def do_interpret(state = %CmdState{code: %ZipperList{cursor: nil}}), do: state
  def do_interpret(state = %CmdState{stack: stack}) do
    # IO.write "#{state.code.cursor} -> :"
    {action, state} = do_command(state)

    # IO.inspect [action, state.input, state.output]
    code = case action do
      :cont -> ZipperList.right(state.code)
      :loop -> state.code
      :break -> state.code
    end

    state = %{state | code: code}
    do_interpret(state)
  end

  def do_command(state = %CmdState{code: code}) do
    case code.cursor do
      :input -> do_input(state)
      :output -> do_output(state)
      :loop_begin -> do_loop_begin(state)
      :loop_end -> do_loop_end(state)
    end
  end

  def do_input(state = %CmdState{input: []}) do
    {:cont, %{state | data: ZipperList.replace(state.data, 0)}}
  end

  def do_input(state = %CmdState{input: [char | input]}) do
    {:cont, %{state | input: input, data: ZipperList.replace(state.data, char)}}
  end

  def do_output(state = %CmdState{data: data, output: output}) do
    {:cont, %{state | output: [data.cursor | output]}}
  end

  def do_loop_begin(state = %CmdState{code: code, data: data, stack: stack}) do
    # FIXME: This might be an error because data.cursor might be nil
    if data.cursor == nil do
      raise "expected the unexpected"
    end

    if data.cursor == 0 do
      [new_code | stack] = stack
      {:break, %{state | code: new_code, stack: stack}}
    else
      stack = if Enum.empty?(stack) do
        [code]
      else
        [code | tl(stack)]
      end
      {:cont, %{state | stack: stack}}
    end
  end

  def do_loop_end(state = %CmdState{data: data, code: code, stack: stack}) do
    if data.cursor != 0 do
      [new_code | stack] = stack
      {:loop, %{state | code: new_code, stack: [code | stack]}}
    else
      {:cont, %{state | stack: tl(state.stack)}}
    end
  end



  # def do_interpret2(state, stack \\ [])
  # def do_interpret2(%CmdState{code: %ZipperList{cursor: nil}}, stack), do: stack
  # def do_interpret2(state, stack) do
  #   IO.puts "[Run] :#{state.code.cursor}"
  #
  #   stack = [state | stack]
  #
  #   # run
  #   # {action, state} = Code.command(state)
  #
  #
  #   # update
  #   # case action do
  #   #   :cont -> state = %{state | code: ZipperList.right(state.code)}
  #   #   :loop ->
  #   #   :break ->
  #   # end
  #   state = %{code: ZipperList.right(state.code)}
  #
  #   # loop
  #   do_interpret2(state, stack)
  # end
  #
  # def do_interpret(state = %CmdState{}), do: do_interpret([state])
  # def do_interpret(stack) when is_list(stack) do
  #   state = List.first(stack)
  #
  #   IO.puts "[Running] :#{state.code.cursor}"
  #
  #   # {action, state} = Command.command(state.code.cursor)
  #   # case action do
  #   #   :cont -> state = %{state | code: ZipperList.right(state.code)}
  #   #   :loop ->
  #   #   :break ->
  #   # end
  #   state = %{state | code: ZipperList.right(state.code)}
  #
  #   if state.code.cursor == nil do
  #     stack
  #   else
  #     do_interpret([state | stack])
  #   end
  # end
  #
  # def run(code = ",.,.,.,.", input = "what") do
  #   initial = %{
  #     code: code |> String.codepoints |> ZipperList.from_list,
  #     input: String.codepoints(input),
  #     output: [],
  #     data: [0],
  #     codeptr: 0,
  #     dataptr: 0
  #   }
  #
  #   state = run_state(initial)
  #
  #   state[:output] |> Enum.reverse |> Enum.join
  # end
  #
  # def run_state(state = %{code: code}) do
  #   if ZipperList.end?(code) do
  #     state
  #   else
  #     {:ok, state} = Command.command(code.cursor, state)
  #     run_state(%{state | code: ZipperList.right(state.code)})
  #   end
  # end


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
