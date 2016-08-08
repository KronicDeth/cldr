# http://unicode.org/reports/tr35/tr35-numbers.html#Language_Plural_Rules
defmodule Cldr.Number.PluralRules.Compiler do
  @moduledoc """
  Generate functions from CLDR plural rules that can be used to determine 
  which pularization rule to be used for a given number.
  """
  
  @doc """
  Scan a rule definition
  
  Using a leex lexer, tokenize a rule definition
  """
  def tokenize(definition) when is_binary(definition) do
    String.to_charlist(definition) |> :plural_rules_lexer.string
  end
  
  @doc """
  Parse a rule definition
  
  Using a yexx lexer, parse a rule definition into an Elixir
  AST that can then be `unquoted` into a function definition.
  """
  def parse(tokens) when is_list(tokens) do
    :plural_rules_parser.parse tokens
  end
  
  def parse(definition) when is_binary(definition) do
    {:ok, tokens, _end_line} = tokenize(definition) 
    tokens |> :plural_rules_parser.parse
  end
end