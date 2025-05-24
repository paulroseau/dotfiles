-- Credits to https://github.com/alvarosevilla95/luatab.nvim

local devicons = require('nvim-web-devicons')

local highlight = require('luatab.highlight')

local M = {}

M.title = function(bufnr)
    local file = vim.fn.bufname(bufnr)
    local buftype = vim.fn.getbufvar(bufnr, '&buftype')
    local filetype = vim.fn.getbufvar(bufnr, '&filetype')

    if buftype == 'help' then
        return 'help:' .. vim.fn.fnamemodify(file, ':t:r')
    elseif buftype == 'quickfix' then
        return 'Quickfix'
    elseif filetype == 'git' then
        return 'Git'
    elseif filetype == 'fugitive' then
        return 'Fugitive'
    elseif filetype == 'neo-tree' then
        return 'NeoTree'
    elseif filetype == 'checkhealth' then
        return 'Health'
    elseif file:sub(file:len()-2, file:len()) == 'FZF' then
        return 'FZF'
    elseif buftype == 'terminal' then
        local _, mtch = string.match(file, "term:(.*):(%a+)")
        return mtch ~= nil and mtch or vim.fn.fnamemodify(vim.env.SHELL, ':t')
    elseif file == '' then
        return '[No Name]'
    else
        return vim.fn.pathshorten(vim.fn.fnamemodify(file, ':p:~:t'))
    end
end

M.modified = function(bufnr)
    return vim.fn.getbufvar(bufnr, '&modified') == 1 and '[+] ' or ''
end

M.windowCount = function(index)
    local nwins = vim.fn.tabpagewinnr(index, '$')
    return nwins > 1 and '(' .. nwins .. ') ' or ''
end

M.devicon = function(bufnr, is_selected)
    local icon, icon_highlight_name
    local file = vim.fn.fnamemodify(vim.fn.bufname(bufnr), ':t')
    local buftype = vim.fn.getbufvar(bufnr, '&buftype')
    local filetype = vim.fn.getbufvar(bufnr, '&filetype')
    if filetype == 'fugitive' then
        icon, icon_highlight_name = devicons.get_icon('git')
    elseif filetype == 'vimwiki' then
        icon, icon_highlight_name = devicons.get_icon('markdown')
    elseif filetype == 'checkhealth' then
        icon, icon_highlight_name = devicons.get_icon('checkhealth')
    elseif buftype == 'terminal' then
        icon, icon_highlight_name = devicons.get_icon('zsh')
    else
        icon, icon_highlight_name = devicons.get_icon(file, vim.fn.expand('#'..bufnr..':e'))
    end
    if icon then
        local fg = highlight.extract_colors(icon_highlight_name, 'fg')
        local bg = highlight.extract_colors('TabLineSel', 'bg')
        local hl = highlight.create_component_highlight_group({bg = bg, fg = fg}, icon_highlight_name)
        local selected_hl_start = (is_selected and hl) and '%#' .. hl .. '#' or ''
        local selected_hl_end = is_selected and '%#TabLineSel#' or ''
        return selected_hl_start .. icon .. selected_hl_end .. ' '
    end
    return ''
end

M.separator = function(index)
    return (index < vim.fn.tabpagenr('$') and '%#TabLine#|' or '')
end

M.cell = function(index)
    local is_selected = vim.fn.tabpagenr() == index
    local buflist = vim.fn.tabpagebuflist(index)
    local winnr = vim.fn.tabpagewinnr(index)
    local bufnr = buflist[winnr]
    local hl = (is_selected and '%#TabLineSel#' or '%#TabLine#')

    return hl .. '%' .. index .. 'T' .. ' ' ..
        M.windowCount(index) ..
        M.title(bufnr) .. ' ' ..
        M.modified(bufnr) ..
        M.devicon(bufnr, is_selected) .. '%T' ..
        M.separator(index)
end

M.tabline = function()
    local line = ''
    for i = 1, vim.fn.tabpagenr('$'), 1 do
        line = line .. M.cell(i)
    end
    line = line .. '%#TabLineFill#%='
    if vim.fn.tabpagenr('$') > 1 then
        line = line .. '%#TabLine#%999XX'
    end
    return line
end

local setup = function(opts)
    opts = opts or {}
    if opts.title then M.title = opts.title end
    if opts.modified then M.modified = opts.modified end
    if opts.windowCount then M.windowCount = opts.windowCount end
    if opts.devicon then M.devicon = opts.devicon end
    if opts.separator then M.separator = opts.separator end
    if opts.cell then M.cell = opts.cell end
    if opts.tabline then M.tabline = opts.tabline end

    vim.opt.tabline = '%!v:lua.require(\'luatab\').helpers.tabline()'
end

return {
    helpers = M,
    setup = setup,
}
