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

  test "custom init replaces default init", %{document: document} do
    custom_init = "<script>window.customMermaid = true;</script>"
    document = MDExMermaid.attach(document, mermaid_init: custom_init)

    html = MDEx.to_html!(document)

    assert html =~ "window.customMermaid = true"
    refute html =~ "import mermaid from 'https://cdn.jsdelivr.net/npm/mermaid"
  end

  test "empty string init skips initialization", %{document: document} do
    document = MDExMermaid.attach(document, mermaid_init: "")

    html = MDEx.to_html!(document)

    refute html =~ "<script"
    assert html =~ ~s(<pre id="mermaid-1" class="mermaid" phx-update="ignore">)
  end

  test "nil init uses default init", %{document: document} do
    document = MDExMermaid.attach(document, mermaid_init: nil)

    html = MDEx.to_html!(document)

    assert html =~ "import mermaid from 'https://cdn.jsdelivr.net/npm/mermaid"
    assert html =~ "mermaid.initialize({securityLevel: 'loose', theme: theme});"
  end

  test "custom mermaid_pre_attrs", %{document: document} do
    pre_attrs = fn seq -> ~s(id="custom-#{seq}" class="diagram" data-type="mermaid") end
    document = MDExMermaid.attach(document, mermaid_pre_attrs: pre_attrs)

    html = MDEx.to_html!(document)

    assert html =~ ~s(<pre id="custom-1" class="diagram" data-type="mermaid">)
    refute html =~ ~s(phx-update="ignore")
  end

  test "mermaid_pre_attrs with LiveView hook", %{document: document} do
    pre_attrs = fn seq ->
      ~s(id="mermaid-#{seq}" class="mermaid" phx-hook="MermaidHook" phx-update="ignore")
    end

    document = MDExMermaid.attach(document, mermaid_pre_attrs: pre_attrs)

    html = MDEx.to_html!(document)

    assert html =~ ~s(phx-hook="MermaidHook")
    assert html =~ ~s(phx-update="ignore")
    assert html =~ ~s(id="mermaid-1")
  end

  test "mermaid_pre_attrs increments sequence for multiple blocks" do
    markdown = """
    ```mermaid
    graph TD;
        A-->B;
    ```

    ```mermaid
    graph LR;
        C-->D;
    ```

    ```mermaid
    sequenceDiagram
        Alice->>Bob: Hello
    ```
    """

    pre_attrs = fn seq -> ~s(id="diagram-#{seq}" class="mermaid") end

    html =
      MDEx.new(markdown: markdown)
      |> MDExMermaid.attach(mermaid_pre_attrs: pre_attrs)
      |> MDEx.to_html!()

    assert html =~ ~s(<pre id="diagram-1" class="mermaid">)
    assert html =~ ~s(<pre id="diagram-2" class="mermaid">)
    assert html =~ ~s(<pre id="diagram-3" class="mermaid">)
  end

  test "combined custom options", %{document: document} do
    custom_init = "<!-- mermaid already loaded -->"
    pre_attrs = fn seq -> ~s(id="chart-#{seq}" class="mermaid-chart") end

    document =
      MDExMermaid.attach(document,
        mermaid_init: custom_init,
        mermaid_pre_attrs: pre_attrs
      )

    html = MDEx.to_html!(document)

    assert html =~ "<!-- mermaid already loaded -->"
    assert html =~ ~s(<pre id="chart-1" class="mermaid-chart">)
    refute html =~ "import mermaid from"
    refute html =~ ~s(phx-update="ignore")
  end

  test "no init script when no mermaid blocks" do
    markdown = """
    # Regular Markdown

    ```elixir
    IO.puts("hello")
    ```
    """

    html =
      MDEx.new(markdown: markdown)
      |> MDExMermaid.attach()
      |> MDEx.to_html!()

    refute html =~ "<script"
    refute html =~ "mermaid"
  end
end
