# MDExMermaid

[![Hex.pm](https://img.shields.io/hexpm/v/mdex_mermaid)](https://hex.pm/packages/mdex_mermaid)
[![Hexdocs](https://img.shields.io/badge/hexdocs-latest-blue.svg)](https://hexdocs.pm/mdex_mermaid)

<!-- MDOC -->

[MDEx](https://mdelixir.dev) plugin for [Mermaid](https://mermaid.js.org).

## Usage

````elixir
Mix.install([
  {:mdex_mermaid, "~> 0.1"}
])

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

MDEx.to_html!(mdex, document: markdown) |> IO.puts()
#=>
# <script type="module">
#   import mermaid from 'https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.esm.min.mjs';
#   const theme = window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'default';
#   mermaid.initialize({securityLevel: 'loose', theme: theme});
# </script>
# <h1>Flowchart</h1>
# <pre id="mermaid-1" class="mermaid" phx-update="ignore">graph TD;
#     A-->B;
#     A-->C;
#     B-->D;
#     C-->D;
# </pre>
````

See [attach/2](https://hexdocs.pm/mdex_mermaid/MDExMermaid.html#attach/2) for more info.
