require('custom.treesitter')

require'nvim-treesitter.configs'.setup {
  ensure_installed = { "terraform", "lua", "python" }, -- Exemple de langages
  highlight = {
    enable = true,
  },
  -- Ajoutez ici d'autres configurations nvim-treesitter si nécessaire
}
