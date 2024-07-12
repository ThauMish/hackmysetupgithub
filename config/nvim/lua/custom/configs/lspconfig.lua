local on_attach = require("plugins.configs.lspconfig").on_attach
local capabilities = require("plugins.configs.lspconfig").capabilities

local lspconfig = require "lspconfig"

-- if you just want default config for the servers then put them in a table
local servers = { "html", "cssls", "tsserver", "clangd", "helm_ls", "terraformls", "ansiblels", "dockerls" }

for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = on_attach,
    capabilities = capabilities,
  }
end
--
lspconfig.yamlls.setup{
  on_attach = function(client, bufnr)
    -- Votre code d'attachement ici (facultatif)
  end,
  capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities()), -- Pour la complétion si vous utilisez nvim-cmp
  settings = {
    yaml = {
      schemas = {
        -- Docker
        ['https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json'] = '/docker-compose*.yml',
        ['https://json.schemastore.org/dockerd'] = '/dockerd*.json',

        -- Ansible
        ['https://raw.githubusercontent.com/ansible/ansible-lint/main/src/ansiblelint/schemas/role-arg-spec.json'] = '/**/argument_spec*.json',
        ['https://raw.githubusercontent.com/ansible/ansible-lint/main/src/ansiblelint/schemas/galaxy.json'] = '/**/galaxy.yml',
        ['https://raw.githubusercontent.com/ansible/ansible-lint/main/src/ansiblelint/schemas/execution-environment.json'] = '/**/execution-environment.yml',
        ['https://raw.githubusercontent.com/ansible/ansible-lint/main/src/ansiblelint/schemas/inventory.json'] = '/**/*inventory.yml',
        ['https://raw.githubusercontent.com/ansible/ansible-lint/main/src/ansiblelint/schemas/meta.json'] = '/**/meta/main.yml',
        ['https://raw.githubusercontent.com/ansible/ansible-navigator/main/src/ansible_navigator/data/ansible-navigator.json'] = '/**/.ansible-navigator.yml',
        ['https://raw.githubusercontent.com/ansible/ansible-lint/main/src/ansiblelint/schemas/ansible.json#/$defs/playbook'] = '/**/*playbook.yml',
        ['https://raw.githubusercontent.com/ansible/ansible-lint/main/src/ansiblelint/schemas/requirements.json'] = '/**/requirements.yml',
        ['https://raw.githubusercontent.com/ansible/ansible-lint/main/src/ansiblelint/schemas/ansible.json#/$defs/tasks'] = '/**/tasks/*.yml',
        ['https://raw.githubusercontent.com/ansible/ansible-lint/main/src/ansiblelint/schemas/vars.json'] = '/**/vars/*.yml',
        ['https://raw.githubusercontent.com/ansible/ansible-lint/main/src/ansiblelint/schemas/ansible-lint-config.json'] = '/**/.ansible-lint',

        -- Kubernetes and Helm
        ['https://json.schemastore.org/chart-lock'] = '/**/Chart.lock',
        ['https://json.schemastore.org/chart'] = '/**/Chart.yaml',
        ['https://json.schemastore.org/helm-unittest'] = '/**/*unittests.yaml',
        ['https://json.schemastore.org/helmfile'] = '/**/helmfile*.yaml',
        ['https://json.schemastore.org/helmwave'] = '/**/helmwave.yml',
        ['https://kubernetesjsonschema.dev/v1.14.0/deployment-apps-v1.json'] = '/*deployment*.yaml',
        ['https://kubernetesjsonschema.dev/v1.10.3-standalone/service-v1.json'] = '/*service*.yaml',

        -- GitHub
        ['https://json.schemastore.org/github-action'] = '/.github/actions/*.yml',
        ['https://json.schemastore.org/github-workflow'] = '/.github/workflows/*',
        ['https://json.schemastore.org/github-funding'] = '/.github/FUNDING.yml',
        ['https://json.schemastore.org/github-issue-forms'] = '/.github/ISSUE_TEMPLATE/*.yml',
        ['https://json.schemastore.org/github-issue-template'] = '/.github/ISSUE_TEMPLATE/config.yml',
        ['https://json.schemastore.org/github-workflow-template-properties'] = '/.github/workflow-templates/*.properties.json',
        ['https://json.schemastore.org/gitlab-ci'] = '/.gitlab-ci.yml',
      },
      validate = true, -- Activer la validation YAML avec le schéma spécifié
      hover = true, -- Activer l'info-bulle sur survol
      completion = true, -- Activer la complétion automatique
    },
  },
}

lspconfig.helm_ls.setup {
settings = {
  ['helm-ls'] = {
    yamlls = {
      path = "yaml-language-server",
    }
  }
}
}




lspconfig.dockerls.setup {
  on_attach = on_attach,
  filetypes = { "Dockerfile" },
  settings = {}
}


