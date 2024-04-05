---------------------------------------------------------------------------------------------------
------------------------------------TopLine.nvim --------------------------------------------------
---------------------------------------------------------------------------------------------------
-- Author: mnjm (github.com/mnjm)
-- Repo: (github.com/mnjm/topline.nvim)
-- File - lua/topline/config.lua
-- License - Refer github

local M = {}

-- default configs
local default_config = {
    seperator = { pre = '', post = '' },
    enable_icons = true,
    max_fname_len = 25,     -- min tab title len
    close_icon = "[x]",
    highlights = {          -- highlights
        TopLine         = { link = 'TabLine' },
        TopLineSel      = { link = 'TabLineSel' },
        TopLineFill     = { link = 'TabLineFill' },
    }
}

-- config validator
-- @param cfg config to validate
local validate_config = function(cfg)
    vim.validate({
        seperator = { cfg.seperator, 'table' },
        enable_icons = { cfg.enable_icons, 'boolean' },
        max_fname_len = { cfg.max_fname_len, 'number' },
        close_icon = {cfg.close_icon, 'string'},
        highlights = { cfg.highlights, 'table' },
    })
    vim.validate({
        pre = { cfg.seperator.pre, 'string' },
        post = { cfg.seperator.post, 'string' },
    })
end

-- initialize config
-- @param cfg custom config from setup call
M.init_config = function(cfg)
    vim.validate({ config = {cfg, 'table'} })
    cfg = cfg or {}
    -- extend default_config and keep the changes from custom config (cfg)
    local config = vim.tbl_deep_extend("keep", cfg, default_config)
    validate_config(config)
    return config
end

return M
