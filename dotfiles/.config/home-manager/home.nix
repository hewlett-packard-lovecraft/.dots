{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "hxia";
  home.homeDirectory = "/home/hxia";

  # tell home-manager we aren't using NixOS
  # targets.genericLinux.enable = true;

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
    pkgs.noto-fonts
    pkgs.noto-fonts-cjk-sans
    pkgs.noto-fonts-cjk-serif
    pkgs.noto-fonts-color-emoji
    pkgs.nerd-fonts.iosevka

    pkgs.git
    pkgs.gh
    pkgs.emacs-pgtk
    pkgs.neovim
    pkgs.nixfmt
    pkgs.fzf
    pkgs.tmux
    pkgs.tmuxp
    pkgs.texlab

    pkgs.zsh
    pkgs.zsh-fzf-tab
    pkgs.zsh-nix-shell
    pkgs.zsh-vi-mode
    pkgs.zsh-you-should-use

    pkgs.cargo
    pkgs.rustc
    pkgs.rustfmt
    pkgs.emacs-lsp-booster
    pkgs.clang-tools
    pkgs.bear
    pkgs.unzip

    pkgs.pandoc
    pkgs.deno
    pkgs.typescript

    # lsp
    pkgs.basedpyright
    pkgs.typescript-language-server
    # pkgs.vscode-css-languageserver
    # pkgs.vscode-json-languageserver
    pkgs.yaml-language-server
    pkgs.docker-language-server
    pkgs.bash-language-server
    pkgs.cmake-language-server
    pkgs.nixd
    pkgs.vscode-langservers-extracted

    # formatter
    pkgs.ruff
    pkgs.prettier
    pkgs.prettierd

    # emacs vterm dependencies
    pkgs.cmake
    pkgs.gnumake
    pkgs.ninja
    pkgs.libtool

  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/hxia/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    EDITOR = "vim";
    GDK_BACKEND = "wayland";
    # GDK_SCALE="2";
    # QT_SCALE_FACTOR = "2";
    WINEWAYLAND_ALLOW_HIDPI = "1";
  };

  home.extraOutputsToInstall = [ "dev" ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  programs.gh = {
    enable = true;
    gitCredentialHelper.enable = true;
    settings = {
      git_protocol = "ssh";
      prompt = "enabled";
      color_labels = "enabled";
      spineer = "enabled";
    };
  };
  programs.git = {
    enable = true;
    settings.user = {
      name = "Hao Ming Xia";
      email = "hx2314@nyu.edu";
    };
  };
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    tmux = {
      enableShellIntegration = true;
    };
  };
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true; # see note on other shells below
    nix-direnv.enable = true;
  };
  programs.zsh = {
    enable = true;
    enableVteIntegration = true;
    loginExtra = ''
      if [ -z "$WAYLAND_DISPLAY" ] && [ -n "$XDG_VTNR" ] && [ "$XDG_VTNR" -eq 1 ] && [ `command -v <cmd>` ] ; then
          exec sway
      fi
    '';
    envExtra = ''
      if grep -q -i 'Microsoft' /proc/version; then
         # export GDK_DPI_SCALE=2.0
         # fix the huge cursor size
         export XCURSOR_SIZE=12
      fi
    '';
    initContent = ''
        source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh

      vterm_printf() {
          if [ -n "$TMUX" ] \
              && { [ "''${TERM%%-*}" = "tmux" ] \
                  || [ "''${TERM%%-*}" = "screen" ]; }; then
              # Tell tmux to pass the escape sequences through
              printf "\ePtmux;\e\e]%s\007\e\\" "$1"
          elif [ "''${TERM%%-*}" = "screen" ]; then
              # GNU screen (screen, screen-256color, screen-256color-bce)
              printf "\eP\e]%s\007\e\\" "$1"
          else
              printf "\e]%s\e\\" "$1"
          fi
      }
    '';
    localVariables = {
      CASE_SENSITIVE = true;
      HYPHEN_INSENSITIVE = true;
      ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE = 20;
      ZSH_AUTOSUGGEST_USE_ASYNC = 1;
      VI_MODE_SET_CURSOR = true;
      #VI_MODE_RESET_PROMPT_ON_MODE_CHANGE=true
      # export DISABLE_FZF_AUTO_COMPLETION="false";
      DISABLE_FZF_AUTO_COMPLETION = "false";
    };
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    enableCompletion = true;
    history.size = 10000;
    plugins = [
      {
        name = pkgs.zsh-nix-shell.pname;
        src = pkgs.zsh-nix-shell.src;
      }
      {
        name = pkgs.zsh-you-should-use.pname;
        src = pkgs.zsh-you-should-use.src;
      }
      {
        name = "zsh-vi-mode";
        src = "${pkgs.zsh-vi-mode}/share/zsh-vi-mode";
      }
      {
        name = "fzf-tab";
        src = "${pkgs.zsh-fzf-tab}/share/fzf-tab";
      }
    ];
    oh-my-zsh = {
      enable = true;
      extraConfig = ''
        zstyle ':omz:update' mode reminder  # just remind me to update when it's time
        zstyle ':omz:update' frequency 7
        zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup
      '';
      plugins = [
        "direnv"
        "vi-mode"
        "git" # also requires `programs.git.enable = true;`
        "github"
        "nvm"
        "fzf"
        "ssh-agent"
      ];
      theme = "dieter";
    };
    shellAliases = {
      ll = "ls -l";
      la = "ls -la";
      hupdate = "home-manager switch";
      nupdate = "home-manager switch";
      # e= "emacs";
      # te = "emacs -nw";
      e = "emacsclient -c";
      te = "emacsclient -t";
    };
  };

  programs.tmux = {
    enable = true;
    tmuxp.enable = true;
    clock24 = true;
    keyMode = "vi";
    prefix = "C-a";
    mouse = true;
    baseIndex = 1;
    extraConfig = ''
      # Start windows and panes at 1, not 0
      set -g base-index 1
      setw -g pane-base-index 1

      # change prefix
      # unbind -n C-b
      set -g prefix2 C-a
      bind -n C-a send-prefix

      # mouse
      setw -g mouse on
      setw -g alternate-screen on

      # Enable passthrough of OSC 52 escape sequences
      set -g allow-passthrough on
      # Enable OSC 52 clipboard integration
      set -g set-clipboard on

      set -ga terminal-overrides ',xterm*:XT:Ms=\E]52;%p1%s;%p2%s\007'
      set -ga terminal-overrides ',screen*:XT:Ms=\E]52;%p1%s;%p2%s\007'
    '';
  };
  programs.vim = {
    enable = true;
    settings = {
      background = "dark";
      expandtab = true;
      hidden = true;
      tabstop = 4;
    };
    extraConfig = ''
            set nu rnu	" Show line numbers
            set linebreak	" Break lines at word (requires Wrap lines)
            set showbreak=++ 	" Wrap-broken line prefix
            let textwidth=100	" Line wrap (number of cols)
            set showmatch	" Highlight matching brace

            set hlsearch	" Highlight all search results
            set smartcase	" Enable smart-case search
            set ignorecase	" Always case-insensitive
            set incsearch	" Searches for strings incrementally

            set textwidth=120       " break lines when line length increases
            set softtabstop=4
            set shiftwidth=4        " number of spaces to use for auto indent
            set autoindent          " copy indent from current line when starting a new line

            set confirm	" Prompts for confirmation
            set ruler	" Show row and column ruler information
            set autowriteall	" Auto-write all file changes
            set undolevels=1000	" Number of undo levels
            set backspace=indent,eol,start	" Backspace behaviour
            set clipboard=unnamed,unnamedplus " Use system keyboard
            syntax on               " syntax highlighting
            set showcmd             " show (partial) command in status line

            set cmdheight=2
            set updatetime=300
            set shortmess+=c
            set signcolumn=yes
            let mapleader = " "
            let maplocalleader = ","

            set fileformat = "unix"
            set fileformats = "unix,dos"

      " WSL paste fix
      autocmd BufReadPost * call s:lastpos()
      function! WslCleanup()
      silent! exe "'[,']s/\r$//g"
      endfunction
      nnoremap p p:call WslCleanup()
      nnoremap P P:call WslCleanup()
    '';
  };

  programs.texlive = {
    enable = true;
    extraPackages = tpkgs: {
      inherit (tpkgs)
        scheme-tetex
        plex
        moderncv
        ;
    };
  };

  fonts.fontconfig = {
    enable = true;
    defaultFonts.monospace = [ "Iosevka Nerd Font 12" ];
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      monospace-font-name = "Iosevka Nerd Font 12";
      cursor-size = 12;
    };
  };

  services.emacs = {
    enable = true;
    package = pkgs.emacs-pgtk; # replace with emacs-gtk, or a version provided by the community overlay if desired.
  };
}
