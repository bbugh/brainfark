defmodule CmdStateTest do
  use ExUnit.Case
  doctest CmdState

  test "new" do
    state = %CmdState{
      code: %ZipperList{cursor: ",", left: [], right: [".", ",", "."]},
      data: %ZipperList{cursor: nil, left: [], right: []},
      input: ["h", "i"],
      output: [],
      stack: []
    }

    assert state == CmdState.new(",.,.", "hi")
  end

  describe "render_output" do
    test "works with characters" do
      state = %CmdState{output: 'krafniarB'}
      assert "Brainfark" == CmdState.render_output(state)
    end

    test "works with binaries" do
      state = %CmdState{output: <<107, 114, 97, 102, 110, 105, 97, 114, 66>>}
      assert "Brainfark" == CmdState.render_output(state)
    end

    test "works without data" do
      state = %CmdState{output: []}
      assert "" == CmdState.render_output(state)
    end
  end
end
