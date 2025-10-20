return {
  recommended = function()
    return LazyVim.extras.wants({
      ft = { "yaml", "yml", "helm", "gotmpl", "yaml.tmpl" },
    })
  end,

  {
    "b0o/SchemaStore.nvim",
    lazy = true,
    version = false,
  },

  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        yamlls = {
          filetypes = { "yaml", "yml", "helm", "gotmpl", "yaml.tmpl" },
          capabilities = {
            textDocument = {
              foldingRange = {
                dynamicRegistration = false,
                lineFoldingOnly = true,
              },
            },
          },
          settings = {
            redhat = { telemetry = { enabled = false } },
            yaml = {
              keyOrdering = false,
              format = { enable = true },
              validate = true,
              schemaStore = {
                enable = false,
                url = "",
              },
              -- optional customTags for template-ish tags
              -- customTags = { "!Ref scalar", "!Sub scalar" },
            },
          },
        },
      },
      setup = {
        yamlls = function(_, server)
          -- Defer loading schemastore until server config time
          local ok, schemastore = pcall(require, "schemastore")
          if ok then
            server.settings = server.settings or {}
            server.settings.yaml = server.settings.yaml or {}
            server.settings.yaml.schemas = schemastore.yaml.schemas()
          end

          -- Per-buffer toggle: disable validation for template filetypes
          server.on_attach = function(client, bufnr)
            local ft = vim.bo[bufnr].filetype
            if ft == "helm" or ft == "gotmpl" or ft == "yaml.tmpl" then
              vim.lsp.buf_notify(bufnr, "workspace/didChangeConfiguration", {
                settings = {
                  yaml = {
                    validate = false,
                  },
                },
              })
            end
          end
        end,
      },
    },
  },
}
