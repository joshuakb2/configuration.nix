{ pkgs, backupFileExtension }:
dir: remote: ''
  PATH="${pkgs.git}/bin:${pkgs.openssh}/bin:$PATH"

  if [[ -d ${dir} ]]; then
    if [[ -d ${dir}/.git ]]; then
      run cd ${dir}
      echo 'Updating ${dir}'
      run git pull || echo 'Could not pull latest version of ${dir}'
    else
      echo 'Moving existing ${dir} out of the way'
      run mv ${dir} ${dir}.${backupFileExtension}
      echo 'Cloning ${dir}'
      run git clone ${remote} ${dir} || echo 'Could not clone ${dir}'
    fi
  else
    echo 'Cloning ${dir}'
    run git clone ${remote} ${dir} || echo 'Could not clone ${dir}'
  fi
''
