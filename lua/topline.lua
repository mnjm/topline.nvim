local M = {}

-- FIXME:
local default_config = {
    seperator = ' ',
    -- seperator_highlight = nil,
    seperator_highlight = {fg = "#ffffff", bg="#262626", gui=nil},
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

local get_tablabel = function(win_id)
    local buf = vim.api.nvim_win_get_buf(win_id)
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
    -- format
    local lbl_n = label:len()
    if lbl_n < M.config.tab_label_len then
        label = label .. string.rep(" ", M.config.tab_label_len - lbl_n)
    end
    return label
end

local get_tabline = function()
    local tabline = ""
    local win_ids = vim.api.nvim_list_wins()
    local cur_win_id = vim.api.nvim_get_current_win()
    local label, hl_grp = "", ""
    local onclick = ""
    for i, id in ipairs(win_ids) do
        -- Skip relative windows
        if vim.api.nvim_win_get_config(id).relative == "" then
            label = get_tablabel(id)
            if id == cur_win_id then hl_grp = "%#TabLineSel#" else hl_grp = "%#TabLine#" end
            onclick = "%"..i.."T"
            tabline = tabline .. table.concat( {
                hl_grp,
                -- onclick,
                label,
                M.__sep
            })
            -- tabline = string.format("%s | %s", tabline, get_tablabel(id))
        end
    end
    tabline = tabline .. "%#TabLineFill#"
    return tabline
end

local setup_highlights = function()
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
    init_config(cfg)
    setup_highlights()
    vim.g.__tabline_fun = get_tabline
    vim.o.tabline = "%!v:lua.vim.g.__tabline_fun()"
end

-- FIXME: Remove test codes
M.setup()
return M
