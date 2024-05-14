local set = vim.opt

-- Start constants
local NODE_MODULES = "~/.nvm/versions/node/v20.13.1/lib/node_modules/"
-- End constants

-- 4 Spaces for tabs
set.autoindent = true
set.expandtab = true
set.tabstop = 4
set.shiftwidth = 4

-- Set folding based on syntax
set.foldmethod = 'syntax'
set.foldnestmax = 10
set.foldenable = false
set.foldlevel = 2

-- Set , as <Leader>
vim.g.mapleader = ','

-- Set float colors to stand out
vim.api.nvim_set_hl(0, "FloatBorder", {bg="#3B4252", fg="#5E81AC"})
vim.api.nvim_set_hl(0, "NormalFloat", {bg="#3B4252"})

-- Install plugins
local Plug = vim.fn['plug#']

vim.call('plug#begin')

-- nvim-cmp for language completion
Plug('neovim/nvim-lspconfig')
Plug('hrsh7th/cmp-nvim-lsp')
Plug('hrsh7th/cmp-buffer')
Plug('hrsh7th/cmp-path')
-- Plug('hrsh7th/cmp-cmdline')
Plug('hrsh7th/nvim-cmp')
Plug('L3MON4D3/LuaSnip')
Plug('rafamadriz/friendly-snippets')

-- NERDTree
Plug('scrooloose/nerdtree', { on='NERDTreeToggle'})
-- Airline
Plug('nvim-lualine/lualine.nvim')

vim.call('plug#end')

-- Start nvim-cmp setup
local cmp = require('cmp')
local luasnip = require('luasnip')

local select_opts = {behavior = cmp.SelectBehavior.Select}

cmp.setup({
    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body)
        end
    },
    sources = {
        {name = 'path'},
        {name = 'nvim_lsp', keyword_length = 1},
        {name = 'buffer', keyword_length = 3},
        {name = 'luasnip', keyword_length = 2},
    },
    window = {
        documentation = cmp.config.window.bordered(),
    },
    formatting = {
        fields = {'menu', 'abbr', 'kind'},
        format = function(entry, item)
            local menu_icon = {
                nvim_lsp = 'λ',
                luasnip = '⋗',
                buffer = 'Ω',
                path = 'P',
            }

            item.menu = menu_icon[entry.source.name]
            return item
        end,
    },
    mapping = {
        ['<Up>'] = cmp.mapping.select_prev_item(select_opts),
        ['<Down>'] = cmp.mapping.select_next_item(select_opts),

        ['<C-p>'] = cmp.mapping.select_prev_item(select_opts),
        ['<C-n>'] = cmp.mapping.select_next_item(select_opts),

        ['<C-u>'] = cmp.mapping.scroll_docs(-4),
        ['<C-d>'] = cmp.mapping.scroll_docs(4),

        ['<C-e>'] = cmp.mapping.abort(),
        ['<C-y>'] = cmp.mapping.confirm({select = true}),
        ['<CR>'] = cmp.mapping.confirm({select = false}),

        ['<C-f>'] = cmp.mapping(function(fallback)
            if luasnip.jumpable(1) then
                luasnip.jump(1)
            else
                fallback()
            end
        end, {'i', 's'}),

        ['<C-b>'] = cmp.mapping(function(fallback)
            if luasnip.jumpable(-1) then
                luasnip.jump(-1)
            else
                fallback()
            end
        end, {'i', 's'}),

        ['<Tab>'] = cmp.mapping(function(fallback)
            local col = vim.fn.col('.') - 1

            if cmp.visible() then
                cmp.select_next_item(select_opts)
            elseif col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') then
                fallback()
            else
                cmp.complete()
            end
        end, {'i', 's'}),

        ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item(select_opts)
            else
                fallback()
            end
        end, {'i', 's'}),
    },
})
-- End nvim-cmp setup

-- Start lscponfig setup
local capabilities = require('cmp_nvim_lsp').default_capabilities()
local lspconfig = require('lspconfig')

lspconfig.lua_ls.setup({
  capabilities = capabilities,
})
lspconfig.volar.setup({
  capabilities = capabilities,
  filetypes = { "vue" },
})
lspconfig.tsserver.setup({
  capabilities = capabilities,
  init_options = {
    plugins = {
      {
        name = "@vue/typescript-plugin",
        location = NODE_MODULES .. "@vue/typescript-plugin",
        languages = {"javascript", "typescript", "vue"},
      },
    },
    tsserver = {
      -- This overwrite the path from the local project, in case your project ts version is not compatible with the plugin
      path = NODE_MODULES .. "typescript/lib",
    },
  },
  filetypes = {
    "javascript",
    "typescript",
    "vue",
  },
})
-- End lspconfig setup

