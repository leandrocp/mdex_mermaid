defmodule MDExMermaid do
  @external_resource "README.md"

  @moduledoc "README.md"
             |> File.read!()
             |> String.split("<!-- MDOC -->")
             |> Enum.fetch!(1)

  alias MDEx.Pipe

  @default_version "11"
  @default_security_level "loose"

  @doc """
  Attaches the MDExMermaid plugin into the MDEx pipeline.

  - Mermaid is loaded from https://www.jsdelivr.com/package/npm/mermaid
  - Theme is determined by the user's `prefers-color-scheme` system preference

  ## Options

    - `:version` - The version of mermaid to use. Defaults to #{@default_version}
    - `:security_level` - The [security level](https://mermaid.js.org/config/usage.html#securitylevel) to use for the mermaid diagrams.
      Defaults to "#{@default_security_level}"
  """

  def attach(pipe, options \\ []) do
    pipe
    |> Pipe.register_options([
      :mermaid_version,
      :mermaid_security_level
    ])
    |> Pipe.put_options(
      mermaid_version: options[:version],
      mermaid_security_level: options[:security_level]
    )
    |> Pipe.append_steps(enable_unsafe: &enable_unsafe/1)
    |> Pipe.append_steps(inject_script: &inject_script/1)
    |> Pipe.append_steps(update_code_blocks: &update_code_blocks/1)
  end

  defp enable_unsafe(pipe) do
    Pipe.put_render_options(pipe, unsafe_: true)
  end

  defp inject_script(pipe) do
    version = Pipe.get_option(pipe, :mermaid_version) || @default_version
    security_level = Pipe.get_option(pipe, :mermaid_security_level) || @default_security_level

    script_node =
      %MDEx.HtmlBlock{
        literal: """
        <script type="module">
          import mermaid from 'https://cdn.jsdelivr.net/npm/mermaid@#{version}/dist/mermaid.esm.min.mjs';

          const theme = window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'default';

          mermaid.initialize({
            securityLevel: '#{security_level}',
            theme: theme,
          });
        </script>
        """
      }

    Pipe.put_node_in_document_root(pipe, script_node, :bottom)
  end

  defp update_code_blocks(pipe) do
    {document, _} =
      MDEx.traverse_and_update(pipe.document, 1, fn
        %MDEx.CodeBlock{info: "mermaid"} = node, acc ->
          node =
            %MDEx.HtmlBlock{
              literal:
                "<pre id=\"mermaid-#{acc}\" class=\"mermaid\" phx-update=\"ignore\">#{node.literal}</pre>",
              nodes: node.nodes
            }

          {node, acc + 1}

        node, acc ->
          {node, acc}
      end)

    %{pipe | document: document}
  end
end
