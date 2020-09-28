defmodule FortKnoxTest do
  use ExUnit.Case
  doctest FortKnox

  test "greets the world" do
    assert FortKnox.hello() == :world
  end
end
