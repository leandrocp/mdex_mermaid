# Credo runs in strict mode, so `mix credo` locally reports exactly what CI
# reports. The two settings below are the ones this repository pins on purpose;
# everything else is Credo's own default.
%{
  configs: [
    %{
      name: "default",
      strict: true,
      files: %{
        included: ["lib/", "src/", "test/", "config/", "mix.exs"],
        excluded: [~r"/_build/", ~r"/deps/", ~r"/node_modules/"]
      },
      checks: %{
        extra: [
          # Classic McCabe cyclomatic complexity, at the ceiling shared by every
          # project in this family, in Elixir and in JavaScript alike.
          {Credo.Check.Refactor.CyclomaticComplexity, max_complexity: 9},
          # Matches `line_length` in .formatter.exs, so the formatter and the
          # linter cannot disagree about a line.
          {Credo.Check.Readability.MaxLineLength, max_length: 98}
        ],
        disabled: [
          # TODO and FIXME notes are tracked in the issue tracker. Failing a
          # build on one only encourages deleting the note.
          {Credo.Check.Design.TagTODO, []},
          {Credo.Check.Design.TagFIXME, []}
        ]
      }
    }
  ]
}
