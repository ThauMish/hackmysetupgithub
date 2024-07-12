-- local autocmd = vim.api.nvim_create_autocmd

-- Auto resize panes when resizing nvim window
-- autocmd("VimResized", {
--   pattern = "*",
--   command = "tabdo wincmd =",
-- })
--

vim.cmd [[
  augroup filetype_yaml_ansible
    autocmd!
    autocmd BufRead,BufNewFile */roles/*.yml,*/roles/*.yaml,*/tasks/*.yml,*/tasks/*.yaml,*/handlers/*.yml,*/handlers/*.yaml set filetype=yaml.ansible
    autocmd BufRead,BufNewFile */group_vars/*.yml,*/group_vars/*.yaml,*/host_vars/*.yml,*/host_vars/*.yaml set filetype=yaml.ansible
    autocmd BufRead,BufNewFile *playbook.yml,*playbook.yaml,site.yml,site.yaml set filetype=yaml.ansible
  augroup END
]]

vim.cmd [[
  augroup filetype_yaml_docker
    autocmd!
    autocmd BufRead,BufNewFile *docker-compose*.yml,*docker-compose*.yaml set filetype=yaml.docker
  augroup END
]]

vim.cmd [[
  augroup filetype_yaml_helm
    autocmd!
    autocmd BufRead,BufNewFile */charts/*.yml,*/charts/*.yaml,*/templates/*.yml,*/templates/*.yaml set filetype=helm
  augroup END
]]

vim.cmd [[
  augroup filetype_terraform
    autocmd!
    autocmd BufRead,BufNewFile *.tf,*.tfvars set filetype=terraform
  augroup END
]]
