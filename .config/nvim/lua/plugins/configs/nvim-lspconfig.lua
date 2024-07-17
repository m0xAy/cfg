local lsp = require("lspconfig")
local mason_lsp = require("mason-lspconfig")

local signs = {
  { name = "DiagnosticSignError", text = "󰅙" },
  { name = "DiagnosticSignWarn", text = "󰀦" },
  { name = "DiagnosticSignHint", text = "󰋼" },
  { name = "DiagnosticSignInfo", text = "󰋗" },
}

for _, sign in ipairs(signs) do
  vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = "" })
end

local config = {
  virtual_text = true,
  signs = {
    active = signs,
  },
  float = {
    style = "minimal",
    border = "rounded",
    source = "always",
    header = "",
    prefix = "",
  },
}

vim.diagnostic.config(config)

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
  border = "rounded",
})

vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
  border = "rounded",
})

local on_attach = function(client, bufnr)
  local map = vim.keymap.set

  if client.name == "tsserver" then
    client.server_capabilities.document_formatting = false
    require("twoslash-queries").attach(client, bufnr)
  end

  vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

  map(
    "n",
    "<leader>ld",
    vim.lsp.buf.definition,
    { desc = "Go to definition", noremap = true, silent = true, buffer = bufnr }
  )
  map(
    "n",
    "<leader>lr",
    vim.lsp.buf.references,
    { desc = "Find references", noremap = true, silent = true, buffer = bufnr }
  )
  map(
    "n",
    "<leader>li",
    vim.lsp.buf.implementation,
    { desc = "Go to implementation", noremap = true, silent = true, buffer = bufnr }
  )
  map("n", "K", vim.lsp.buf.hover, { desc = "Hover", noremap = true, silent = true, buffer = bufnr })
  map(
    "n",
    "<leader>ln",
    vim.lsp.buf.rename,
    { desc = "Rename symbol", noremap = true, silent = true, buffer = bufnr }
  )
  map(
    "n",
    "<leader>la",
    vim.lsp.buf.code_action,
    { desc = "Code actions", noremap = true, silent = true, buffer = bufnr }
  )
  map("n", "<leader>lf", function()
    vim.lsp.buf.format({ async = true })
  end, { desc = "Format", noremap = true, silent = true, buffer = bufnr })
end

local lsp_flags = {
  debounce_text_changes = 150,
}

local capabilities = vim.lsp.protocol.make_client_capabilities()

mason_lsp.setup_handlers({
  function(server_name)
    lsp[server_name].setup({
      on_attach = on_attach,
      flags = lsp_flags,
      capabilities = capabilities,
    })
  end,
  ["lua_ls"] = function()
    lsp.lua_ls.setup({
      on_attach = on_attach,
      flags = lsp_flags,
      capabilities = capabilities,
      settings = {
        Lua = {
          diagnostics = {
            globals = { "vim" },
          },
        },
      },
    })
  end,
})
