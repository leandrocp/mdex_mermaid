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
                   querySelector: '.mermaid'
                 });
              }
            },

            MermaidGlobalHook: {
              mounted() {
                 window.mermaid.run({
                   querySelector: '.mermaid'
                 });

              },
              updated() {
                 window.mermaid.run({
                   querySelector: '.mermaid'
                 });
              }
            },
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
      MDEx.new(markdown: markdown)
      |> MDExMermaid.attach(
        mermaid_init: "",
        mermaid_pre_attrs: fn seq ->
          ~s(id="mermaid-#{seq}" class="mermaid" phx-hook="MermaidHook")
        end
      )

    html = MDEx.to_html!(mdex)
    {:ok, assign(socket, html: {:safe, html})}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <script>
    </script>

    <div class="min-h-screen">
      <nav class="bg-gray-800 text-white">
        <div class="container mx-auto px-4 sm:px-6 lg:px-8">
          <div class="flex items-center justify-between h-16">
            <div class="flex items-center">
              <div class="flex space-x-4">
                <.link patch="/mindmap" class="px-3 py-2 rounded-md text-sm font-medium hover:bg-gray-700">
                  Mindmap
                </.link>
                <.link patch="/gantt" class="px-3 py-2 rounded-md text-sm font-medium hover:bg-gray-700">
                  Gantt Chart
                </.link>
              </div>
            </div>
          </div>
        </div>
      </nav>
      <div class="container mx-auto py-8 px-4 sm:px-6 lg:px-8">
        <%= @html %>
      </div>
    </div>
    """
  end
end

defmodule GanttLive do
  use Phoenix.LiveView

  def mount(_params, _session, socket) do
    socket
    |> assign(:example_1, true)
    |> assign(:example_2, false)
    |> assign(:html, {:safe, example_1()})
    |> then(&{:ok, &1})
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  defp example_1 do
    example_1 = """
    # Gantt Chart - Example 1

    ```mermaid
    gantt
        title A Gantt Diagram
        dateFormat YYYY-MM-DD
        section Section
            A task          :a1, 2014-01-01, 30d
            Another task    :after a1, 20d
        section Another
            Task in Another :2014-01-12, 12d
            another task    :24d
    ```
    """

    MDEx.new(markdown: example_1)
    |> MDExMermaid.attach(
      mermaid_init: "",
      mermaid_pre_attrs: fn seq ->
        ~s(id="mermaid-#{seq}" class="mermaid")
      end
    )
    |> MDEx.to_html!()
  end

  defp example_2 do
    example_2 = """
    # Gantt Chart - Example 2

    ```mermaid
    gantt
        dateFormat  YYYY-MM-DD
        title       Adding GANTT diagram functionality to mermaid
        excludes    weekends
        %% (`excludes` accepts specific dates in YYYY-MM-DD format, days of the week ("sunday") or "weekends", but not the word "weekdays".)

        section A section
        Completed task            :done,    des1, 2014-01-06,2014-01-08
        Active task               :active,  des2, 2014-01-09, 3d
        Future task               :         des3, after des2, 5d
        Future task2              :         des4, after des3, 5d

        section Critical tasks
        Completed task in the critical line :crit, done, 2014-01-06,24h
        Implement parser and jison          :crit, done, after des1, 2d
        Create tests for parser             :crit, active, 3d
        Future task in critical line        :crit, 5d
        Create tests for renderer           :2d
        Add to mermaid                      :until isadded
        Functionality added                 :milestone, isadded, 2014-01-25, 0d

        section Documentation
        Describe gantt syntax               :active, a1, after des1, 3d
        Add gantt diagram to demo page      :after a1  , 20h
        Add another diagram to demo page    :doc1, after a1  , 48h

        section Last section
        Describe gantt syntax               :after doc1, 3d
        Add gantt diagram to demo page      :20h
        Add another diagram to demo page    :48h
    ```
    """

    MDEx.new(markdown: example_2)
    |> MDExMermaid.attach(
      mermaid_init: "",
      mermaid_pre_attrs: fn seq ->
        ~s(id="mermaid-#{seq}" class="mermaid")
      end
    )
    |> MDEx.to_html!()
  end

  def handle_event("show_example_1", _params, socket) do
    socket
    |> assign(:example_1, true)
    |> assign(:example_2, false)
    |> assign(:html, {:safe, example_1()})
    |> then(&{:noreply, &1})
  end

  def handle_event("show_example_2", _params, socket) do
    socket
    |> assign(:example_1, false)
    |> assign(:example_2, true)
    |> assign(:html, {:safe, example_2()})
    |> then(&{:noreply, &1})
  end

  def render(assigns) do
    ~H"""
    <div id="gantt-demo" class="min-h-screen" phx-hook="MermaidGlobalHook">
      <nav class="bg-gray-800 text-white">
        <div class="container mx-auto px-4 sm:px-6 lg:px-8">
          <div class="flex items-center justify-between h-16">
            <div class="flex items-center">
              <div class="flex space-x-4">
                <.link patch="/mindmap" class="px-3 py-2 rounded-md text-sm font-medium hover:bg-gray-700">
                  Mindmap
                </.link>
                <.link patch="/gantt" class="px-3 py-2 rounded-md text-sm font-medium hover:bg-gray-700">
                  Gantt Chart
                </.link>
              </div>
            </div>
          </div>
        </div>
      </nav>
      <div class="container mx-auto py-8 px-4 sm:px-6 lg:px-8">
        <div class="mb-4 flex gap-4">
          <button 
            phx-click="show_example_1" 
            class={"px-4 py-2 rounded " <> if @example_1, do: "bg-blue-500 text-white", else: "bg-gray-200"}>
            Example 1
          </button>
          <button 
            phx-click="show_example_2"
            class={"px-4 py-2 rounded " <> if @example_2, do: "bg-blue-500 text-white", else: "bg-gray-200"}>
            Example 2
          </button>
        </div>
        
        <div :if={@example_1}>
          <%= @html %>
        </div>
        
        <div :if={@example_2}>
          <%= @html %>
        </div>
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
          <li><.link patch={"/gantt"} class="text-blue-500">Gantt Chart</.link></li>
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
    live("/gantt", GanttLive)
  end
end

PhoenixPlayground.start(plug: DemoRouter, open_browser: true)
