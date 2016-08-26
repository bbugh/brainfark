defmodule Zipper do
  @moduledoc """
    A Haskell clone Zipper list implementation.
  """
  @type t :: %Zipper{left: list, right: list}
  defstruct left: [], right: []

  @doc """
  Returns an empty Zipper with the cursor position at the front.

  ## Examples

      iex> Zipper.empty
      %Zipper{left: [], right: []}
  """
  @spec empty :: Zipper.t
  def empty, do: %Zipper{}


  @doc """
  Returns a new Zipper with the cursor on `right`'s first element.

  ## Examples

      iex> Zipper.from_lists([1, 2, 3], [4, 5])
      %Zipper{left: [3, 2, 1], right: [4, 5]}
  """
  @spec from_lists(list, list) :: Zipper.t
  def from_lists(left, right), do: %Zipper{left: Enum.reverse(left), right: right}

  @doc """
  Returns a zipper containing the elements of `xs`, focused on the first element.

  ## Examples

      iex> Zipper.from_list([1, 2, 3])
      %Zipper{left: [], right: [1, 2, 3]}
  """
  @spec from_list(list) :: Zipper.t
  def from_list(xs), do: %Zipper{right: xs}


  @doc """
  Returns a zipper containing the elements of `xs`, focused just off the right
  end of the list

  ## Examples

      iex> zip = Zipper.from_list_end([1, 2, 3])
      %Zipper{left: [3, 2, 1], right: []}
      iex> Zipper.end? zip
      true
  """
  def from_list_end(xs), do: %Zipper{left: Enum.reverse(xs)}

  @doc """
  Returns a list from the zipper, ignoring cursor position.

  ## Examples

      iex> Zipper.to_list(%Zipper{left: [3,2,1], right: [4,5,6]})
      [1, 2, 3, 4, 5, 6]
  """
  def to_list(%Zipper{} = z) do
    Enum.reverse(z.left) ++ z.right
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
  def end?(%Zipper{right: []}), do: true
  def end?(%Zipper{}), do: false

  @doc """
  Returns `true` if the zipper is empty.

  ## Examples

      iex> Zipper.empty?(Zipper.empty)
      true
      iex> Zipper.empty?(%Zipper{left: [3, 2, 1]})
      false
  """
  def empty?(%Zipper{left: [], right: []}), do: true
  def empty?(%Zipper{}), do: false

  @doc """
  Returns the zipper with the cursor set to the start.

  ## Examples

      iex> Zipper.cursor_start(%Zipper{left: [2, 1], right: [3, 4]})
      %Zipper{left: [], right: [1, 2, 3, 4]}
  """
  def cursor_start(z = %Zipper{left: [], right: []}), do: z
  def cursor_start(z = %Zipper{left: []}), do: z
  def cursor_start(z = %Zipper{}), do: %Zipper{right: Enum.reverse(z.left) ++ z.right}


  @doc """
  Returns the zipper with the cursor set just after the end.

  ## Examples

      iex> Zipper.cursor_end(%Zipper{left: [2, 1], right: [3, 4]})
      %Zipper{left: [1, 2, 3, 4], right: []}
  """
  def cursor_end(z = %Zipper{right: []}), do: z
  def cursor_end(z = %Zipper{left: [], right: []}), do: z
  def cursor_end(z = %Zipper{}), do: %Zipper{left: Enum.reverse(z.left) ++ z.right}

  @doc """
  Returns the value at the cursor position, or nil if it is at the end or empty.

  ## Examples

      iex> Zipper.cursor(%Zipper{left: [2, 1], right: [3]})
      3
      iex> Zipper.cursor(%Zipper{left: [3, 2, 1], right: []})
      nil
      iex> Zipper.cursor(Zipper.empty)
      nil
  """
  def cursor(%Zipper{right: []}), do: nil
  def cursor(%Zipper{right: [h | _]}), do: h

  @doc """
  Returns the zipper with the cursor focus shifted one element to the left, or
  the zipper if the cursor is already at the beginning.

  ## Examples

      iex> Zipper.left(%Zipper{left: [2, 1], right: [3]})
      %Zipper{left: [1], right: [2, 3]}
      iex> Zipper.left(%Zipper{left: [], right: [1, 2, 3]})
      %Zipper{left: [], right: [1, 2, 3]}
  """
  def left(%Zipper{left: [head | tail], right: right}) do
    %Zipper{left: tail, right: [head | right]}
  end
  def left(%Zipper{} = z), do: z

  @doc """
  Returns the zipper with the cursor focus shifted one element to the right, or
  the zipper if the cursor is already at the end.

  ## Examples

      iex> Zipper.right(%Zipper{left: [2, 1], right: [3]})
      %Zipper{left: [3, 2, 1], right: []}
      iex> Zipper.right(%Zipper{left: [3, 2, 1], right: []})
      %Zipper{left: [3, 2, 1], right: []}
  """
  def right(%Zipper{left: left, right: [head | tail]}) do
    %Zipper{left: [head | left], right: tail}
  end
  def right(%Zipper{} = z), do: z

  @doc """
  Inserts `value` at the cursor position.

  ## Examples

      iex> Zipper.insert(5, %Zipper{left: [3], right: [2]})
      %Zipper{left: [3], right: [5, 2]}
      iex> Zipper.insert(5, Zipper.empty)
      %Zipper{left: [], right: [5]}
  """
  def insert(value, z = %Zipper{right: right}) do
    %{z | right: [value | right]}
  end

  @doc """
  Deletes the value at the cursor position. If there is no value at the cursor,
  or the cursor is at the end, it returns the zipper.

  ## Examples

      iex> Zipper.delete(%Zipper{left: [3], right: [5, 2]})
      %Zipper{left: [3], right: [2]}
      iex> Zipper.delete(%Zipper{left: [3], right: []})
      %Zipper{left: [3], right: []}
  """
  def delete(z = %Zipper{right: []}), do: z
  def delete(z = %Zipper{right: [_ | right]}) do
    %{z | right: right}
  end

  @doc """
  Pushes a value into the position before the cursor.

  Note: The cursor value does not change.

  ## Examples

      iex> Zipper.push(5, %Zipper{left: [1], right: [2, 3]})
      %Zipper{left: [5, 1], right: [2, 3]}
      iex> Zipper.push(5, Zipper.empty)
      %Zipper{left: [5], right: []}
  """
  def push(value, z = %Zipper{left: left}) do
    %{z | left: [value | left]}
  end

  @doc """
  Pops a value off of the position before the cursor. If used on an empty
  zipper, it returns the zipper.

  Note: the cursor value does not change.

  ## Examples

      iex> Zipper.pop(%Zipper{left: [1], right: [2, 3]})
      %Zipper{left: [], right: [2, 3]}

      iex> Zipper.pop(Zipper.empty)
      %Zipper{left: [], right: []}
  """
  def pop(z = %Zipper{left: []}), do: z
  def pop(z = %Zipper{left: [_ | left]}) do
    %{z | left: left}
  end

  @doc """
  Changes the current element in the zipper to the passed in `value`. If there
  is no current element, the zipper is unchanged. If you want to add the
  element, use `insert/2` or `update/2` instead.

  ## Examples

      iex> Zipper.replace(5, %Zipper{left: [1], right: [2, 3]})
      %Zipper{left: [1], right: [5, 3]}

      iex> Zipper.replace(5, Zipper.empty)
      %Zipper{left: [], right: []}
  """
  def replace(_, z = %Zipper{right: []}), do: z
  def replace(value, z = %Zipper{right: [_ | right]}) do
    %{z | right: [value | right]}
  end

  @doc """
  Replaces the current element in the zipper, or if it's empty, inserts it.

  ## Examples

      iex> Zipper.update(5, %Zipper{left: [1], right: [2]})
      %Zipper{left: [1], right: [5]}

      iex> Zipper.update(5, Zipper.empty)
      %Zipper{left: [], right: [5]}
  """
  def update(value, z = %Zipper{right: []}) do
    %{z | right: [value]}
  end
  def update(value, z = %Zipper{right: [_ | right]}) do
    %{z | right: [value | right]}
  end

  @doc """
  Returns the zipper with the elements in the reverse order. O(1).

  The cursor is moved to the previous element, so if the cursor was at the
  start, it's now off the right end, and if it was off the right end, it's now
  at the start of the reversed list.

  ## Examples

      iex> Zipper.reverse(%Zipper{left: [2, 1], right: [3, 4]})
      %Zipper{left: [3, 4], right: [2, 1]}
  """
  def reverse(%Zipper{left: left, right: right}) do
    %Zipper{left: right, right: left}
  end

  @doc """
  Folds from the left, including the cursor position.

  ## Examples

      iex> z = %Zipper{left: [2, 1], right: [3, 4]}
      iex> Zipper.foldl(z, 0, fn(i, acc) -> i + acc end)
      7

      iex> z = %Zipper{left: [4, 3, 2, 1], right: []}
      iex> Zipper.foldl(z, 0, fn(i, acc) -> i + acc end)
      0
  """
  def foldl(%Zipper{right: []}, acc, _), do: acc
  def foldl(%Zipper{} = z, acc, function) do
    List.foldl(z.right, acc, function)
  end

  @doc """
  Folds from the right, not including the cursor position.

  ## Examples

      iex> z = %Zipper{left: [2, 1], right: [3, 4]}
      iex> Zipper.foldr(z, 0, fn(i, acc) -> i + acc end)
      3

      iex> z = %Zipper{left: [], right: [1, 2, 3, 4]}
      iex> Zipper.foldr(z, 0, fn(i, acc) -> i + acc end)
      0
  """
  def foldr(%Zipper{left: []}, acc, _), do: acc
  def foldr(%Zipper{} = z, acc, function) do
    List.foldr(z.left, acc, function)
  end

  @doc """
  Returns the count of the number of elements in the zipper.

  ## Examples

      iex> Zipper.count(%Zipper{left: [2, 1], right: [3, 4]})
      4

      iex> Zipper.count(Zipper.empty)
      0
  """
  def count(%Zipper{left: [], right: []}), do: 0
  def count(%Zipper{left: left, right: right}), do: length(left) + length(right)
end