-- Start LSP keybindings
vim.api.nvim_create_autocmd('LspAttach', {
  desc = 'LSP actions',
  callback = function()
    local bufmap = function(mode, lhs, rhs)
      local opts = {buffer = true}
      vim.keymap.set(mode, lhs, rhs, opts)
    end

    -- Displays hover information about the symbol under the cursor
    bufmap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>')

    -- Jump to the definition
    bufmap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>')

    -- Jump to declaration
    bufmap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>')

    -- Lists all the implementations for the symbol under the cursor
    bufmap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>')

    -- Jumps to the definition of the type symbol
    bufmap('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>')

    -- Lists all the references 
    bufmap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>')

    -- Displays a function's signature information
    bufmap('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>')

    -- Renames all references to the symbol under the cursor
    bufmap('n', '<Leader>rn', '<cmd>lua vim.lsp.buf.rename()<cr>')

    -- Selects a code action available at the current cursor position
    bufmap('n', '<Leader>qf', '<cmd>lua vim.lsp.buf.code_action()<cr>')

    -- Show diagnostics in a floating window
    bufmap('n', 'gl', '<cmd>lua vim.diagnostic.open_float()<cr>')

    -- Move to the previous diagnostic
    bufmap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<cr>')

    -- Move to the next diagnostic
    bufmap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<cr>')
  end
})
-- End LSP keybindings

-- Start LuaSnip and friendly-snippets setup
require('luasnip.loaders.from_vscode').lazy_load()
-- End LuaSnip and friendly-snippets setup

-- Start NERDTree setup
vim.keymap.set('n', '<Leader>n', ':NERDTreeFind<CR>')
vim.keymap.set('n', '<C-t>', ':NERDTreeToggle<CR>')
-- End NERDTree setup

