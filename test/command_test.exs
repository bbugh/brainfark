defmodule CommandTest do
  use ExUnit.Case
  doctest Command

  defp create_command(command_cursor, data_cursor) do
    %CmdState{code: %ZipperList{cursor: command_cursor},
              data: %ZipperList{cursor: data_cursor}}
  end

  describe ", capture" do
    test "input should have the front char removed" do
      cmd = %{create_command(:input, nil) | input: String.codepoints("hello")}
      {_, %CmdState{input: input}} = Command.command(cmd)
      assert input == ["e", "l", "l", "o"]
    end

    test "it should replace the current data ptr location with the first input" do
      cmd = %{create_command(:input, 98) | input: String.codepoints("hello")}
      {_, %CmdState{data: data}} = Command.command(cmd)
      assert data.cursor == 104
    end

    test "returns :continue action" do
      cmd = %{create_command(:input, 98) | input: String.codepoints("hello")}
      assert {:continue, _} = Command.command(cmd)
    end
  end

  describe ". output value" do
    test "it adds the current data character to the output list" do
      cmd = %{create_command(:output, 98) | output: [97]}
      {_, %CmdState{output: output}} = Command.command(cmd)
      assert output == [98, 97]
    end

    test "returns :continue action" do
      cmd = %{create_command(:output, 98) | output: [97]}
      assert {:continue, _} = Command.command(cmd)
    end
  end

  describe "- decrement value" do
    test "decrements the data at the data ptr location" do
      cmd = create_command(:decrement, 100)
      {_, %CmdState{data: data}} = Command.command(cmd)
      assert data.cursor == 99
    end

    test "safely returns 255 when cursor is nil" do
      cmd = create_command(:decrement, nil)
      {_, %CmdState{data: data}} = Command.command(cmd)
      assert data.cursor == 255
    end

    test "returns 255 when cursor is 0" do
      cmd = create_command(:decrement, 0)
      {_, %CmdState{data: data}} = Command.command(cmd)
      assert data.cursor == 255
    end

    test "returns :continue action" do
      cmd = create_command(:decrement, 100)
      assert {:continue, _} = Command.command(cmd)
    end
  end

  describe "+ increment value" do
    test "increments the data at the data ptr location" do
      cmd = create_command(:increment, 100)
      {_, %CmdState{data: data}} = Command.command(cmd)
      assert data.cursor == 101
    end

    test "safely returns 1 when cursor is nil" do
      cmd = create_command(:increment, nil)
      {_, %CmdState{data: data}} = Command.command(cmd)
      assert data.cursor == 1
    end

    test "returns 0 when cursor is 255" do
      cmd = create_command(:increment, 255)
      {_, %CmdState{data: data}} = Command.command(cmd)
      assert data.cursor == 0
    end

    test "returns :continue action" do
      cmd = create_command(:increment, 100)
      assert {:continue, _} = Command.command(cmd)
    end
  end

  describe "< decrement data pointer" do
    test "it moves the data pointer down" do
      cmd = %CmdState{code: %ZipperList{cursor: :move_left},
                      data: %ZipperList{left: [1], cursor: 2}}
      {_, %CmdState{data: data}} = Command.command(cmd)
      assert data.cursor == 1
    end

    test "safely defaults to 0 when it can't move left more" do
      cmd = %CmdState{code: %ZipperList{cursor: :move_left},
                      data: ZipperList.empty}
      {_, %CmdState{data: data}} = Command.command(cmd)
      assert data.cursor == 0
    end

    test "returns :continue action" do
      cmd = %CmdState{code: %ZipperList{cursor: :move_left},
                      data: ZipperList.empty}
      assert {:continue, _} = Command.command(cmd)
    end
  end

  describe "> increment data pointer" do
    test "it moves the data pointer up" do
      cmd = %CmdState{code: %ZipperList{cursor: :move_right},
                      data: %ZipperList{cursor: 2, right: [1]}}
      {_, %CmdState{data: data}} = Command.command(cmd)
      assert data.cursor == 1
    end

    test "safely defaults to 0 when it can't move right more" do
      cmd = %CmdState{code: %ZipperList{cursor: :move_right},
                      data: ZipperList.empty}
      {_, %CmdState{data: data}} = Command.command(cmd)
      assert data.cursor == 0
    end

    test "returns :continue action" do
      cmd = %CmdState{code: %ZipperList{cursor: :move_right},
                      data: ZipperList.empty}
      assert {:continue, _} = Command.command(cmd)
    end
  end

  describe "[ loop begin" do
    test "returns :break action when cursor is 0" do
      cmd = create_command(:loop_begin, 0)
      assert {:break, ^cmd} = Command.command(cmd)
    end

    test "returns :continue_loop action when cursor is non-zero" do
      cmd = create_command(:loop_begin, "potato")
      assert {:continue_loop, ^cmd} = Command.command(cmd)
    end
  end

  describe "] loop end" do
    test "returns :restart_loop action when cursor is non-zero" do
      cmd = create_command(:loop_end, "potato")
      assert {:restart_loop, ^cmd} = Command.command(cmd)
    end

    test "returns :end_loop action when cursor is 0" do
      cmd = create_command(:loop_end, 0)
      assert {:end_loop, ^cmd} = Command.command(cmd)
    end
  end

end
