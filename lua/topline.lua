---------------------------------------------------------------------------------------------------
------------------------------------TopLine.nvim --------------------------------------------------
---------------------------------------------------------------------------------------------------
-- Author: mnjm (github.com/mnjm)
-- Repo: (github.com/mnjm/topline.nvim)
-- File - lua/topline.lua
-- License - Refer github

local M = {}

-- import modules
local config = require('topline.config')
local utils = require('topline.utils')

-- get file icon if available
-- @param fpath file path
-- @return icon if found else ""
local get_icon = function(fpath)
    if not M.config.enable_icons then return "" end
    return utils.get_icon(fpath)
end

-- get filename and tags like modified, readonly, help...
-- @param buf bufid
-- @return filename with tags
local get_fname_and_tag = function(buf)
    local fpath = vim.api.nvim_buf_get_name(buf)
    local label = " [No Name] "
    if fpath ~= "" then
        local icon = get_icon(fpath)
        label = string.format(" %s %s ", icon, vim.fn.fnamemodify(fpath, ':t'))
    end
    -- Tags
    if vim.bo[buf].buftype == "quickfix" then
        label = label.."[QFXLST]"
    end
    if vim.bo[buf].modified then
        label = label.."[+]"
    end
    if vim.bo[buf].readonly then
        label = label.."[RO]"
    end
    if vim.bo[buf].buftype == "help" then
        label = label.."[HELP]"
    end
    return label
end

-- generate tab title given id with win count prepended
-- @param tab_id tab handle
-- @return tab title string
local get_tablabel = function(tab_id)
    -- Get n_windows and modified flag
    local win_ids = vim.api.nvim_tabpage_list_wins(tab_id)
    local buf_modified = false
    local tablabel = ""
    -- Remove relative windows (like autocomplete wins) from the count
    local n_fixed_wins = 0
    for _, id in ipairs(win_ids) do
        if utils.is_window_fixed(id) then
            n_fixed_wins = n_fixed_wins + 1
            local buf_id = vim.api.nvim_win_get_buf(id)
            buf_modified = buf_modified or vim.bo[buf_id].modified
        end
    end
    if n_fixed_wins > 1 then
        tablabel = string.format(" [%d%s]", n_fixed_wins, buf_modified and "+" or "")
    end

    -- get current buf name
    local cur_win_id = vim.api.nvim_tabpage_get_win(tab_id)
    local cur_buf_id  = vim.api.nvim_win_get_buf(cur_win_id)
    tablabel = tablabel .. get_fname_and_tag(cur_buf_id)

    -- format
    local lbl_n = tablabel:len()
    if lbl_n < M.config.title_len then
        tablabel = tablabel .. string.rep(" ", M.config.title_len - lbl_n)
    end
    return tablabel
end

-- callback for onclick | switchs to clicked tab using tab_id arg
-- @param data from user command - this is assumed to contain tab handle in args[1]
local topline_onclick_callback = function(data)
    local tab_id = tonumber(data["fargs"][1])
    vim.api.nvim_set_current_tabpage(tab_id)
end

-- generate onclick call register if supported
-- @param tab_id tab handle
-- @return onclick that gets added to tabline
local get_onclick_call = function(tab_id)
    local ret = ""
    if M.is_tabclick_supported then
        ret = string.format('%%%d@TopLineClickFunc@', tab_id)
    end
    return ret
end

-- main generate tabline
-- @return tabline string
M.generate_tabline = function()
    local tabline = ""
    local tabpage_ids = vim.api.nvim_list_tabpages()
    local cur_tabpage = vim.api.nvim_get_current_tabpage()
    local label, hl_grp, onclick, sep = "", "", "", nil
    for _, tid in ipairs(tabpage_ids) do
        label = get_tablabel(tid)
        if tid == cur_tabpage then
            hl_grp = "%#TopLineSel#"
            sep = M.prep_seperators.sel
        else
            hl_grp = "%#TopLine#"
            sep = M.prep_seperators.norm
        end
        onclick = get_onclick_call(tid)
        tabline = tabline .. table.concat( {
            sep.pre,
            hl_grp,
            onclick,
            label,
            sep.post,
            "%#TopLineFill# ",
        })
    end

    -- add autofil and close button
    tabline = tabline .. "%#TopLineFill#" .. "%=%#TopLineSel#%999X[X]"
    return tabline
end

-- setup callbacks for taplick switcher
local setup_onclick_func = function()
    M.is_tabclick_supported = vim.fn.has('tablinat')
    -- I couldn't find anyway to switch to tab using tab_id in vim script, so had to create a user
    -- command and call that with vim script.
    if M.is_tabclick_supported then
        -- vim func
        vim.cmd(
            [[function! TopLineClickFunc(tab_id, clicks, button, mod)
            execute 'ToplineOnClickCallUserCmd' a:tab_id
            endfunction]]
        )
        -- User command calling lua callback(?)
        vim.api.nvim_create_user_command('ToplineOnClickCallUserCmd', topline_onclick_callback,
            {nargs = "?", desc = 'Topline,nvim: On click callback user command'})
    end
end

-- init_topline - Setup highlight groups and seperators
local init_topline = function()
    -- setup highlights
    utils.setup_highlights(M.config.highlights)

    -- override TopLineSel - make it bold
    local data = vim.api.nvim_get_hl(0, { name = 'TopLineSel', link = false })
    data = vim.deepcopy(data)
    data['bold'] = true
    vim.api.nvim_set_hl(0, 'TopLineSel', data)

    -- Create seperator highlights
    data = vim.api.nvim_get_hl(0, { name = 'TopLine', link = false })
    -- Use background as foreground for seperators
    local norm_fg = data.bg
    data = vim.api.nvim_get_hl(0, { name = 'TopLineSel', link = false })
    local sel_fg = data.bg
    -- Use fill hl background
    data = vim.api.nvim_get_hl(0, { name = 'TopLineFill', link = false })
    local bg = data.bg
    vim.api.nvim_set_hl(0, "TopLineSelInvert", { fg = sel_fg, bg = bg })
    vim.api.nvim_set_hl(0, "TopLineInvert", { fg = norm_fg, bg = bg })
    -- Prepare seperators
    M.prep_seperators = {
        norm = {
            pre = "%#TopLineInvert#" .. M.config.seperator.pre,
            post = "%#TopLineInvert#" .. M.config.seperator.post,
        },
        sel = {
            pre = "%#TopLineSelInvert#" .. M.config.seperator.pre,
            post = "%#TopLineSelInvert#" .. M.config.seperator.post,
        },
    }
end

-- setup func
-- @param cfg custom config table
M.setup = function(cfg)
    -- Exposing plugin
    _G._topline = M
    -- init config
    M.config = config.init_config(cfg)
    -- setup highlights
    init_topline()
    -- setup onclick calls
    setup_onclick_func()
    -- set tabline string
    vim.o.tabline = '%!v:lua._topline.generate_tabline()'
end

return M
