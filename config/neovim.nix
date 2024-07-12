{ pkgs, inputs, ... }:
let
  finecmdline = pkgs.vimUtils.buildVimPlugin {
    name = "fine-cmdline";
    src = inputs.fine-cmdline;
  };
in
{
  programs = {
    neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
      withNodeJs = true;
      extraPackages = with pkgs; [
        lua-language-server
        gopls
        xclip
        wl-clipboard
        luajitPackages.lua-lsp
        nil
        rust-analyzer
        yaml-language-server
        pyright
        marksman
        docker-compose
        docker
        typescript-language-server
        bash-language-server
      ];
      plugins = with pkgs.vimPlugins; [
        alpha-nvim
        auto-session
        bufferline-nvim
        dressing-nvim
        indent-blankline-nvim
        nui-nvim
        finecmdline
        nvim-treesitter.withAllGrammars
        lualine-nvim
        nvim-autopairs
        nvim-web-devicons
        nvim-cmp
        nvim-surround
        nvim-lspconfig
        cmp-nvim-lsp
        cmp-buffer
        luasnip
        cmp_luasnip
        friendly-snippets
        lspkind-nvim
        comment-nvim
        nvim-ts-context-commentstring
        plenary-nvim
        neodev-nvim
        telescope-nvim
        todo-comments-nvim
        nvim-tree-lua
        telescope-fzf-native-nvim
        vim-tmux-navigator
        gitsigns-nvim
        nvim-lsp-installer
        which-key-nvim
        semgrep
      ];
      extraConfig = ''
        set noemoji
        nnoremap : <cmd>FineCmdline<CR>
        augroup filetype_yaml_ansible
          autocmd!
          autocmd BufRead,BufNewFile */roles/*.yml,*/roles/*.yaml,*/tasks/*.yml,*/tasks/*.yaml,*/handlers/*.yml,*/handlers/*.yaml set filetype=yaml.ansible
          autocmd BufRead,BufNewFile */group_vars/*.yml,*/group_vars/*.yaml,*/host_vars/*.yml,*/host_vars/*.yaml set filetype=yaml.ansible
          autocmd BufRead,BufNewFile *playbook.yml,*playbook.yaml,site.yml,site.yaml set filetype=yaml.ansible
        augroup END
        augroup filetype_yaml_docker
          autocmd!
          autocmd BufRead,BufNewFile *docker-compose*.yml,*docker-compose*.yaml set filetype=yaml.docker
        augroup END
        augroup filetype_yaml_helm
          autocmd!
          autocmd BufRead,BufNewFile */charts/*.yml,*/charts/*.yaml,*/templates/*.yml,*/templates/*.yaml set filetype=helm
        augroup END
        augroup filetype_terraform
          autocmd!
          autocmd BufRead,BufNewFile *.tf,*.tfvars set filetype=terraform
        augroup END
        augroup filetype_force
          autocmd!
          autocmd BufRead,BufNewFile *.yaml set filetype=yaml
          autocmd BufRead,BufNewFile *.tf set filetype=terraform
          autocmd BufRead,BufNewFile *.helm set filetype=helm
        augroup END
      '';
      extraLuaConfig = ''
        ${builtins.readFile ./nvim/options.lua}
        ${builtins.readFile ./nvim/keymaps.lua}
        ${builtins.readFile ./nvim/plugins/alpha.lua}
        ${builtins.readFile ./nvim/plugins/autopairs.lua}
        ${builtins.readFile ./nvim/plugins/auto-session.lua}
        ${builtins.readFile ./nvim/plugins/comment.lua}
        ${builtins.readFile ./nvim/plugins/cmp.lua}
        ${builtins.readFile ./nvim/plugins/lsp.lua}
        ${builtins.readFile ./nvim/plugins/nvim-tree.lua}
        ${builtins.readFile ./nvim/plugins/telescope.lua}
        ${builtins.readFile ./nvim/plugins/todo-comments.lua}
        ${builtins.readFile ./nvim/plugins/treesitter.lua}
        ${builtins.readFile ./nvim/plugins/fine-cmdline.lua}
        require("ibl").setup()
        require("bufferline").setup{}
        require("lualine").setup({
          icons_enabled = true,
        })
        require('gitsigns').setup()
        require('mason').setup()
        require('mason-lspconfig').setup({
          ensure_installed = { "html", "cssls", "tsserver", "clangd", "helm_ls", "terraformls", "ansiblels", "dockerls", "yamlls", "bashls" },
          automatic_installation = true,
        })
        require("which-key").setup {}
        local wk = require("which-key")
        wk.register({
          f = {
            name = "file", -- group name
            s = { ":w<CR>", "Save File" },
            f = { ":Telescope find_files<CR>", "Find Files" },
            r = { ":Telescope live_grep<CR>", "Search in Files" },
          },
          q = { ":q<CR>", "Quit" },
          e = { ":NvimTreeToggle<CR>", "Explorer" },
        }, { prefix = "<leader>" })
        vim.api.nvim_set_keymap('n', '<C-s>', ':w<CR>', { noremap = true, silent = true })
        vim.api.nvim_set_keymap('n', '<leader>q', ':q<CR>', { noremap = true, silent = true })
        vim.api.nvim_set_keymap('n', '<leader>fm', ':lua vim.lsp.buf.formatting()<CR>', { noremap = true, silent = true })
        vim.api.nvim_set_keymap('n', '<C-c>', 'ggVGy', { noremap = true, silent = true })
        vim.api.nvim_set_keymap('n', '<Esc>', ':noh<CR>', { noremap = true, silent = true })
        augroup SemgrepAutocmd
          autocmd!
          autocmd BufWritePost *.py,*.js,*.yaml !semgrep --config=p/security-audit --exclude-dir=node_modules
        augroup END
      '';
    };
  };
}
