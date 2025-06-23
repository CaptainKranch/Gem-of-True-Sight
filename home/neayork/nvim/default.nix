{ config, pkgs, ... }:
{
  imports = [
    #./themes/theme-rose-pine.nix
    #./themes/theme-kanagawa.nix
    #./themes/theme-github.nix
    #./themes/theme-oxocarbon.nix
    ./plugins/default.nix
  ];
  home.sessionVariables.EDITOR = "nvim";
    programs.neovim = {
      enable = true;
      vimAlias = true;
      viAlias = true;
      withPython3 = true;
      withNodeJs = true;
      defaultEditor = true;

      extraConfig = /* vim */ ''
        "Use system clipboard
        set clipboard=unnamedplus

        "Set fold level to highest in file
        "so everything starts out unfolded at just the right level
        augroup initial_fold
          autocmd!
          autocmd BufWinEnter * let &foldlevel = max(map(range(1, line('$')), 'foldlevel(v:val)'))
        augroup END

        "Tabs
        set tabstop=4 "4 char-wide tab
        set expandtab "Use spaces
        set softtabstop=0 "Use same length as 'tabstop'
        set shiftwidth=0 "Use same length as 'tabstop'
        
        "Fix nvim size according to terminal
        "(https://github.com/neovim/neovim/issues/11330)
        augroup fix_size
          autocmd VimEnter * silent exec "!kill -s SIGWINCH" getpid()
        augroup END

        "Line numbers
        set number relativenumber

        " Keep visual selection after indenting/unindenting
        " vnoremap: visual mode, non-recursive mapping
        " >gv: Perform the default indent (>), then reselect last visual area (gv)
        " <gv: Perform the default unindent (<), then reselect last visual area (gv)
        vnoremap > >gv
        vnoremap < <gv

        "Buffers
        if has('macunix')
            " --- macOS ---
            " Use Command key (<D->).
            " NOTE: These work best in GUI Vim (like MacVim).
            " In TERMINAL Vim on macOS, <D-key> shortcuts are often
            " intercepted by the terminal itself (e.g., Terminal.app, iTerm2)
            " or the OS before reaching Vim. You might need specific
            " terminal configuration to pass them through, which can be tricky.
            echom "Platform: macOS. Mapping Buffers to <D-k/j/q>"
            nnoremap <silent> <D-k> :bnext<CR>
            nnoremap <silent> <D-j> :bprev<CR>
            nnoremap <silent> <D-q> :bdelete<CR> " Use bdelete or bd

        else
            " --- Linux, Windows, other Unix ---
            " Use Meta key (<M->, usually Alt or Option).
            " NOTE: Ensure your terminal emulator is configured to send Meta/Alt
            " keys correctly if you are using Vim in a terminal.
            " (e.g., 'Use Option as Meta key' in Terminal.app, 'Esc+' in iTerm2)
            echom "Platform: Non-macOS. Mapping Buffers to <M-k/j/q>"
            nnoremap <silent> <M-k> :bnext<CR>
            nnoremap <silent> <M-j> :bprev<CR>
            nnoremap <silent> <M-q> :bdelete<CR> " Use bdelete or bd
        endif

        "Loclist
        nmap <space>l :lwindow<cr>
        nmap [l :lprev<cr>
        nmap ]l :lnext<cr>

        nmap <space>L :lhistory<cr>
        nmap [L :lolder<cr>
        nmap ]L :lnewer<cr>

        "Quickfix
        nmap <space>q :cwindow<cr>
        nmap [q :cprev<cr>
        nmap ]q :cnext<cr>

        nmap <space>Q :chistory<cr>
        nmap [Q :colder<cr>
        nmap ]Q :cnewer<cr>

        "Make
        nmap <space>m :make<cr>

        "Close other splits
        nmap <space>o :only<cr>

        "Sudo save
        cmap w!! w !sudo tee > /dev/null %
      '';

      extraLuaConfig = /* lua */ ''
        vim.g.mapleader = " "
        vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

        vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
        vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

        --Jump between windows in current buffer
        vim.api.nvim_set_keymap('n', '<C-h>', '<C-w>h', { noremap = true, silent = true })
        vim.api.nvim_set_keymap('n', '<C-l>', '<C-w>l', { noremap = true, silent = true })

        -- greatest remap ever
        vim.keymap.set("x", "<leader>p", [["_dP]])

        -- next greatest remap ever : asbjornHaland
        vim.keymap.set({"n", "v"}, "<leader>y", [["+y]])
        vim.keymap.set("n", "<leader>Y", [["+Y]])
      '';
  };

  xdg.configFile."nvim/init.lua".onChange = ''
    XDG_RUNTIME_DIR=''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}
    for server in $XDG_RUNTIME_DIR/nvim.*; do
      nvim --server $server --remote-send ':source $MYVIMRC<CR>' &
    done
  '';
}

