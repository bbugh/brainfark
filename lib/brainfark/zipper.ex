defmodule Zipper do
  @moduledoc """
    A Haskell clone Zipper list implementation.
  """
  defstruct left: [], right: []

  @doc """
  Returns an empty Zipper with the cursor position at the front.

  ## Examples

      iex> Zipper.empty
      %Zipper{left: [], right: []}
  """
  def empty, do: %Zipper{}

  @doc """
  Returns a zipper containing the elements of `xs`, focused on the first element.

  ## Examples

      iex> Zipper.fromList([1, 2, 3])
      %Zipper{left: [], right: [1, 2, 3]}
  """
  def fromList(xs), do: %Zipper{right: xs}


  @doc """
  Returns a zipper containing the elements of `xs`, focused just off the right
  end of the list

  ## Examples

      iex> zip = Zipper.fromListEnd([1, 2, 3])
      %Zipper{left: [3, 2, 1], right: []}
      iex> Zipper.end? zip
      true
  """
  def fromListEnd(xs), do: %Zipper{left: Enum.reverse(xs)}

  @doc """
  Returns a list from the zipper, ignoring cursor position.

  ## Examples

      iex> Zipper.toList(%Zipper{left: [3,2,1], right: [4,5,6]})
      [1, 2, 3, 4, 5, 6]
  """
  def toList(%Zipper{} = z) do
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
  def insert(value, %Zipper{right: right} = zip) do
    %{zip | right: [value | right]}
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
  def delete(%Zipper{right: []} = z), do: z
  def delete(%Zipper{right: [_ | right]} = zip) do
    %{zip | right: right}
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
  def push(value, %Zipper{left: left} = z) do
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
  def pop(%Zipper{left: []} = z), do: z
  def pop(%Zipper{left: [_ | left]} = z) do
    %{z | left: left}
  end
end
