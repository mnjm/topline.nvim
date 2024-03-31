local M = {}

-- FIXME:
local default_config = {
    seperator = ' ',
    seperator_highlight = nil,
    enable_icons = true,
    tab_label_len = 15,
}

local init_config = function(cfg)
    cfg = cfg or {}
    M.config = vim.tbl_deep_extend("keep", cfg, default_config)
end

local safe_require = function(module_name)
    local status_ok, mod = pcall(require, module_name)
    if not status_ok then mod = nil end
    return mod
end

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

local is_window_relative = function(win_id)
    return vim.api.nvim_win_get_config(win_id).relative ~= ''
end

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
        local sign = ""
        if buf_modified then sign = "+" end
        tablabel = string.format(" [%d%s]", n_fixed_wins, sign)
    end

    -- get current buf name
    local cur_win_id = vim.api.nvim_tabpage_get_win(tab_id)
    local cur_buf_id  = vim.api.nvim_win_get_buf(cur_win_id)
    tablabel = tablabel .. get_fname_and_tag(cur_buf_id)

    -- format
    local lbl_n = tablabel:len()
    if lbl_n < M.config.tab_label_len then
        tablabel = tablabel .. string.rep(" ", M.config.tab_label_len - lbl_n)
    end
    return tablabel
end

local topline_onclick_callback = function(data)
    local tab_id = tonumber(data["fargs"][1])
    vim.api.nvim_set_current_tabpage(tab_id)
end

local setup_onclick_func = function()
    M.is_tabclick_supported = vim.fn.has('tablinat')
    if M.is_tabclick_supported then
        vim.cmd(
[[function! TopLineClickFunc(tab_id, clicks, button, mod)
execute 'ToplineOnClickCallUserCmd' a:tab_id
endfunction]]
        )
        vim.api.nvim_create_user_command('ToplineOnClickCallUserCmd', topline_onclick_callback,
            {nargs = "?", desc = 'Topline,nvim: On click callback user command'})
    end
end

local get_onclick_call = function(tab_id)
    local cur_win_id = vim.api.nvim_tabpage_get_win(tab_id)
    local cur_buf_id  = vim.api.nvim_win_get_buf(cur_win_id)
    local ret = ""
    if M.is_tabclick_supported then
        ret = string.format('%%%d@TopLineClickFunc@', tab_id)
    end
    return ret
end

M.generate_tabline = function()
    local tabline = ""
    local tabpage_ids = vim.api.nvim_list_tabpages()
    local cur_tabpage = vim.api.nvim_get_current_tabpage()
    local label, hl_grp = "", ""
    local onclick = ""
    for _, tid in ipairs(tabpage_ids) do
        label = get_tablabel(tid)
        if tid == cur_tabpage then hl_grp = "%#TabLineSel#" else hl_grp = "%#TabLine#" end
        onclick = get_onclick_call(tid)
        tabline = tabline .. table.concat( {
            hl_grp,
            onclick,
            label,
            M.__sep
        })
    end
    tabline = tabline .. "%#TabLineFill#" .. "%=%#TabLineSel#%999X[X]"
    return tabline
end

local setup_highlights = function()
    -- Make selected tablabel bold
    vim.cmd("hi TabLineSel gui=bold")

    local sep_hl = M.config.seperator_highlight
    local sep = "%#TabLine#"
    if sep_hl then
        local m = sep_hl.gui
        if m then m = "gui="..m else m = "" end
        vim.cmd(string.format("hi TabLineSep guibg=%s guifg=%s %s", sep_hl.bg, sep_hl.fg, m))
        sep = "%#TabLineSep#"
    end
    M.__sep = string.format("%s%s" , sep, M.config.seperator)
end

M.setup = function(cfg)
    _G._topline = M
    init_config(cfg)
    setup_highlights()
    setup_onclick_func()
    -- set tabline string
    vim.o.tabline = '%!v:lua._topline.generate_tabline()'
end

return M
