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

    [mdex: MDEx.new(document: markdown)]
  end

  test "default options", %{mdex: mdex} do
    mdex = MDExMermaid.attach(mdex)
    html = MDEx.to_html!(mdex)

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

  test "custom init", %{mdex: mdex} do
    mdex = MDExMermaid.attach(mdex, mermaid_init: "<script>console.log('__test__')</script>")
    html = MDEx.to_html!(mdex)
    assert html =~ "__test__"
  end

  test "merge options", %{mdex: mdex} do
    mdex = MDExMermaid.attach(mdex, mermaid_init: "__test__", document: "# Other")
    html = MDEx.to_html!(mdex)
    assert html == "__test__\n<h1>Other</h1>"
  end
end
