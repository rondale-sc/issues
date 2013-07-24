Code.require_file "test_helper.exs", __DIR__

defmodule IssuesTest do
  use ExUnit.Case

  import Issues.CLI, only: [ parse_args: 1,
                             sort_into_ascending_order: 1,
                             convert_to_list_of_hashdicts: 1 ]

  test :parse_args do
    assert parse_args(["-h", "anything"]) == :help
    assert parse_args(["-help", "anything"]) == :help
    assert parse_args(["blahzorz"]) == :help

    assert parse_args(["user", "project", "99"]) == { "user", "project", 99 }
    assert parse_args(["user", "project"]) == {"user", "project"}
  end

  test "sort ascending orders the correct way" do
    result = sort_into_ascending_order(fake_created_at_list(["c", "a", "b"]))
    assert (lc issue inlist result, do: issue["created_at"]) == [ "a", "b", "c" ]
  end

  defp fake_created_at_list(values) do
    data = lc value inlist values, do: [{"created_at", value}, {"other_data", "xxx"}]
    convert_to_list_of_hashdicts data
  end
end
