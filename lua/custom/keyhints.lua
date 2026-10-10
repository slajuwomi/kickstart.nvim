-- Context-aware keymap hints in a floating box in the top-right corner.
--
-- The box refreshes as the cursor moves and shows the keys that are useful for
-- whatever is under the cursor: LSP symbols, diagnostics, strings, JSX/HTML
-- tags, function-call arguments, brackets, numbers, comments. It also changes
-- with the mode (normal / visual / insert). If the cursor goes under the box,
-- the box moves to the bottom-right corner.
--
-- Toggle: <leader>tk  or  :KeyHints

local M = {}

local ns = vim.api.nvim_create_namespace 'keyhints'
local state = { enabled = false, buf = nil, win = nil, timer = nil, rendered = nil }

local QUOTES = { ['"'] = true, ["'"] = true, ['`'] = true }
local BRACKETS = { ['('] = '(', [')'] = '(', ['['] = '[', [']'] = '[', ['{'] = '{', ['}'] = '{' }

-- Walk up the treesitter tree from the cursor and record which kinds of
-- syntax we're inside. Node names differ per language, so match loosely.
local function syntax_context(bufnr)
  local ctx = {}
  local ok, node = pcall(vim.treesitter.get_node, { bufnr = bufnr, ignore_injections = false })
  if not ok then
    return ctx
  end
  local depth = 0
  while node and depth < 8 do
    local t = node:type()
    if not ctx.quote and t:find 'string' then
      local first = vim.treesitter.get_node_text(node, bufnr):sub(1, 1)
      if QUOTES[first] then
        ctx.quote = first
      end
    elseif t:find 'comment' then
      ctx.comment = true
    elseif t == 'number' or t:find 'integer' or t:find 'float' or t == 'number_literal' then
      ctx.number = true
    elseif t:find '^jsx_' or t == 'element' or t == 'tag_name' or t == 'start_tag' then
      ctx.tag = true
    elseif t:find 'argument' then
      ctx.argument = true
    end
    node = node:parent()
    depth = depth + 1
  end
  return ctx
end

local function normal_sections(bufnr)
  local sections = {}
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local line = vim.api.nvim_get_current_line()
  local char = line:sub(col + 1, col + 1)
  local word = vim.fn.expand '<cword>'

  if #vim.diagnostic.get(bufnr, { lnum = row - 1 }) > 0 then
    table.insert(sections, {
      title = 'Diagnostic',
      items = {
        { '<C-w>d', 'Show full message' },
        { 'gra', 'Quick fix / code action' },
        { ']d [d', 'Next / prev diagnostic' },
        { '<leader>sd', 'All diagnostics' },
      },
    })
  end

  local ctx = syntax_context(bufnr)

  if
    not ctx.quote
    and not ctx.comment
    and word:match '^[%a_$][%w_$]*$'
    and #vim.lsp.get_clients { bufnr = bufnr, method = 'textDocument/definition' } > 0
  then
    table.insert(sections, {
      title = 'Symbol: ' .. word,
      items = {
        { 'grd', 'Go to definition' },
        { '<C-t>', 'Jump back from definition' },
        { 'grr', 'Find references' },
        { 'K', 'Hover docs / type' },
        { 'grn', 'Rename everywhere' },
        { 'gra', 'Code action' },
        { 'grt', 'Go to type definition' },
      },
    })
  end

  if ctx.quote then
    local q = ctx.quote
    local other = q == '"' and "'" or '"'
    table.insert(sections, {
      title = 'String',
      items = {
        { 'ci' .. q, 'Change text inside quotes' },
        { 'yi' .. q, 'Copy text inside quotes' },
        { 'da' .. q, 'Delete string with quotes' },
        { 'sr' .. q .. other, 'Swap ' .. q .. ' for ' .. other },
        { 'sd' .. q, 'Remove the quotes' },
      },
    })
  end

  if ctx.tag then
    table.insert(sections, {
      title = 'Tag',
      items = {
        { 'cit', 'Change tag contents' },
        { 'dat', 'Delete whole element' },
        { 'vat', 'Select element (again: parent)' },
        { 'sdt', 'Unwrap: remove surrounding tag' },
      },
    })
  end

  if ctx.argument then
    table.insert(sections, {
      title = 'Arguments',
      items = {
        { 'cia', 'Change this argument' },
        { 'daa', 'Delete argument + comma' },
        { 'cif', 'Change all call arguments' },
        { 'vaf', 'Select whole call' },
      },
    })
  end

  if BRACKETS[char] then
    local open = BRACKETS[char]
    table.insert(sections, {
      title = 'Bracket ' .. char,
      items = {
        { '%', 'Jump to matching bracket' },
        { 'ci' .. open, 'Change inside brackets' },
        { 'va' .. open, 'Select incl. brackets' },
        { 'sd' .. open, 'Remove the brackets' },
      },
    })
  end

  if ctx.number or char:match '%d' then
    table.insert(sections, {
      title = 'Number',
      items = {
        { '<C-a> <C-x>', 'Increment / decrement' },
        { '10<C-a>', 'Add 10' },
      },
    })
  end

  if ctx.comment then
    local items = {
      { 'gcc', 'Toggle comment on line' },
      { 'gcip', 'Toggle comment on paragraph' },
    }
    if line:find 'TODO' or line:find 'FIXME' or line:find 'HACK' or line:find 'NOTE' then
      table.insert(items, { ':TodoTelescope', 'Find all TODOs' })
    end
    table.insert(sections, { title = 'Comment', items = items })
  end

  table.insert(sections, {
    title = 'Anywhere',
    items = {
      { '<leader>sf', 'Find file' },
      { '<leader>sg', 'Grep project' },
      { '<leader><leader>', 'Open buffers' },
      { '<leader>/', 'Search this file' },
      { '<C-o> <C-i>', 'Jump back / forward' },
      { '<leader>f', 'Format file' },
      { '<leader>sk', 'Search all keymaps' },
    },
  })
  return sections
