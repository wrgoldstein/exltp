defmodule Exltp do
  @moduledoc """
  Documentation for `Exltp`.
  """

  def encode_datum(d, {:signed, :little, :integer, :size, n}), do: <<d::signed-little-integer-size(n)>>
  def encode_datum(d, {:unsigned, :little, :integer, :size, n}), do: <<d::unsigned-little-integer-size(n)>>

  def encode_datum(true, :boolean), do: <<1::1>>
  def encode_datum(false, :boolean), do: <<0::1>>

  def get_size({_, _, :integer, :size, n}), do: n
  def get_size(:boolean), do: 1

  def encode(data, schema) do
    for {k, v} <- schema, into: <<>>, do: encode_datum(data[k], v)
  end

  def read_off(bytes, {:signed, :little, :integer, :size, n}) do
    <<head::signed-little-integer-size(n), _rest::bitstring>> = bytes
    head
  end

  def read_off(bytes, {:unsigned, :little, :integer, :size, n}) do
    <<head::unsigned-little-integer-size(n), _rest::bitstring>> = bytes
    head
  end

  def read_off(bytes, :boolean) do
    <<head::size(1), _rest::bitstring>> = bytes
    head
  end

  def conversion(bool, :boolean) do
    if bool, do: true, else: false
  end

  def conversion(value, _), do: value

  def decode_key(bytes, schema, key) do
    {start, type} = Enum.reduce_while(schema, 0, fn {k, v}, acc -> 
      if k != key do
        {:cont, acc + get_size(v)}
      else
        {:halt, {trunc(acc), v}}
      end
    end)
    
    <<_s::size(start), rest::bitstring>> = bytes 
    read_off(rest, type) |> conversion(type)
  end
end
