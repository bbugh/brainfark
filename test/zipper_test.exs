defmodule ZipperTest do
  use ExUnit.Case
  doctest Zipper

  describe "empty" do
    test "returns an empty zipper" do
      assert %Zipper{left: [], right: []} == Zipper.empty
    end
  end

  describe "fromList" do
    test "returns a zipper focused on the first element" do
      list = [1, 2, 3]
      assert %Zipper{left: [], right: list} == Zipper.fromList list
    end
  end

  describe "fromListEnd" do
    test "returns a zipper focused after the last element" do
      list = [1, 2, 3]
      assert %Zipper{left: list, right: []} == Zipper.fromListEnd list
    end
  end

  describe "toList" do
    test "returns a list from the zipper" do
      zipped = %Zipper{left: [3, 2, 1], right: [4, 5, 6]}
      assert [1, 2, 3, 4, 5, 6] == Zipper.toList zipped
    end
  end

  describe "beginning?" do
    test "true if the zipper is at the start" do
      zipped = %Zipper{left: [], right: [1, 2, 3]}
      assert Zipper.beginning? zipped
    end

    test "false if the zipper is not at the start" do
      zipped = %Zipper{left: [2, 1], right: [3]}
      refute Zipper.beginning? zipped
    end
  end

  describe "end?" do
    test "true if the zipper is at the end" do
      zipped = %Zipper{left: [3, 2, 1], right: []}
      assert Zipper.end? zipped
    end

    test "false if the zipper is not at the end" do
      zipped = %Zipper{left: [2, 1], right: [3]}
      refute Zipper.end? zipped
    end
  end

  describe "empty?" do
    test "true if no values" do
      assert Zipper.empty?(Zipper.empty)
    end

    test "false if anything inside" do
      refute Zipper.empty? %Zipper{left: [1], right: []}
      refute Zipper.empty? %Zipper{left: [], right: [1]}
      refute Zipper.empty? %Zipper{left: [1], right: [1]}
    end
  end

  describe "cursor" do
    test "returns the value at the cursor position" do
      zipped = %Zipper{left: [2, 1], right: [3]}
      assert 3 == Zipper.cursor zipped
    end

    test "returns nil if at the end" do
      zipped = %Zipper{left: [3, 2, 1], right: []}
      assert nil == Zipper.cursor zipped
    end
  end

  describe "left" do
    test "returns the zipper with the focus shifted left one element" do
      zipped = %Zipper{left: [2, 1], right: [3]}
      assert %Zipper{left: [1], right: [2, 3]} == Zipper.left zipped
    end

    test "returns the same zipper when at the beginning" do
      zipped = %Zipper{left: [], right: [1]}
      assert Zipper.left(zipped) == zipped
    end
  end

  describe "right" do
    test "returns the zipper with the focus shifted right one element" do
      zipped = %Zipper{left: [1], right: [2, 3]}
      assert %Zipper{left: [2, 1], right: [3]} == Zipper.right zipped
    end

    test "returns the same zipper when at the end" do
      zipped = %Zipper{left: [1], right: []}
      assert Zipper.right(zipped) == zipped
    end
  end

  describe "insert" do
    test "adds the value into the cursor position" do
      zipped = %Zipper{left: [1], right: [3]}
      assert %Zipper{left: [1], right: [2, 3]} == Zipper.insert(2, zipped)
    end

    test "adds the value into the cursor position when empty" do
      assert %Zipper{left: [], right: [1]} == Zipper.insert(1, Zipper.empty)
    end
  end

  describe "delete" do
    test "deletes the current cursor value" do
      zipped = %Zipper{left: [1], right: [2, 3]}
      assert %Zipper{left: [1], right: [3]} == Zipper.delete(zipped)
    end

    test "doesn't change anything if the cursor position is empty" do
      zipped = %Zipper{left: [1], right: []}
      assert zipped == Zipper.delete(zipped)
    end
  end

  describe "push" do
    test "inserts value into the zipper and advances past it" do
      %{left: left, right: right} = Zipper.push(5, %Zipper{left: [1], right: [2, 3]})
      assert left == [5, 1]
      assert right == [2, 3]
    end

    test "works for empty zippers" do
      %{left: left, right: right} = Zipper.push(5, Zipper.empty)
      assert left == [5]
      assert right == []
    end
  end

  describe "pop" do
    test "removes the element before the cursor" do
      zipped = %Zipper{left: [1], right: [2, 3]}
      assert %Zipper{left: [], right: [2, 3]} == Zipper.pop(zipped)
    end

    test "returns the zipper if the left side is empty" do
      zipped = %Zipper{left: [], right: [2, 3]}
      assert zipped == Zipper.pop(zipped)
    end
  end
end
