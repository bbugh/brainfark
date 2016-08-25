defmodule Zipper do
  defstruct left: [], right: []

  def empty, do: %Zipper{left: [], right: []}

  def fromList(list), do: %Zipper{left: [], right: list}
  def fromListEnd(list), do: %Zipper{left: list, right: []}

  def toList(%Zipper{left: left, right: right}) do
    Enum.reverse(left) ++ right
  end

  def beginning?(%Zipper{left: []}), do: true
  def beginning?(_), do: false

  def end?(%Zipper{right: []}), do: true
  def end?(_), do: false

  def empty?(%Zipper{left: [], right: []}), do: true
  def empty?(_), do: false

  def cursor(%Zipper{right: []}), do: nil
  def cursor(%Zipper{right: [h | _]}), do: h

  def left(%Zipper{left: [head | tail], right: right}) do
    %Zipper{left: tail, right: [head | right]}
  end
  def left(z), do: z

  def right(%Zipper{left: left, right: [head | tail]}) do
    %Zipper{left: [head | left], right: tail}
  end
  def right(z), do: z

  def insert(value, %Zipper{right: right} = zip) do
    %{zip | right: [value | right]}
  end

  def delete(%Zipper{right: []} = z), do: z
  def delete(%Zipper{right: [_ | right]} = zip) do
    %{zip | right: right}
  end

  def push(value, %Zipper{left: left} = z) do
    %{z | left: [value | left]}
  end

  def pop(%Zipper{left: []} = z), do: z
  def pop(%Zipper{left: [_ | left]} = z) do
    %{z | left: left}
  end
end
