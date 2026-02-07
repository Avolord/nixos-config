{ config, pkgs, ... }:

{
  home.username = "avolord";
  home.homeDirectory = "/home/avolord";
  home.stateVersion = "25.11";
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    # CLI tools
    eza        # modern ls replacement (used in aliases below)
    bat        # modern cat with syntax highlighting
    fd         # modern find
    ripgrep    # modern grep
    fzf        # fuzzy finder (integrates with zsh)
    btop       # system monitor
    fastfetch  # system info (replaces neofetch)
    zoxide     # smarter cd
  ];

  # ── Zsh ────────────────────────────────────────────────────────────
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    history = {
      size = 50000;
      save = 50000;
      ignoreDups = true;
      ignoreAllDups = true;
      ignoreSpace = true;    # commands starting with space aren't recorded
      extended = true;        # save timestamps
      share = true;           # share history across sessions
    };

    shellAliases = {
      # NixOS
      update  = "sudo nixos-rebuild switch --flake /etc/nixos#nixos";
      cleanup = "sudo nix-collect-garbage -d";

      # Modern replacements
      ls  = "eza --icons --group-directories-first";
      ll  = "eza -l --icons --group-directories-first --git";
      la  = "eza -la --icons --group-directories-first --git";
      lt  = "eza --tree --icons --level=2";
      cat = "bat --paging=never";

      # Git shortcuts (supplement oh-my-zsh git plugin)
      glog = "git log --oneline --graph --decorate -20";

      # Safety
      rm = "rm -i";
      cp = "cp -i";
      mv = "mv -i";

      # Misc
      ".." = "cd ..";
      "..." = "cd ../..";
    };

    oh-my-zsh = {
      enable = true;
      # agnoster and powerlevel10k are popular; agnoster works out of the box
      # with Nerd Fonts. For p10k you'd use a separate home-manager module.
      theme = "agnoster";
      plugins = [
        "git"
        "dirhistory"
        "history"
        "sudo"           # press Esc twice to prepend sudo
        "copypath"       # copy current directory path
        "copyfile"       # copy file contents to clipboard
        "web-search"     # `google foo` opens browser
        "extract"        # `extract archive.tar.gz` — universal extractor
        "colored-man-pages"
      ];
    };

    # Extra zsh configuration that goes into .zshrc
    initContent = ''
      # ── Zoxide (smarter cd) ──
      eval "$(zoxide init zsh)"

      # ── FZF integration ──
      eval "$(fzf --zsh)"
      export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"

      # ── Kitty shell integration ──
      # Ensures proper terminfo when SSHing from kitty
      if [[ "$TERM" == "xterm-kitty" ]]; then
        alias ssh="kitty +kitten ssh"
      fi

      # ── Keybindings ──
      bindkey '^[[A' history-search-backward   # Up arrow: search history
      bindkey '^[[B' history-search-forward    # Down arrow: search history
    '';
  };

  # ── Kitty ──────────────────────────────────────────────────────────
  programs.kitty = {
    enable = true;

    font = {
      name = "FiraCode Nerd Font";
      size = 12;
    };

    settings = {
      confirm_os_window_close = 0;
      enable_audio_bell       = false;
      scrollback_lines        = 10000;
      copy_on_select          = "clipboard";
      strip_trailing_spaces   = "smart";
      shell_integration       = "enabled";
      cursor_shape            = "beam";
      cursor_blink_interval   = "0.5";
      window_padding_width    = 4;
      hide_window_decorations = "yes";
      sync_to_monitor         = true;
      tab_bar_style           = "powerline";
      tab_powerline_style     = "slanted";
      shell                   = "${pkgs.zsh}/bin/zsh";

      # Your existing settings
      allow_remote_control = "yes";
      listen_on            = "unix:/tmp/kitty";
    };

    # Raw lines appended to the generated kitty.conf
    extraConfig = ''
      include themes/Matugen.conf
    '';

    # Remove themeFile — Matugen handles theming
    # themeFile = "Catppuccin-Mocha";

    keybindings = {
      "ctrl+shift+t"     = "new_tab_with_cwd";
      "ctrl+shift+enter" = "new_window_with_cwd";
      "ctrl+shift+l"     = "next_layout";
    };
  };

  # ── FZF (home-manager module for deeper shell integration) ─────────
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  # ── Environment variables ──────────────────────────────────────────
  home.sessionVariables = {
    EDITOR = "code --wait";
    VISUAL = "code --wait";
    PAGER  = "bat --paging=always";
  };
}
