defmodule CommandTest do
  use ExUnit.Case
  doctest Command

  describe "> increment data pointer" do
    test "parsing default setting behaves correclty" do
      result = Command.command(">", %{data: [], dataptr: 0})
      assert result == {:ok, %{data: [0], dataptr: 1}}
    end

    test "it appends a 0 to data when pointing past the end" do
      {:ok, %{data: data}} = Command.command(">", %{data: [1], dataptr: 0})
      assert data == [1, 0]
    end

    test "it doesn't change data when pointing internally" do
      {:ok, %{data: data}} = Command.command(">", %{data: [1,2], dataptr: 0})
      assert data == [1,2]
    end

    # test "it fails when data is not a list" do
    #   assert_raise FunctionClauseError, fn ->
    #     Command.command(">", %{data: "hello", dataptr: 0})
    #   end
    # end
    #
    # test "it fails when dataptr is not a number" do
    #   assert_raise FunctionClauseError, fn ->
    #     Command.command(">", %{data: [], dataptr: "hello"})
    #   end
    # end
    #
    # test "it fails when dataptr is a negative number" do
    #   assert_raise FunctionClauseError, fn ->
    #     Command.command(">", %{data: [], dataptr: -1})
    #   end
    # end
  end


  # dptr -= 1
  # if dptr < 0
  #   data.unshift 0
  #   dptr = 0
  # end
  #
  describe "< decrement data pointer" do
    test "it moves the data pointer down" do
      {:ok, %{dataptr: dataptr}} = Command.command("<", %{data: [1,2,3], dataptr: 1})
      assert dataptr == 0
    end

    test "it prepends an item to the data stack when it goes negative" do
      {:ok, %{data: data}} = Command.command("<", %{data: [1], dataptr: 0})
      assert data == [0, 1]
    end

    # test "it fails when data is not a list" do
    #   assert_raise FunctionClauseError, fn ->
    #     Command.command("<", %{data: "hello", dataptr: 0})
    #   end
    # end
    #
    # test "it fails when dataptr is not a number" do
    #   assert_raise FunctionClauseError, fn ->
    #     Command.command("<", %{data: [], dataptr: "hello"})
    #   end
    # end
    #
    # test "it fails when dataptr is a negative number" do
    #   assert_raise FunctionClauseError, fn ->
    #     Command.command("<", %{data: [], dataptr: -1})
    #   end
    # end
  end

  describe ", capture" do
    test "input should have the front char removed" do
      {:ok, %{input: input}} = Command.command(",", %{data: [], dataptr: 0, input: 'hello'})
      assert input == 'ello'
    end

    test "it should replace the current data ptr location with the first input" do
      {:ok, %{data: data}} = Command.command(",", %{data: [97], dataptr: 0, input: 'hello'})
      assert data == [104]
    end

    test "insert the first input into data when given an empty data list" do
      {:ok, %{data: data}} = Command.command(",", %{data: [], dataptr: 0, input: 'hello'})
      assert data == [104]
    end
  end

  describe "+ increment value" do
    test "increments the data at the data ptr location" do
      {:ok, %{data: data}} = Command.command("+", %{data: [97, 104], dataptr: 1})
      assert data == [97, 105]
    end

    test "it wraps around to 0 when greater than 255" do
      {:ok, %{data: data}} = Command.command("+", %{data: [97, 255], dataptr: 1})
      assert data == [97, 0]
    end

    # uncertain how BF handles this
    test "it results in an error when there is no data at the pointer" do
      {result, _} = Command.command("+", %{data: [], dataptr: 0})
      assert result == :error
    end
  end

  describe "- decrement value" do
    test "decrements the data at the data ptr location" do
      {:ok, %{data: data}} = Command.command("-", %{data: [97, 104], dataptr: 1})
      assert data == [97, 103]
    end

    test "it wraps around to 255 when less than 0" do
      {:ok, %{data: data}} = Command.command("-", %{data: [97, 0], dataptr: 1})
      assert data == [97, 255]
    end

    # uncertain how BF handles this
    test "it results in an error when there is no data at the pointer" do
      {result, _} = Command.command("-", %{data: [], dataptr: 0})
      assert result == :error
    end
  end

  test "the truth" do
    assert 1 + 1 == 2
  end
end
