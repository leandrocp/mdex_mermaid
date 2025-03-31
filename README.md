# MDExMermaid

[![Hex.pm](https://img.shields.io/hexpm/v/mdex_mermaid)](https://hex.pm/packages/mdex_mermaid)
[![Hexdocs](https://img.shields.io/badge/hexdocs-latest-blue.svg)](https://hexdocs.pm/mdex_mermaid)

<!-- MDOC -->

[MDEx](https://mdelixir.dev) plugin for [Mermaid](https://mermaid.js.org).

## Usage

````elixir
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

mdex =
  MDEx.new()
  |> MDExMermaid.attach()

# format to HTML
MDEx.to_html(mdex, document: document)
````

See [attach/2](https://hexdocs.pm/mdex_mermaid/MDExMermaid.html#attrach/2) for more info.
