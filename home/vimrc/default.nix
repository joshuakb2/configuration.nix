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
  xdg.configFile."nvim/coc-settings.json".source = ./coc-settings.json;
  xdg.configFile."nvim/init.vim".source = ./init.vim;

  home.activation.vimrc = lib.hm.dag.entryAfter [ "reloadSystemd" ] (
    cloneOrUpdate ".vim" "git@github.com:joshuakb2/MyVimRC.git"
  );
}
