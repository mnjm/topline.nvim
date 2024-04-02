---------------------------------------------------------------------------------------------------
------------------------------------TopLine.nvim --------------------------------------------------
---------------------------------------------------------------------------------------------------
-- Author: mnjm (github.com/mnjm)
-- Repo: (github.com/mnjm/topline.nvim)

local M = {}

local default_config = {
    seperator = { pre = '', post = '' },
    enable_icons = true,
    title_len = 15,
}

-- helper func for init
local validate_config = function(cfg)
    vim.validate({
        seperator = { cfg.seperator, 'table' },
        enable_icons = { cfg.enable_icons, 'boolean' },
        title_len = { cfg.title_len, 'number' },
    })
    vim.validate({
        pre = { cfg.seperator.pre, 'string' },
        post = { cfg.seperator.post, 'string' },
    })
end

local init_config = function(cfg)
    vim.validate({ config = {cfg, 'table'} })
    cfg = cfg or {}
    local config = vim.tbl_deep_extend("keep", cfg, default_config)
    validate_config(config)
    return config
end

-- helper func for get_icon
local safe_require = function(module_name)
    local status_ok, mod = pcall(require, module_name)
    if not status_ok then mod = nil end
    return mod
end

-- get icon if available
local get_icon = function(fpath)
    if not M.config.enable_icons then return "" end
    local file_name, file_ext = vim.fn.fnamemodify(fpath, ":t"), vim.fn.fnamemodify(fpath, ":e")
    local dev_icons = safe_require("nvim-web-devicons")
    local icon = ""
    if dev_icons then
        icon = dev_icons.get_icon(file_name, file_ext, { default = true })
    end
    local ftype = vim.bo.filetype
    if ftype == '' then icon = '' end
    return icon
end

-- get filename and tags like modified, readonly, help...
local get_fname_and_tag = function(buf)
    local fpath = vim.api.nvim_buf_get_name(buf)
    local label = ""
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

-- helper func for get_tablabel
local is_window_relative = function(win_id)
    return vim.api.nvim_win_get_config(win_id).relative ~= ''
end

-- generate tab title given id
local get_tablabel = function(tab_id)
    -- Get n_windows and modified flag
    local win_ids = vim.api.nvim_tabpage_list_wins(tab_id)
    local buf_modified = false
    local tablabel = ""
    -- Remove relative windows (like autocomplete wins) from the count
    local n_fixed_wins = 0
    if #win_ids > 1 then
        for _, id in ipairs(win_ids) do
            if not is_window_relative(id) then
                n_fixed_wins = n_fixed_wins + 1
                local buf_id = vim.api.nvim_win_get_buf(id)
                buf_modified = buf_modified or vim.bo[buf_id].modified
            end
        end
        if n_fixed_wins > 1 then
            tablabel = string.format(" [%d%s]", n_fixed_wins, buf_modified and "+" or "")
        end
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
local topline_onclick_callback = function(data)
    local tab_id = tonumber(data["fargs"][1])
    vim.api.nvim_set_current_tabpage(tab_id)
end

-- generate onclick call register if supported
local get_onclick_call = function(tab_id)
    local ret = ""
    if M.is_tabclick_supported then
        ret = string.format('%%%d@TopLineClickFunc@', tab_id)
    end
    return ret
end

-- main generate tabline
M.generate_tabline = function()
    local tabline = ""
    local tabpage_ids = vim.api.nvim_list_tabpages()
    local cur_tabpage = vim.api.nvim_get_current_tabpage()
    local label, hl_grp, onclick, sep = "", "", "", nil
    for _, tid in ipairs(tabpage_ids) do
        label = get_tablabel(tid)
        if tid == cur_tabpage then
            hl_grp = "%#TabLineSel#"
            sep = M.prep_seperators.sel
        else
            hl_grp = "%#TabLine#"
            sep = M.prep_seperators.norm
        end
        onclick = get_onclick_call(tid)
        tabline = tabline .. table.concat( {
            sep.pre,
            hl_grp,
            onclick,
            label,
            sep.post,
            "%#TabLineFill# ",
        })
    end

    -- add autofil and close button
    tabline = tabline .. "%#TabLineFill#" .. "%=%#TabLineSel#%999X[X]"
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

-- Setup highlight groups and seperators
local init_topline = function()
    -- Make selected tablabel bold
    vim.cmd("hi TabLineSel gui=bold")

    -- Create seperator highlights
    local data = vim.api.nvim_get_hl(0, { name = 'TabLine' })
    -- Use background as foreground for seperators
    local norm_fg = data.bg
    data = vim.api.nvim_get_hl(0, { name = 'TabLineSel' })
    local sel_fg = data.bg
    -- Use fill hl background
    data = vim.api.nvim_get_hl(0, { name = 'TabLineFill' })
    local bg = data.bg
    vim.api.nvim_set_hl(0, "TabLineSelInvert", { fg = sel_fg, bg = bg })
    vim.api.nvim_set_hl(0, "TabLineInvert", { fg = norm_fg, bg = bg })
    -- Prepare seperators
    M.prep_seperators = {
        norm = {
            pre = "%#TabLineInvert#" .. M.config.seperator.pre,
            post = "%#TabLineInvert#" .. M.config.seperator.post,
        },
        sel = {
            pre = "%#TabLineSelInvert#" .. M.config.seperator.pre,
            post = "%#TabLineSelInvert#" .. M.config.seperator.post,
        },
    }
end

-- setup func
M.setup = function(cfg)
    -- Exposing plugin
    _G._topline = M
    -- init config
    M.config = init_config(cfg)
    -- setup highlights
    init_topline()
    -- setup onclick calls
    setup_onclick_func()
    -- set tabline string
    vim.o.tabline = '%!v:lua._topline.generate_tabline()'
end

return M
