defmodule Cldr.Number.PluralRule.Transformer do
  alias Cldr.Number.PluralRule
  
  # Obsolete but a good code pattern to know
  # defmacrop define_do_cardinal(rules, locale) do
  #   {:defp, context, [arguments]} = quote do: defp do_cardinal(unquote(locale), n, i, v, w, f, t)
  #   function = {:defp, context, [arguments, [do: rules]]}
  #   function
  # end
  
  @doc """
  Converts a map representing a set of plural rules and converts it
  to an `cond` statement.
  
  `rules` is a map of the locale specific branch of the plurals.json
  file from CLDR.  It is then tokenized, parsed and the resulting ast
  converted to a `cond` statement.
  """
  def rules_to_condition_statement(rules, module) do
    branches = Enum.map rules, fn({"pluralRule-count-" <> category, rule}) ->
      {:ok, definition} = PluralRule.Compiler.parse(rule)
      {new_ast, _} = set_operand_module(definition[:rule], module)
      rule_to_cond_branch(new_ast, String.to_atom(category))
    end
    {:cond, [],[[do: move_true_branch_to_end(branches)]]}
  end
  
  # We can't assume the order of branches and we need the
  # `true` branch at the end since it will always match
  # and hence potentially shadow other branches
  defp move_true_branch_to_end(branches) do
    Enum.sort branches, fn ({:->, [], [[ast], _category]}, _other_branch) ->
      not(ast == true)
    end
  end
  
  # Walk the AST and replace the variable context to that of the calling
  # module
  defp set_operand_module(ast, module) do
    Macro.prewalk ast, [], fn(expr, acc) ->
      new_expr = case expr do
        {var, [], Elixir} ->
          {var, [], module}
        {:mod, _context, [operand, value]} ->
          {:mod, [context: Elixir, import: Elixir.Cldr.Number.Math], [operand, value]}
        {:within, _context, [operand, range]} ->
          {:within, [context: Elixir, import: Elixir.Cldr.Number.Math], [operand, range]}
        _ ->
          expr
      end
      {new_expr, acc}
    end
  end
  
  # Transform the rule AST into a branch of a `cond` statement
  defp rule_to_cond_branch(nil, category) do
     {:->, [], [[true], category]}
  end
  defp rule_to_cond_branch(rule_ast, category) do
     {:->, [], [[rule_ast], category]}
  end
end