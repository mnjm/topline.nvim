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
    enable = true,
    seperator = { pre = '', post = '' },
    enable_icons = true,
    max_fname_len = 25,     -- max file name len
    close_icon = "[x]",
    highlights = {          -- highlights
        TopLine         = { link = 'TabLine' },               -- tab title
        TopLineSel      = { link = 'TabLineSel' },            -- tab title [Focused]
        TopLineFill     = { link = 'TabLineFill' },           -- filler
        TopLineClose    = { link = 'TabLineSel' },            -- close button
    },
}

-- config validator
-- @param cfg config to validate
local validate_config = function(cfg)
    vim.validate({
        enable = { cfg.enable, 'boolean' },
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
M.init_config = function(user_cfg)
    user_cfg = user_cfg or {}
    -- check if passed config is a table
    vim.validate({ config = {user_cfg, 'table'} })
    -- extend default_config and keep the changes from custom config (cfg)
    local config = vim.tbl_deep_extend("keep", user_cfg, default_config)
    validate_config(config)
    -- clear out the default highlights if any that seeped through when (keep)expanded
    if user_cfg.highlights then
        for name, data in pairs(user_cfg.highlights) do
            config.highlights[name] = data
        end
    end
    return config
end

return M
