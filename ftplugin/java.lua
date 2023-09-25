local mason_root = require("mason.settings").current.install_root_dir
local install_path = require("mason-registry").get_package("jdtls"):get_install_path()
local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
-- calculate workspace dir
local workspace_dir = vim.fn.stdpath("data") .. "/site/java/workspace-root/" .. project_name

-- get the current OS
local os
if vim.fn.has "mac" == 1 then
    os = "mac"
elseif vim.fn.has "unix" == 1 then
    os = "linux"
elseif vim.fn.has "win32" == 1 then
    os = "win"
end
-- ensure that OS is valid
if not os or os == "" then
    return
end
local config = {
  cmd = {
    "java",
    "-Declipse.application=org.eclipse.jdt.ls.core.id1",
    "-Dosgi.bundles.defaultStartLevel=4",
    "-Declipse.product=org.eclipse.jdt.ls.core.product",
    "-Dlog.protocol=true",
    "-Dlog.level=ALL",
    "-javaagent:" .. install_path .. "/lombok.jar",
    "-Xms1g",
    "--add-modules=ALL-SYSTEM",
    "--add-opens",
    "java.base/java.util=ALL-UNNAMED",
    "--add-opens",
    "java.base/java.lang=ALL-UNNAMED",
    "-jar",
    vim.fn.glob(install_path .. "/plugins/org.eclipse.equinox.launcher_*.jar"),
    "-configuration",
    install_path .. "/config_" .. os,
    "-data",
    workspace_dir,
  },
  root_dir = vim.fs.dirname(vim.fs.find({'pom.xml', 'gradlew', '.git', 'mvnw'}, { })[1]),
}
require('jdtls').start_or_attach(config)

local status_ok, which_key = pcall(require, "which-key")
if not status_ok then return end

local mappings = {
  c = {
    name = "Code",
    o = { "<Cmd>lua require('jdtls').organize_imports()<CR>", "Organize Imports" },
    v = { "<Cmd>lua require('jdtls').extract_variable()<CR>", "Extract Variable" },
    c = { "<Cmd>lua require('jdtls').extract_constant()<CR>", "Extract Constant" },
    t = { "<Cmd>lua require'jdtls'.test_nearest_method()<CR>", "Test Method" },
    T = { "<Cmd>lua require'jdtls'.test_class()<CR>", "Test Class" },
    u = { "<Cmd>JdtUpdateConfig<CR>", "Update Config" },
    a = { "<Cmd>lua AttachDebugLocalhost()<CR>", "Attach Debugger" },
  },
}

local vmappings = {
  c = {
    name = "Code",
    v = { "<Esc><Cmd>lua require('jdtls').extract_variable(true)<CR>", "Extract Variable" },
    c = { "<Esc><Cmd>lua require('jdtls').extract_constant(true)<CR>", "Extract Constant" },
    m = { "<Esc><Cmd>lua require('jdtls').extract_method(true)<CR>", "Extract Method" },
  },
}

which_key.register(mappings, {
  mode = "n", -- NORMAL mode
  prefix = "<leader>",
  buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
  silent = true, -- use `silent` when creating keymaps
  noremap = true, -- use `noremap` when creating keymaps
  nowait = true, -- use `nowait` when creating keymaps
})

which_key.register(vmappings, {
  mode = "v", -- VISUAL mode
  prefix = "<leader>",
  buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
  silent = true, -- use `silent` when creating keymaps
  noremap = true, -- use `noremap` when creating keymaps
  nowait = true, -- use `nowait` when creating keymaps
})

