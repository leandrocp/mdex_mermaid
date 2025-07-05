Mix.install([
  {:phoenix_playground, "~> 0.1"},
  {:mdex_mermaid, path: ".."}
])

defmodule DemoLayout do
  use Phoenix.Component

  def render("root.html", assigns) do
    ~H"""
    <!DOCTYPE html>
    <html lang="en" class="h-full">
      <head>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <title>mdex-mermaid</title>
      </head>
      <body>
        <script src="https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4"></script>

        <script type="module">
          import mermaid from 'https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.esm.min.mjs';
          mermaid.initialize({ startOnLoad: false, securityLevel: 'loose' });
          window.mermaid = mermaid;
        </script>

        <script src="/assets/phoenix/phoenix.js"></script>
        <script src="/assets/phoenix_live_view/phoenix_live_view.js"></script>

        <script>
          let hooks = {
            MermaidHook: {
              mounted() {
                window.mermaid.run({
                  nodes: [this.el],
                  querySelector: '.mermaid'
                });
              }
            }
          }

          let liveSocket =
            new window.LiveView.LiveSocket(
              "/live",
              window.Phoenix.Socket,
              { hooks }
            )
          liveSocket.connect()

          window.addEventListener("phx:live_reload:attached", ({detail: reloader}) => {
            reloader.enableServerLogs()
            window.liveReloader = reloader
          })
        </script>

        <%= @inner_content %>
      </body>
    </html>
    """
  end
end

defmodule MindmapLive do
  use Phoenix.LiveView

  @mermaid_init """
  """

  def mount(_params, _session, socket) do
    markdown = """
    # Mindmap

    ```mermaid
    mindmap
      root((mindmap))
        Origins
          Long history
          ::icon(fa fa-book)
          Popularisation
            British popular psychology author Tony Buzan
        Research
          On effectiveness<br/>and features
          On Automatic creation
            Uses
                Creative techniques
                Strategic planning
                Argument mapping
        Tools
          Pen and paper
          Mermaid
    ```
    """

    mdex =
      MDEx.new()
      |> MDExMermaid.attach(
        mermaid_init: "",
        mermaid_pre_attrs: fn seq ->
          ~s(id="mermaid-#{seq}" class="mermaid" phx-hook="MermaidHook" phx-update="ignore")
        end
      )

    html = MDEx.to_html!(mdex, document: markdown)
    {:ok, assign(socket, html: {:safe, html})}
  end

  def render(assigns) do
    ~H"""
    <script>
    </script>

    <div class="min-h-screen">
      <div class="container mx-auto py-8 px-4 sm:px-6 lg:px-8">
        <%= @html %>
      </div>
    </div>
    """
  end
end

defmodule DemoLive do
  use Phoenix.LiveView

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <body class="min-h-screen">
      <div class="container mx-auto py-8 px-4 sm:px-6 lg:px-8">
        <h1 class="text-xl">Demos</h1>

        <ul>
          <li><.link patch={"/mindmap"} class="text-blue-500">Mindmap</.link></li>
        </ul>
      </div>
    </body>
    """
  end
end

defmodule DemoRouter do
  use Phoenix.Router
  import Phoenix.LiveView.Router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:put_root_layout, html: {DemoLayout, :root})
    plug(:put_secure_browser_headers)
  end

  scope "/" do
    pipe_through(:browser)
    live("/", DemoLive)
    live("/mindmap", MindmapLive)
  end
end

PhoenixPlayground.start(plug: DemoRouter, open_browser: true)
