{ username, lib, ... }:

{
  home.file.".gitconfig".text = let
    userSection = if username == "joshua" then ''
      [user]
        name = Joshua Baker
        email = joshuakb2@gmail.com
    '' else if username == "jbaker" then ''
      [user]
        name = Josh Baker
        email = jbaker@enseo.com
    '' else
      abort "Unexpected username ${username}";

    common = ''
      [apply]
        whitespace = fix
      [pull]
        ff = only
      [advice]
        diverging = false
      [merge]
        conflictStyle = diff3
    '';

  in lib.mkMerge [ userSection common ];
}
