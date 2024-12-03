{
  pkgs,
  lib,
  backupFileExtension,
  username,
  ...
}:

let
  cloneOrUpdate = import ./cloneOrUpdate.nix { inherit pkgs backupFileExtension; };

in
{
  xdg.configFile."git/config".text =
    let
      userSection =
        if username == "joshua" then
          ''
            [user]
              name = Joshua Baker
              email = joshuakb2@gmail.com
          ''
        else if username == "jbaker" then
          ''
            [user]
              name = Josh Baker
              email = jbaker@enseo.com
          ''
        else
          abort "Unexpected username ${username}";

      common = ''
        [advice]
          diverging = false
        [alias]
          ff = merge --ff-only
          redmine-issues-between = "!f(){ git log $1..$2 | grep -Po '(?<=refs #)\\d+' | sort | uniq | awk '{print \"http://redmine.eng.enseo.com/issues/\" $0}'; }; f"
        [apply]
          whitespace = fix
        [diff]
          wserrorhighlight = all
        [init]
          defaultBranch = main
          templatedir = /home/${username}/.git-templates
        [merge]
          conflictStyle = diff3
          tool = nvimdiff
        [mergetool "nvimdiff"]
          trustExitCode = false
        [pull]
          ff = only
      '';

    in
    lib.mkMerge [
      userSection
      common
    ];

  xdg.configFile."git/ignore".text = ''
    *.code-workspace
    .vscode
    .tabs
    .spaces
    .project_root
  '';

  home.activation.git-templates-repo = lib.hm.dag.entryAfter [ "reloadSystemd" ] (
    cloneOrUpdate ".git-templates-repo" "git@github.com:joshuakb2/my-git-templates.git"
  );
  home.activation.git-templates-setup = lib.hm.dag.entryAfter [ "git-templates-repo" ] ''
    PATH="${pkgs.git}/bin:${pkgs.openssh}/bin:$PATH"

    (
      cd .git-templates-repo
      ./install-nixos.sh
    )
  '';
}
