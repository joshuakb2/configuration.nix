{
  pkgs,
  lib,
  backupFileExtension,
  ...
}:

let
  cloneOrUpdate = import ../cloneOrUpdate.nix { inherit pkgs backupFileExtension; };

in
{
  xdg.configFile."nvim-old/coc-settings.json".source = ./coc-settings.json;
  xdg.configFile."nvim-old/init.vim".source = ./init.vim;

  home.activation.vimrc = lib.hm.dag.entryAfter [ "reloadSystemd" ] (
    cloneOrUpdate ".vim" "git@github.com:joshuakb2/MyVimRC.git"
  );

  programs.neovim = {
    enable = true;
    coc.enable = true;
    coc.settings = builtins.fromJSON (builtins.readFile ./coc-settings.json);
    plugins = with pkgs.vimPlugins; [
      coc-svelte
      nvim-java
      nvim-lspconfig
      nvim-treesitter
      nvim-treesitter-context
      plenary-nvim
      project-nvim
      rainbow
      telescope-nvim
      typescript-vim
      vim-commentary
      vim-fugitive
      vim-indentwise
      vim-javascript
      vim-lion
      vim-svelte
    ];
  };
}
