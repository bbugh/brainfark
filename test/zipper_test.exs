defmodule ZipperTest do
  use ExUnit.Case
  doctest Zipper

  describe "Enum.reduce" do
    test "it reduces the right side" do
      zs = Zipper.from_lists([1, 2, 3], [4, 5])
      result = Enumerable.reduce(zs, {:cont, 0}, fn(z, acc) ->
        {:cont, Zipper.cursor(z) + acc}
      end)

      assert {:done, 9} == result
    end

    test "it handles :suspend" do
      zs = Zipper.from_list([2, 3, 4])
      result = Enumerable.reduce(zs, {:cont, 5}, fn(_z, acc) ->
        {:suspend, acc}
      end)
      assert {:suspended, 5, _} = result
    end

    test "it can resume after suspend" do
      zs = Zipper.from_lists([1], [2, 3, 4, 5])
      {:suspended, 2, continuation} = Enumerable.reduce(zs, {:cont, 0}, fn(z, acc) ->
        x = Zipper.cursor(z)
        if x == 3 do
          {:suspend, acc}
        else
          {:cont, acc + x}
        end
      end)

      assert {:done, 13} = continuation.({:cont, 4})
    end

    test "it handles :halt" do
      zs = Zipper.from_lists([1], [2, 3, 4, 5])
      assert {:halted, 100} = Enumerable.reduce(zs, {:cont, 100}, fn(_z, acc) ->
        {:halt, acc}
      end)
    end

    test "it can do find" do
      zs = Zipper.from_lists([1], [2, 3, 4, 5])
      result = Enum.find(zs, &(Zipper.cursor(&1) == 4))
      assert result == %Zipper{left: [3, 2, 1], right: [4, 5]}
    end
  end
end
