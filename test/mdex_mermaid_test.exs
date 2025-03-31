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
      <h1>Flowchart</h1>
      <pre id="mermaid-1" class="mermaid" phx-update="ignore">graph TD;
          A-->B;
          A-->C;
          B-->D;
          C-->D;
      </pre>
      <script type="module">
        import mermaid from 'https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.esm.min.mjs';

        const theme = window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'default';

        mermaid.initialize({
          securityLevel: 'loose',
          theme: theme,
        });
      </script>
      """
      |> String.trim()

    assert html == expected
  end

  test "version", %{mdex: mdex} do
    mdex = MDExMermaid.attach(mdex, version: "10")
    html = MDEx.to_html!(mdex)
    assert html =~ "https://cdn.jsdelivr.net/npm/mermaid@10/dist/mermaid.esm.min.mjs"
  end

  test "security level", %{mdex: mdex} do
    mdex = MDExMermaid.attach(mdex, security_level: "strict")
    html = MDEx.to_html!(mdex)
    assert html =~ "securityLevel: 'strict'"
  end
end
