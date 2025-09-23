defmodule MDExMermaidTest do
  use ExUnit.Case

  setup do
    markdown = """
    # Flowchart

    ```mermaid
    graph TD;
        A-->B;
        A-->C;
        B-->D;
        C-->D;
    ```
    """

    [document: MDEx.new(markdown: markdown)]
  end

  test "default options", %{document: document} do
    document = MDExMermaid.attach(document)
    html = MDEx.to_html!(document)

    expected =
      """
      <script type="module">
        import mermaid from 'https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.esm.min.mjs';
        const theme = window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'default';
        mermaid.initialize({securityLevel: 'loose', theme: theme});
      </script>
      <h1>Flowchart</h1>
      <pre id="mermaid-1" class="mermaid" phx-update="ignore">graph TD;
          A-->B;
          A-->C;
          B-->D;
          C-->D;
      </pre>
      """
      |> String.trim()

    assert html == expected
  end

  test "custom init", %{document: document} do
    document =
      MDExMermaid.attach(document, mermaid_init: "<script>console.log('__test__')</script>")

    html = MDEx.to_html!(document)
    assert html =~ "__test__"
  end
end
