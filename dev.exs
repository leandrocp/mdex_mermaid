Mix.install([
  {:phoenix_playground, "~> 0.1"},
  {:mdex_mermaid, path: "."}
])

defmodule DemoLive do
  use Phoenix.LiveView

  def mount(_params, _session, socket) do
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

    mdex = MDEx.new() |> MDExMermaid.attach()
    html = MDEx.to_html!(mdex, document: markdown)

    IO.puts(html)

    html = {:safe, html}

    {:ok, assign(socket, html: html)}
  end

  def render(assigns) do
    ~H"""
    <script src="https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4"></script>

    <body class="min-h-screen">
      <div class="container mx-auto py-8 px-4 sm:px-6 lg:px-8">
        <%= @html %>
      </div>
    </body>
    """
  end
end

PhoenixPlayground.start(live: DemoLive, open_browser: false)