end

local VISUAL_SECTIONS = {
  {
    title = 'Visual',
    items = {
      { 'sa"', 'Surround with " (or ( [ { t)' },
      { 'gc', 'Toggle comment' },
      { '> <', 'Indent / outdent' },
      { 'J', 'Join lines' },
      { '~', 'Toggle case' },
      { 'o', 'Jump to other end' },
      { 'ip ap', 'Expand to paragraph' },
      { 'y d c', 'Copy / delete / change' },
    },
  },
}

local INSERT_SECTIONS = {
  {
    title = 'Insert',
    items = {
      { '<C-w>', 'Delete word before' },
      { '<C-u>', 'Delete to line start' },
      { '<C-o>', 'Run one normal cmd' },
      { '<C-r>"', 'Paste last yank' },
      { '<C-t> <C-d>', 'Indent / outdent line' },
    },
  },
  {
    title = 'Completion',
    items = {
      { '<C-space>', 'Open menu / docs' },
      { '<C-n> <C-p>', 'Next / prev item' },
      { '<C-y>', 'Accept' },
      { '<C-e>', 'Close menu' },
      { '<Tab>', 'Next snippet field' },
    },
  },
}

-- Turn sections into buffer lines plus highlight ranges.
local function layout(sections)
  local keyw = 0
  for _, s in ipairs(sections) do
    for _, it in ipairs(s.items) do
      keyw = math.max(keyw, vim.fn.strdisplaywidth(it[1]))
    end
  end

  local lines, hls = {}, {}
  for i, s in ipairs(sections) do
    if i > 1 then
      table.insert(lines, '')
    end
    local title = ' ' .. s.title
    table.insert(lines, title)
    table.insert(hls, { #lines - 1, 1, #title, 'KeyHintsTitle' })
    for _, it in ipairs(s.items) do
      local key, desc = it[1], it[2]
      local text = ' ' .. key .. string.rep(' ', keyw - vim.fn.strdisplaywidth(key)) .. '  ' .. desc .. ' '
      table.insert(lines, text)
      table.insert(hls, { #lines - 1, 1, 1 + #key, 'KeyHintsKey' })
      table.insert(hls, { #lines - 1, #text - #desc - 1, #text - 1, 'KeyHintsDesc' })
    end
  end
  return lines, hls
end

function M.hide()
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    vim.api.nvim_win_close(state.win, true)
  end
  state.win = nil
  state.rendered = nil
end

local function update()
  if not state.enabled then
    return M.hide()
  end

  local cur = vim.api.nvim_get_current_win()
  local bufnr = vim.api.nvim_get_current_buf()
  -- Hide in floats (Telescope, hover), special buffers (neo-tree, help, terminal) and narrow screens.
  if vim.api.nvim_win_get_config(cur).relative ~= '' or vim.bo[bufnr].buftype ~= '' or vim.o.columns < 80 then
    return M.hide()
  end

  local mode = vim.api.nvim_get_mode().mode:sub(1, 1)
  local sections
  if mode == 'n' then
    sections = normal_sections(bufnr)
  elseif mode == 'v' or mode == 'V' or mode == '\22' then
    sections = VISUAL_SECTIONS
  elseif mode == 'i' then
    sections = INSERT_SECTIONS
  else
    return M.hide()
  end

  local lines, hls = layout(sections)
  -- Keep the box under half the screen height so one corner is always clear of
  -- the cursor: drop the trailing "Anywhere" section first when it's too tall.
  local max_height = math.floor((vim.o.lines - vim.o.cmdheight - 2) / 2) - 2
  if #lines > max_height and #sections > 1 and sections[#sections].title == 'Anywhere' then
    lines, hls = layout(vim.list_slice(sections, 1, #sections - 1))
  end
  local width = 0
  for _, l in ipairs(lines) do
    width = math.max(width, vim.fn.strdisplaywidth(l))
  end
  local height = math.min(#lines, max_height)

  -- Bottom-right if the cursor sits under the top-right box.
  local pos = vim.fn.screenpos(cur, vim.fn.line '.', vim.fn.col '.')
  local under_box = pos.row > 0 and pos.row <= height + 2 and pos.col >= vim.o.columns - width - 2
  local win_config = {
    relative = 'editor',
    anchor = under_box and 'SE' or 'NE',
    row = under_box and (vim.o.lines - vim.o.cmdheight - 1) or 0,
    col = vim.o.columns,
    width = width,
    height = height,
    style = 'minimal',
    border = 'rounded',
    title = ' keys ',
    title_pos = 'center',
    focusable = false,
    zindex = 45,
  }

  if not (state.buf and vim.api.nvim_buf_is_valid(state.buf)) then
    state.buf = vim.api.nvim_create_buf(false, true)
    vim.bo[state.buf].bufhidden = 'hide'
  end

  local key = table.concat(lines, '\n')
  if key ~= state.rendered then
    vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, lines)
    vim.api.nvim_buf_clear_namespace(state.buf, ns, 0, -1)
    for _, h in ipairs(hls) do
      vim.api.nvim_buf_set_extmark(state.buf, ns, h[1], h[2], { end_col = h[3], hl_group = h[4] })
    end
    state.rendered = key
  end

  if state.win and vim.api.nvim_win_is_valid(state.win) then
    vim.api.nvim_win_set_config(state.win, win_config)
  else
    win_config.noautocmd = true
    state.win = vim.api.nvim_open_win(state.buf, false, win_config)
    vim.wo[state.win].winhighlight = 'Normal:NormalFloat,FloatBorder:FloatBorder'
  end
end

local function schedule_update()
  state.timer:stop()
  state.timer:start(60, 0, vim.schedule_wrap(update))
end

function M.toggle()
  state.enabled = not state.enabled
  update()
end

function M.setup()
  vim.api.nvim_set_hl(0, 'KeyHintsTitle', { link = 'Title', default = true })
  vim.api.nvim_set_hl(0, 'KeyHintsKey', { link = 'Special', default = true })
  vim.api.nvim_set_hl(0, 'KeyHintsDesc', { link = 'NormalFloat', default = true })

  state.timer = vim.uv.new_timer()
  vim.api.nvim_create_autocmd({
    'CursorMoved',
    'CursorMovedI',
    'ModeChanged',
    'BufEnter',
    'WinEnter',
    'LspAttach',
    'LspDetach',
    'DiagnosticChanged',
    'VimResized',
  }, {
    group = vim.api.nvim_create_augroup('keyhints', { clear = true }),
    callback = schedule_update,
  })

  vim.keymap.set('n', '<leader>tk', M.toggle, { desc = '[T]oggle [K]ey hints box' })
  vim.api.nvim_create_user_command('KeyHints', M.toggle, { desc = 'Toggle key hints box' })
end

return M
