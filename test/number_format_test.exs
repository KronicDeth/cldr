defmodule Number.Format.Test do
  use ExUnit.Case
  import Cldr.Number.Format.Test, only: [sanitize: 1]
  
  Enum.each Cldr.Number.Format.Test.test_data(), fn {value, result, args} ->
    test "formatted #{inspect value} == #{inspect sanitize(result)} with args: #{inspect args}" do
      assert Cldr.Number.to_string(unquote(value), unquote(args)) == unquote(result)
    end
  end
  
  test "invalid format returns an error" do
    assert {:error, _message} = Cldr.Number.to_string(1234, format: "xxx")
  end
  
  test "a currency format with no currency specified raises" do
    assert_raise ArgumentError, ~r/Cannot use a currency format/, fn ->
      Cldr.Number.to_string(1234, format: "¤ #,##0.00")
    end
  end
end