-- Start lualine setup
require('lualine').setup {
  options = {
    icons_enabled = false,
    theme = 'auto',
    component_separators = { left = '', right = ''},
    section_separators = { left = '', right = ''},
    disabled_filetypes = {
      statusline = {},
      winbar = {},
    },
    ignore_focus = {},
    always_divide_middle = true,
    globalstatus = false,
    refresh = {
      statusline = 1000,
      tabline = 1000,
      winbar = 1000,
    }
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch', 'diff', 'diagnostics'},
    lualine_c = {'filename'},
    lualine_x = {'encoding', 'fileformat', 'filetype'},
    lualine_y = {'progress'},
    lualine_z = {'location'}
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {'filename'},
    lualine_x = {'location'},
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {},
  winbar = {},
  inactive_winbar = {},
  extensions = {}
}
-- End lualine setup

-- OLD CONTENT BELOW
-- " Linting
-- " Plug 'w0rp/ale'
-- " " Auto completion
-- " Plug 'Shougo/deoplete.nvim'
-- " Floating Preview
-- Plug 'ncm2/float-preview.nvim'
-- " Apex/Salesforce
-- " Plug 'neowit/vim-force.com'
-- " File viewer
-- Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
-- " Clojure REPL
-- Plug 'Olical/conjure'
-- " Fennel
-- Plug 'bakpakin/fennel.vim'
-- " Fennel in Conjure
-- Plug 'Olical/aniseed', { 'tag': 'v3.15.0' }
-- " Find files
-- Plug 'Shougo/denite.nvim', { 'do': ':UpdateRemotePlugins' }
-- " Code completion
-- Plug 'neoclide/coc.nvim', {'branch': 'release'}
-- " Git diff
-- Plug 'sindrets/diffview.nvim'
-- 
-- " Local salesforce plugin
-- "Plug '~/Developer/vim/salesforce'
-- " Local ant plugin
-- "Plug '~/Developer/vim/ant'
-- " Local sfdx plugin
-- Plug '~/Developer/vim/sfdx-nvim'
-- " Local coc-apex plugin
-- Plug '~/Developer/vim/coc-apex'
-- " Local sf plugin
-- Plug '~/Developer/vim/sf-nvim'
-- 
-- " Initialize plugin system.
-- call plug#end()
-- " " Place configuration AFTER `call plug#end()`
-- " let g:deoplete#enable_at_startup = 1
-- " " Use float preview instead of preview window
-- " set completeopt-=preview
-- " let g:float_preview#docked = 1
-- " let g:float_preview#max_width = 80
-- " let g:float_preview#max_height = 40
-- let maplocalleader = ','
-- let mapleader = ','
-- 
-- " Have tab insert spaces instead of a tab character
-- set expandtab
-- " Set tab to 4 spaces
-- set tabstop=4
-- set shiftwidth=4
-- 
-- " Set folding based on syntax
-- set foldmethod=syntax
-- set foldnestmax=10
-- set nofoldenable " Start with folds disabled
-- set foldlevel=2
-- 
-- " Display terminal
-- " open new split below
-- set splitbelow
-- " turn terminal to normal mode with escape
-- tnoremap <Esc> <C-\><C-n>
-- " start terminal in insert mode
-- au BufEnter * if &buftype == 'terminal' | :startinsert | endif
-- " open terminal on ctrl+n
-- function! OpenTerminal()
--   split term://zsh
--   resize 10
-- endfunction
-- nnoremap <c-n> :call OpenTerminal()<CR>
-- 
-- " === Conjure setup ===
-- let g:conjure#client#fennel#aniseed#aniseed_module_prefix = "aniseed."
-- let g:aniseed#env = v:true
-- " === End Conjure setup ===
-- 
-- " === Denite setup ==="
-- " Use ripgrep for searching current directory for files
-- " By default, ripgrep will respect rules in .gitignore
-- "   --files: Print each file that would be searched (but don't search)
-- "   --glob:  Include or exclues files for searching that match the given glob
-- "            (aka ignore .git files)
-- "
-- call denite#custom#var('file/rec', 'command', ['rg', '--files', '--glob', '!.git'])
-- 
-- " Use ripgrep in place of "grep"
-- call denite#custom#var('grep', 'command', ['rg'])
-- 
-- " Custom options for ripgrep
-- "   --vimgrep:  Show results with every match on it's own line
-- "   --hidden:   Search hidden directories and files
-- "   --heading:  Show the file name above clusters of matches from each file
-- "   --S:        Search case insensitively if the pattern is all lowercase
-- call denite#custom#var('grep', 'default_opts', ['--hidden', '--vimgrep', '--heading', '-S'])
-- 
-- " Recommended defaults for ripgrep via Denite docs
-- call denite#custom#var('grep', 'recursive_opts', [])
-- call denite#custom#var('grep', 'pattern_opt', ['--regexp'])
-- call denite#custom#var('grep', 'separator', ['--'])
-- call denite#custom#var('grep', 'final_opts', [])
-- 
-- " Remove date from buffer list
-- call denite#custom#var('buffer', 'date_format', '')
-- 
-- " Custom options for Denite
-- "   auto_resize             - Auto resize the Denite window height automatically.
-- "   prompt                  - Customize denite prompt
-- "   direction               - Specify Denite window direction as directly below current pane
-- "   winminheight            - Specify min height for Denite window
-- "   highlight_mode_insert   - Specify h1-CursorLine in insert mode
-- "   prompt_highlight        - Specify color of prompt
-- "   highlight_matched_char  - Matched characters highlight
-- "   highlight_matched_range - matched range highlight
-- let s:denite_options = {'default' : {
-- \ 'split': 'floating',
-- \ 'start_filter': 1,
-- \ 'auto_resize': 1,
-- \ 'prompt': 'λ ',
-- \ 'highlight_matched_char': 'QuickFixLine',
-- \ 'highlight_matched_range': 'Visual',
-- \ 'highlight_window_background': 'Visual',
-- \ 'highlight_filter_background': 'DiffAdd',
-- \ 'winrow': 1,
-- \ 'vertical_preview': 1
-- \ }}
-- 
-- " Loop through denite options and enable them
-- function! s:profile(opts) abort
--   for l:fname in keys(a:opts)
--     for l:dopt in keys(a:opts[l:fname])
--       call denite#custom#option(l:fname, l:dopt, a:opts[l:fname][l:dopt])
--     endfor
--   endfor
-- endfunction
-- 
-- call s:profile(s:denite_options)
-- "=== End Denite Setup ==="
-- 
-- "=== Start NERDTree ==="
-- nnoremap <silent> <C-t> :NERDTreeToggle<CR>
-- nnoremap <leader>n :NERDTreeFind<CR>
-- "=== End NERDTree ==="
-- 
-- " Clear highlights
-- nnoremap <silent> <C-l> :nohl<CR><C-l>
-- 
-- " nnoremap <C-k> :ALEHover<CR>
-- inoremap ¬ <C-k>*l
-- 
-- " === Denite shorcuts === "
-- "   ;         - Browser currently open buffers
-- "   <leader>t - Browse list of files in current directory
-- "   <leader>g - Search current directory for occurences of given term and close window if no results
-- "   <leader>j - Search current directory for occurences of word under cursor
-- nmap ; :Denite buffer<CR>
-- nmap <leader>t :DeniteProjectDir file/rec<CR>
-- nnoremap <leader>g :<C-u>Denite grep:. -no-empty<CR>
-- nnoremap <leader>j :<C-u>DeniteCursorWord grep:.<CR>
-- 
-- " Define mappings while in 'filter' mode
-- "   <C-o>         - Switch to normal mode inside of search results
-- "   <Esc>         - Exit denite window in any mode
-- "   <CR>          - Open currently selected file in any mode
-- "   <C-t>         - Open currently selected file in a new tab
-- "   <C-v>         - Open currently selected file a vertical split
-- "   <C-h>         - Open currently selected file in a horizontal split
-- autocmd FileType denite-filter call s:denite_filter_my_settings()
-- function! s:denite_filter_my_settings() abort
--   imap <silent><buffer> <C-o>
--   \ <Plug>(denite_filter_update)
--   inoremap <silent><buffer><expr> <Esc>
--   \ denite#do_map('quit')
--   nnoremap <silent><buffer><expr> <Esc>
--   \ denite#do_map('quit')
--   inoremap <silent><buffer><expr> <CR>
--   \ denite#do_map('do_action')
--   inoremap <silent><buffer><expr> <C-t>
--   \ denite#do_map('do_action', 'tabopen')
--   inoremap <silent><buffer><expr> <C-v>
--   \ denite#do_map('do_action', 'vsplit')
--   inoremap <silent><buffer><expr> <C-h>
--   \ denite#do_map('do_action', 'split')
-- endfunction
-- 
-- " Define mappings while in denite window
-- "   <CR>        - Opens currently selected file
-- "   q or <Esc>  - Quit Denite window
-- "   d           - Delete currenly selected file
-- "   p           - Preview currently selected file
-- "   <C-o> or i  - Switch to insert mode inside of filter prompt
-- "   <C-t>       - Open currently selected file in a new tab
-- "   <C-v>       - Open currently selected file a vertical split
-- "   <C-h>       - Open currently selected file in a horizontal split
-- autocmd FileType denite call s:denite_my_settings()
-- function! s:denite_my_settings() abort
--   nnoremap <silent><buffer><expr> <CR>
--   \ denite#do_map('do_action')
--   nnoremap <silent><buffer><expr> q
--   \ denite#do_map('quit')
--   nnoremap <silent><buffer><expr> <Esc>
--   \ denite#do_map('quit')
--   nnoremap <silent><buffer><expr> d
--   \ denite#do_map('do_action', 'delete')
--   nnoremap <silent><buffer><expr> p
--   \ denite#do_map('do_action', 'preview')
--   nnoremap <silent><buffer><expr> i
--   \ denite#do_map('open_filter_buffer')
--   nnoremap <silent><buffer><expr> <C-o>
--   \ denite#do_map('open_filter_buffer')
--   nnoremap <silent><buffer><expr> <C-t>
--   \ denite#do_map('do_action', 'tabopen')
--   nnoremap <silent><buffer><expr> <C-v>
--   \ denite#do_map('do_action', 'vsplit')
--   nnoremap <silent><buffer><expr> <C-h>
--   \ denite#do_map('do_action', 'split')
-- endfunction
-- 
-- "=== Start SFDX setup ===
-- nnoremap <leader>h :TestMethods<CR>
-- "=== End SFDX setup ===
-- 
-- 
-- "=== Start COC setup ===
-- let g:coc_global_extensions = ['coc-tsserver', 'coc-json', 'coc-vimlsp', 'coc-xml']
-- let $NVIM_COC_LOG_LEVEL='all'
-- 
-- highlight CocFloating ctermbg=15 ctermfg=1
-- highlight NormalFloat ctermbg=15 ctermfg=1
-- "highlight CocErrorFloat ctermfg=15
-- 
-- " Use tab for trigger completion with characters ahead and navigate.
-- " NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
-- " other plugin before putting this into your config.
-- inoremap <silent><expr> <TAB>
--       \ coc#pum#visible() ? coc#pum#next(1) :
--       \ CheckBackspace() ? "\<Tab>" :
--       \ coc#refresh()
-- 
-- inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"
-- 
-- " Make <CR> to accept selected completion item or notify coc.nvim to format
-- " <C-g>u breaks current undo, please make your own choice
-- inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
--                               \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
-- 
-- function! CheckBackspace() abort
--   let col = col('.') - 1
--   return !col || getline('.')[col - 1]  =~# '\s'
-- endfunction
-- 
-- " Use <c-space> to trigger completion.
-- inoremap <silent><expr> <c-space> coc#refresh()
-- 
-- " Make <CR> auto-select the first completion item and notify coc.nvim to
-- " format on enter, <cr> could be remapped by other vim plugin
-- inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
--                               \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
-- 
-- " Use `[g` and `]g` to navigate diagnostics
-- " Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
-- nmap <silent> [g <Plug>(coc-diagnostic-prev)
-- nmap <silent> ]g <Plug>(coc-diagnostic-next)
-- 
-- " GoTo code navigation.
-- nmap <silent> gd <Plug>(coc-definition)
-- nmap <silent> gy <Plug>(coc-type-definition)
-- nmap <silent> gi <Plug>(coc-implementation)
-- nmap <silent> gr <Plug>(coc-references)
-- 
-- " Use K to show documentation in preview window.
-- nnoremap <silent> K :call <SID>show_documentation()<CR>
-- 
-- function! s:show_documentation()
--   if (index(['vim','help'], &filetype) >= 0)
--     execute 'h '.expand('<cword>')
--   elseif (coc#rpc#ready())
--     call CocActionAsync('doHover')
--   else
--     execute '!' . &keywordprg . " " . expand('<cword>')
--   endif
-- endfunction
-- 
-- " Highlight the symbol and its references when holding the cursor.
-- "autocmd CursorHold * silent call CocActionAsync('highlight')
-- 
-- " Symbol renaming.
-- nmap <leader>rn <Plug>(coc-rename)
-- 
-- " Formatting selected code.
-- xmap <leader>f  <Plug>(coc-format-selected)
-- nmap <leader>f  <Plug>(coc-format-selected)
-- 
-- augroup mygroup
--   autocmd!
--   " Setup formatexpr specified filetype(s).
--   autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
--   " Update signature help on jump placeholder.
--   autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
-- augroup end
-- 
-- " Applying codeAction to the selected region.
-- " Example: `<leader>aap` for current paragraph
-- xmap <leader>a  <Plug>(coc-codeaction-selected)
-- nmap <leader>a  <Plug>(coc-codeaction-selected)
-- 
-- " Remap keys for applying codeAction to the current buffer.
-- nmap <leader>ac  <Plug>(coc-codeaction)
-- " Apply AutoFix to problem on the current line.
-- nmap <leader>qf  <Plug>(coc-fix-current)
-- 
-- " Map function and class text objects
-- " NOTE: Requires 'textDocument.documentSymbol' support from the language server.
-- xmap if <Plug>(coc-funcobj-i)
-- omap if <Plug>(coc-funcobj-i)
-- xmap af <Plug>(coc-funcobj-a)
-- omap af <Plug>(coc-funcobj-a)
-- xmap ic <Plug>(coc-classobj-i)
-- omap ic <Plug>(coc-classobj-i)
-- xmap ac <Plug>(coc-classobj-a)
-- omap ac <Plug>(coc-classobj-a)
-- 
-- " Remap <C-f> and <C-b> for scroll float windows/popups.
-- "if has('nvim-0.4.0') || has('patch-8.2.0750')
-- "  nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
-- "  nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
-- "  inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
-- "  inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
-- "  vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
-- "  vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
-- "endif
-- 
-- " Use CTRL-S for selections ranges.
-- " Requires 'textDocument/selectionRange' support of language server.
-- nmap <silent> <C-s> <Plug>(coc-range-select)
-- xmap <silent> <C-s> <Plug>(coc-range-select)
-- 
-- " Add `:Format` command to format current buffer.
-- command! -nargs=0 Format :call CocAction('format')
-- 
-- " Add `:Fold` command to fold current buffer.
-- command! -nargs=? Fold :call     CocAction('fold', <f-args>)
-- 
-- " Add `:OR` command for organize imports of the current buffer.
-- command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')
-- 
-- " Add (Neo)Vim's native statusline support.
-- " NOTE: Please see `:h coc-status` for integrations with external plugins that
-- " provide custom statusline: lightline.vim, vim-airline.
-- set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}
-- 
-- " Mappings for CoCList
-- " Show all diagnostics.
-- nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>
-- " Manage extensions.
-- nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>
-- " Show commands.
-- nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>
-- " Find symbol of current document.
-- nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
-- " Search workspace symbols.
-- nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>
-- " Do default action for next item.
-- nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
-- " Do default action for previous item.
-- nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
-- " Resume latest coc list.
-- nnoremap <silent><nowait> <space>p  :<C-u>CocListResume<CR>
-- "=== End COC ===
