defmodule Issues.CLI do

  @default_count 4

  @moduledoc """
  Handle the commandline parsing and the dispatch to various functions.
  """

  def run(argv) do
    argv |> parse_args |> process |> IO.inspect
  end

  def parse_args(argv) do
    parse = OptionParser.parse(argv, switches: [help: :boolean],
                                     aliases:  [h:    :help])
    case parse do
      {[help: true], _ } -> :help
      {_,[user,project,count]} -> { user,project,binary_to_integer(count) }
      {_,[user,project]} -> { user,project }
      _ -> :help
    end
  end

  def process(:help) do
    IO.puts """
      usage: issues <user> <project> [ count | #{@default_count} ]
    """
    System.halt(0)
  end

  def process({user,project}) do
    Issues.GithubIssues.fetch(user,project)
      |> decode_response
      |> convert_to_list_of_hashdicts
      |> sort_into_ascending_order
  end

  def convert_to_list_of_hashdicts(list) do
    Enum.map(list, HashDict.new(&1))
  end

  def sort_into_ascending_order(list_of_issues) do
    sort_func = fn item_one, item_two ->
      item_one["created_at"] < item_two["created_at"]
    end
    Enum.sort(list_of_issues,sort_func)
  end

  def decode_response({:ok, body}), do: Jsonex.decode(body)
  def decode_response({:error, msg}) do
    Jsonex.decode(msg)["message"]
    System.halt(2)
  end
end
