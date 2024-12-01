{ pkgs, lib, backupFileExtension, ... }:

{
  xdg.configFile."nvim/coc-settings.json".source = ./coc-settings.json;
  xdg.configFile."nvim/init.vim".source = ./init.vim;

  home.activation.vimrc = lib.hm.dag.entryAfter ["reloadSystemd"] ''
    PATH="${pkgs.git}/bin:${pkgs.openssh}/bin:$PATH"

    if [[ -d .vim ]]; then
      if [[ -d .vim/.git ]]; then
        run cd .vim
        echo 'Updating .vim'
        run git pull || echo 'Could not pull latest version of .vim'
      else
        echo 'Moving existing .vim out of the way'
        run mv .vim .vim.${backupFileExtension}
        echo 'Cloning .vim'
        run git clone git@github.com:joshuakb2/MyVimRC.git .vim || echo 'Could not clone .vim'
      fi
    else
      echo 'Cloning .vim'
      run git clone git@github.com:joshuakb2/MyVimRC.git .vim || echo 'Could not clone .vim'
    fi
  '';
}
