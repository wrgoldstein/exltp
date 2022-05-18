defmodule ExltpTest do
  use ExUnit.Case
  doctest Exltp

  test "encodes basic struct" do
    schema = [
      count: {:signed, :little, :integer, :size, 32},
      b: {:unsigned, :little, :integer, :size, 8},
      foo: :boolean,
    ]

    data = %{count: 123, b: 64, foo: true}

    bytes = <<123, 0, 0, 0, 64, 1::1>>
    Exltp.encode(data, schema)
    assert Exltp.encode(data, schema) == bytes
  end

  test "decodes a struct for a key" do
    schema = [
      count: {:signed, :little, :integer, :size, 32},
      b: {:unsigned, :little, :integer, :size, 8},
      foo: :boolean,
    ]

    bytes = <<123, 0, 0, 0, 64, 1::1>>
    assert Exltp.decode_key(bytes, schema, :foo) == true
    assert Exltp.decode_key(bytes, schema, :count) == 123
    assert Exltp.decode_key(bytes, schema, :b) == 64
  end
end
