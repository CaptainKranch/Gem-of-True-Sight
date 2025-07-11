{ config, pkgs, ... }:
{
  imports = [
    #./themes/theme-rose-pine.nix
    ./themes/theme-github.nix
    ./themes/theme-oxocarbon.nix
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
        nmap <M-k> :bnext<CR>
        nmap <M-j> :bprev<CR>
        nmap <M-q> :bdel<CR>

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

        -- Theme toggle command
        local themes = {
          dark = "github_dark_default",
          light = "github_light_default"
        }
        local current_theme = "dark"

        function ToggleTheme()
          if current_theme == "dark" then
            current_theme = "light"
          else
            current_theme = "dark"
          end
          vim.cmd("colorscheme " .. themes[current_theme])
        end

        vim.api.nvim_create_user_command('ToggleTheme', ToggleTheme, {})
        vim.keymap.set('n', '<leader>tt', ':ToggleTheme<CR>', { noremap = true, silent = true })
      '';
  };

  xdg.configFile."nvim/init.lua".onChange = ''
    XDG_RUNTIME_DIR=''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}
    for server in $XDG_RUNTIME_DIR/nvim.*; do
      nvim --server $server --remote-send ':source $MYVIMRC<CR>' &
    done
  '';

  xdg.desktopEntries = {
    nvim = {
      name = "Neovim";
      genericName = "Text Editor";
      comment = "Edit text files";
      exec = "nvim %F";
      icon = "nvim";
      mimeType = [
        "text/english"
        "text/plain"
        "text/x-makefile"
        "text/x-c++hdr"
        "text/x-c++src"
        "text/x-chdr"
        "text/x-csrc"
        "text/x-java"
        "text/x-moc"
        "text/x-python"
        "text/x-tcl"
        "text/x-tex"
        "application/x-shellscript"
        "text/x-c"
        "text/x-c++"
      ];
      terminal = true;
      type = "Application";
      categories = [ "Utility" "TextEditor" ];
    };
  };
}

