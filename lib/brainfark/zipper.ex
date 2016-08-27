defmodule Zipper do
  @moduledoc """
    A Haskell clone Zipper list implementation.
  """
  @type t :: %Zipper{left: list, right: list, cursor: any}
  defstruct left: [], right: [], cursor: nil

  @doc """
  Returns an empty Zipper with the cursor position at the front.

  ## Examples

      iex> Zipper.empty
      %Zipper{left: [], right: []}
  """
  @spec empty :: Zipper.t
  def empty, do: %Zipper{}


  @doc """
  Returns a new Zipper with the cursor from `right`'s first element.

  ## Examples

      iex> Zipper.from_lists([1, 2, 3], [4, 5])
      %Zipper{left: [3, 2, 1], right: [5], cursor: 4}
  """
  @spec from_lists(list, list) :: Zipper.t
  def from_lists(left, [c | right]) do
    %Zipper{left: Enum.reverse(left), right: right, cursor: c}
  end

  @doc """
  Returns a zipper containing the elements of `xs`, with the cursor from the
  first element.

  ## Examples

      iex> Zipper.from_list([1, 2, 3])
      %Zipper{left: [], cursor: 1, right: [2, 3]}
  """
  @spec from_list(list) :: Zipper.t
  def from_list([c | xs]), do: %Zipper{right: xs, cursor: c}


  @doc """
  Returns a zipper containing the elements of `xs`, focused just off the right
  end of the list

  ## Examples

      iex> zip = Zipper.from_list_end([1, 2, 3])
      %Zipper{left: [3, 2, 1], right: [], cursor: nil}
      iex> Zipper.end? zip
      true
  """
  @spec from_list_end(list) :: Zipper.t
  def from_list_end(xs), do: %Zipper{left: Enum.reverse(xs)}

  @doc """
  Returns a list from the zipper, including cursor value.

  ## Examples

      iex> Zipper.to_list(%Zipper{left: [3,2,1], right: [5,6], cursor: 4})
      [1, 2, 3, 4, 5, 6]
  """
  def to_list(z = %Zipper{}) do
    Enum.reverse(z.left) ++ [z.cursor | z.right]
  end

  @doc """
  Returns `true` if the zipper is at the start.

  ## Examples

      iex> Zipper.beginning?(%Zipper{left: [], right: [1, 2, 3]})
      true

      iex> Zipper.beginning?(%Zipper{left: [2, 1], right: [3]})
      false
  """
  def beginning?(%Zipper{left: []}), do: true
  def beginning?(%Zipper{}), do: false

  @doc """
  Returns `true` if the zipper is at the end.

  Note: It is safe to call `cursor` on `z` if `end?` returns `true`.

  ## Examples

      iex> Zipper.end?(%Zipper{left: [3, 2, 1], right: []})
      true

      iex> Zipper.end?(%Zipper{left: [2, 1], right: [3]})
      false
  """
  def end?(%Zipper{cursor: nil, right: []}), do: true
  def end?(%Zipper{}), do: false

  @doc """
  Returns `true` if the zipper is empty.

  ## Examples

      iex> Zipper.empty?(Zipper.empty)
      true

      iex> Zipper.empty?(%Zipper{left: [3, 2, 1], cursor: 4})
      false
  """
  def empty?(%Zipper{left: [], right: [], cursor: nil}), do: true
  def empty?(%Zipper{}), do: false

  @doc """
  Returns the zipper with the cursor set to the start.

  ## Examples

      iex> Zipper.cursor_start(%Zipper{left: [2, 1], right: [4], cursor: 3})
      %Zipper{left: [], right: [2, 3, 4], cursor: 1}
  """
  def cursor_start(z = %Zipper{left: [], right: []}), do: z
  def cursor_start(z = %Zipper{}) do
    [cursor | right] = Enum.reverse(z.left) ++ [z.cursor | z.right]
    %Zipper{cursor: cursor, right: right}
  end


  @doc """
  Returns the zipper with the cursor set just after the end.

  ## Examples

      iex> Zipper.cursor_end(%Zipper{left: [2, 1], right: [4, 5], cursor: 3})
      %Zipper{left: [5, 4, 3, 2, 1], right: [], cursor: nil}
  """
  def cursor_end(z = %Zipper{right: []}), do: z
  def cursor_end(z = %Zipper{left: [], right: []}), do: z
  def cursor_end(z = %Zipper{}) do
    %Zipper{cursor: nil, left: Enum.reverse(z.right) ++ [z.cursor | z.left]}
   end

  # @doc """
  # Returns the value at the cursor position, or nil if it is at the end or empty.
  #
  # ## Examples
  #
  #     iex> Zipper.cursor(%Zipper{left: [2, 1], right: [3]})
  #     3
  #     iex> Zipper.cursor(%Zipper{left: [3, 2, 1], right: []})
  #     nil
  #     iex> Zipper.cursor(Zipper.empty)
  #     nil
  # """
  # def cursor(%Zipper{right: []}), do: nil
  # def cursor(%Zipper{right: [h | _]}), do: h

  @doc """
  Returns the zipper with the cursor focus shifted one element to the left, or
  the zipper if the cursor is already at the beginning.

  ## Examples

      iex> Zipper.left(%Zipper{left: [2, 1], right: [4], cursor: 3})
      %Zipper{left: [1], right: [3, 4], cursor: 2}

      iex> Zipper.left(%Zipper{left: [], right: [2, 3], cursor: 1})
      %Zipper{left: [], right: [2, 3], cursor: 1}
  """
  def left(z = %Zipper{left: []}), do: z
  def left(z = %Zipper{left: [head | tail]}) do
    %Zipper{cursor: head, left: tail, right: [z.cursor | z.right]}
  end

  @doc """
  Returns the zipper with the cursor focus shifted one element to the right, or
  returns the zipper if the cursor is past the end.

  ## Examples

      iex> Zipper.right(%Zipper{left: [2, 1], right: [4], cursor: 3})
      %Zipper{left: [3, 2, 1], right: [], cursor: 4}

      iex> Zipper.right(%Zipper{left: [3, 2, 1], right: [], cursor: 4})
      %Zipper{left: [4, 3, 2, 1], right: [], cursor: nil}

      iex> Zipper.right(%Zipper{left: [4, 3, 2, 1], right: [], cursor: nil})
      %Zipper{left: [4, 3, 2, 1], right: [], cursor: nil}
  """
  def right(z = %Zipper{cursor: nil, right: []}), do: z
  def right(z = %Zipper{cursor: cursor, right: []}) do
    %{z | cursor: nil, left: [cursor | z.left]}
  end
  def right(z = %Zipper{right: [head | tail]}) do
    %Zipper{cursor: head, left: [z.cursor | z.left], right: tail}
  end

  @doc """
  Inserts `value` at the cursor position, moving the current cursor to the right.

  ## Examples

  Inserting a value replaces the cursor:

      iex> Zipper.insert(5, %Zipper{left: [1], right: [3], cursor: 2})
      %Zipper{left: [1], right: [2, 3], cursor: 5}

  On empty zippers, it inserts at the cursor position:

      iex> Zipper.insert(5, Zipper.empty)
      %Zipper{left: [], right: [], cursor: 5}

  Any values are pushed to the right on any zipper:

      iex> Zipper.insert(10, %Zipper{left: [], right: [], cursor: 5})
      %Zipper{left: [], right: [5], cursor: 10}
  """
  def insert(value, z = %Zipper{cursor: nil}), do: %{z | cursor: value}
  def insert(value, z = %Zipper{right: right}) do
    %{z | cursor: value, right: [z.cursor | right]}
  end

  @doc """
  Deletes the value at the cursor position and replaces it with the next value
  from the right.

  ## Examples

      iex> Zipper.delete(%Zipper{left: [3], right: [5, 2], cursor: 4})
      %Zipper{left: [3], right: [2], cursor: 5}

      iex> Zipper.delete(Zipper.empty)
      %Zipper{left: [], right: [], cursor: nil}

  If there is no value to the right, `cursor` will be `nil`:

      iex> Zipper.delete(%Zipper{left: [2, 5, 3], right: [], cursor: 8})
      %Zipper{left: [2, 5, 3], right: [], cursor: nil}
  """
  def delete(z = %Zipper{cursor: nil}), do: z
  def delete(z = %Zipper{cursor: c, right: []}) do
    %{z | cursor: nil}
  end
  def delete(z = %Zipper{right: [cursor | right]}) do
    %{z | cursor: cursor, right: right}
  end

  @doc """
  Pushes a value into the position before the cursor.

  Note: The cursor value does not change.

  ## Examples

      iex> Zipper.push(5, %Zipper{left: [1], right: [3, 4], cursor: 2})
      %Zipper{left: [5, 1], right: [3, 4], cursor: 2}
      iex> Zipper.push(5, Zipper.empty)
      %Zipper{left: [5], right: [], cursor: nil}
  """
  def push(value, z = %Zipper{left: left}) do
    %{z | left: [value | left]}
  end

  @doc """
  Pops a value off of the position before the cursor. If used on an empty
  zipper, it returns the zipper.

  Note: the cursor value does not change.

  ## Examples

      iex> Zipper.pop(%Zipper{left: [1], right: [3, 4], cursor: 2})
      %Zipper{left: [], right: [3, 4], cursor: 2}

      iex> Zipper.pop(Zipper.empty)
      %Zipper{left: [], right: [], cursor: nil}
  """
  def pop(z = %Zipper{left: []}), do: z
  def pop(z = %Zipper{left: [_ | left]}) do
    %{z | left: left}
  end

  @doc """
  Replaces the zipper's cursor with the passed in `value`. If there is no
  current cursor, the value becomes the new cursor.

  ## Examples

      iex> Zipper.replace(5, %Zipper{left: [1], right: [3, 4], cursor: 2})
      %Zipper{left: [1], right: [3, 4], cursor: 5}

      iex> Zipper.replace(5, Zipper.empty)
      %Zipper{left: [], right: [], cursor: 5}
  """
  def replace(value, z = %Zipper{}) do
    %{z | cursor: value}
  end

  @doc """
  Returns the zipper with the elements in the reverse order. O(1).

  The cursor "position" is shifted, but the value does not change. If the cursor
  was at the start, it's now at the end, and if it was at the end, it's now at
  the start.

  ## Examples

      iex> Zipper.reverse(%Zipper{left: [2, 1], right: [4], cursor: 3})
      %Zipper{left: [4], right: [2, 1], cursor: 3}

      iex> Zipper.reverse(%Zipper{left: [], right: [2, 3, 4], cursor: 1})
      %Zipper{left: [2, 3, 4], right: [], cursor: 1}
  """
  def reverse(z = %Zipper{left: left, right: right}) do
    %{z | left: right, right: left}
  end

  # @doc """
  # Folds from the left, including the cursor position.
  #
  # ## Examples
  #
  #     iex> z = %Zipper{left: [2, 1], right: [3, 4]}
  #     iex> Zipper.foldl(z, 0, fn(i, acc) -> i + acc end)
  #     7
  #
  #     iex> z = %Zipper{left: [4, 3, 2, 1], right: []}
  #     iex> Zipper.foldl(z, 0, fn(i, acc) -> i + acc end)
  #     0
  # """
  # def foldl(%Zipper{cursor: nil, right: []}, acc, _), do: acc
  # def foldl(z = %Zipper{}, acc, function) do
  #   List.foldl(z.right, acc, function)
  # end
  #
  # @doc """
  # Folds from the right, not including the cursor position.
  #
  # ## Examples
  #
  #     iex> z = %Zipper{left: [2, 1], right: [3, 4]}
  #     iex> Zipper.foldr(z, 0, fn(i, acc) -> i + acc end)
  #     3
  #
  #     iex> z = %Zipper{left: [], right: [1, 2, 3, 4]}
  #     iex> Zipper.foldr(z, 0, fn(i, acc) -> i + acc end)
  #     0
  # """
  # def foldr(%Zipper{left: []}, acc, _), do: acc
  # def foldr(z = %Zipper{}, acc, function) do
  #   List.foldr(z.left, acc, function)
  # end

  @doc """
  Returns the count of the number of elements in the zipper.

  ## Examples

      iex> Zipper.count(%Zipper{left: [2, 1], right: [4, 5], cursor: 3})
      5

      iex> Zipper.count(Zipper.empty)
      0
  """
  def count(%Zipper{left: [], right: [], cursor: nil}), do: 0
  def count(%Zipper{left: left, right: right, cursor: cursor}) when not is_nil(cursor) do
    length(left) + length(right) + 1
  end
end
