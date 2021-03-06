defmodule Mix.Tasks.Cldr.GenerateLanguageTags do
  @moduledoc """
  Mix task to generate the language tags for all
  available locales.
  """

  use Mix.Task

  @shortdoc "Generate langauge tags for all available locales"

  @doc false
  def run(_) do
    unless Mix.env() == :test do
      raise "Must be run in :test mode to ensure that all locales are configured"
    end

    # We set the gettext locale name to nil because we can't tell in advance
    # what the gettext locale name will be (if any)
    language_tags =
      for locale_name <- Cldr.all_locale_names() do
        with {:ok, language_tag} <- Cldr.LanguageTag.parse(locale_name),
             {:ok, canonical_tag} <- Cldr.Locale.canonical_language_tag(language_tag) do
          language_tag =
            canonical_tag
            |> Map.put(:cldr_locale_name, locale_name)
            |> Map.put(:gettext_locale_name, nil)

          {locale_name, language_tag}
        else
          {:error, {exception, reason}} ->
            raise exception, reason
        end
      end
      |> Enum.into(%{})

    output_path = Path.expand(Path.join("priv/cldr/", "language_tags.ebin"))
    File.write!(output_path, :erlang.term_to_binary(language_tags))
  end
end
