
# definitions needed for standalone call
PIHOME=/home/pi
RASPBIAN=$PIHOME/di_update/Raspbian_For_Robots
DEXTER=Dexter
LIB=lib
DEXTER_PATH=$PIHOME/$DEXTER
DEXTER_LIB=$DEXTER_PATH/$LIB/$DEXTER
DEXTERSCRIPT=$DEXTER_LIB/script_tools
RFRTOOLS=$DEXTER_LIB/RFR_Tools
REPO_PACKAGE=auto_detect_rpi
OS_CODENAME=$(lsb_release --codename --short)

################################################
######## Parsing Command Line Arguments ########
################################################

# called way down bellow
check_if_run_with_pi() {
  ## if not running with the pi user then exit
  if [ $(id -ur) -ne $(id -ur pi) ]; then
    echo "RFR_Tools installer script must be run with \"pi\" user. Exiting."
    exit 4
  fi
}

parse_cmdline_arguments() {
  # the following option is required should the python package be installed
  # by default, the python package are not installed
  installpythonpkg=false

  # the following 3 options are mutually exclusive
  systemwide=true
  userlocal=false
  envlocal=false
  usepython3exec=true

  # the following 2 options can be used together
  updatedebs=false
  installdebs=false

  # the following option is not a dependent
  # and if installdebs is not enabled then this one cannot be enabled
  installgui=false

  # the following option tells which branch has to be used
  selectedbranch="master" # set to master by default

  # iterate through bash arguments
  for i; do
    case "$i" in
      --install-python-package)
        installpythonpkg=true
        ;;
      --user-local)
        userlocal=true
        systemwide=false
        ;;
      --env-local)
        envlocal=true
        systemwide=false
        ;;
      --system-wide)
        ;;
      --update-aptget)
        updatedebs=true
        ;;
      --install-deb-deps)
        installdebs=true
        ;;
      --use-python3-exe-too)
        usepython3exec=true
        ;;
      --install-gui)
        installgui=true
        ;;
      develop|feature/*|hotfix/*|fix/*|DexterOS*|v*)
        selectedbranch="$i"
        ;;
    esac
  done


  pushd $PIHOME > /dev/null
  result=${PWD##*/}

  echo "Updating RFR_Tools for $selectedbranch branch with the following options:"
  echo "  --install-python-package=$installpythonpkg"
  echo "  --system-wide=$systemwide"
  echo "  --user-local=$userlocal"
  echo "  --env-local=$envlocal"
  echo "  --use-python3-exe-too=$usepython3exec"
  echo "  --update-aptget=$updatedebs"
  echo "  --install-deb-deps=$installdebs"
  echo "  --install-gui=$installgui"

  # create folders recursively if they don't exist already
  # can't use <<functions_library.sh>> here because there's no
  # cloned RFR_Tools yet at this part of the install script
  sudo mkdir -p $DEXTER_LIB
  sudo chown pi:pi -R $PIHOME/$DEXTER
  popd > /dev/null
}

################################################
###### Update and Install with Apt-Get  ########
################################################

# called way down bellow
update_install_aptget() {
  if [[ $updatedebs = "true" ]]; then
    # bring in nodejs repo
    echo "Updating debian repository within RFR_Tools "

    # to confirm nodejs is available for the given distribution
    curl -sLf -o /dev/null "https://deb.nodesource.com/node_9.x/dists/$OS_CODENAME/Release"
    ret_val=$?
    if [[ $ret_val -eq 0 ]]; then
      # add gpg key for nodejs
      curl -s https://deb.nodesource.com/gpgkey/nodesource.gpg.key | sudo apt-key add -
      # add nodejs to apt-get source list
      sudo sh -c "echo 'deb http://deb.nodesource.com/node_9.x $OS_CODENAME main' > /etc/apt/sources.list.d/nodesource.list"
      sudo sh -c "echo 'deb-src http://deb.nodesource.com/node_9.x $OS_CODENAME main' >> /etc/apt/sources.list.d/nodesource.list"
      echo "RFR_Tools: Added NodeJS repo to source for apt-get for \"$OS_CODENAME\" distribution"
    else
      echo "RFR_Tools: Couldn't add Nodejs repo to source because it's not available for \"$OS_CODENAME\" distribution"
    fi

    sudo apt-get update
  fi
  [[ $installdebs = "true" ]] && \
    echo "Installing debian dependencies within RFR_Tools. This might take a while.." && \
    sudo apt-get install -y --no-install-recommends git \
                         build-essential \
                         libi2c-dev \
                         i2c-tools \
                         python-dev \
                         python3-dev \
                         python-setuptools \
                         python3-setuptools \
                         python-pip \
                         python3-pip \
                         libffi-dev
}

install_pythons() {
  # needed on Bullseye
  if [[ $OS_CODENAME != "bookworm" ]]; then
  command -v python2 >/dev/null 2>&1 || { feedback "installing python2"; sudo apt install python2 -y; }
  else
     echo Bypassing python2 for Bookworm.
  fi
  # needed on Stretch
  command -v python3 >/dev/null 2>&1 || { feedback "installing python3" ;sudo apt install python3 -y; }

  # exit if python2/python3 are not installed in the current environment
  if [[ $installpythonpkg = "true" ]]; then
    if [[ $OS_CODENAME != "bookworm" ]]; then
      command -v python2 >/dev/null 2>&1 || { echo "Executable \"python\" couldn't be found. Aborting." >&2; exit 2; }
    fi
    if [[ $usepython3exec = "true" ]]; then
      command -v python3 >/dev/null 2>&1 || { echo "Executable \"python3\" couldn't be found. Aborting." >&2; exit 3; }
    fi
  fi
}

install_git(){
  # install git
  command -v git >/dev/null 2>&1 || { echo "installing git"; sudo apt install git -y; echo "done with git install";}
}

################################################
########### Cloning RFR_Tools  #################
################################################

# called way down below
clone_rfr_tools(){
  # it's simpler and more reliable (for now) to just delete the repo and clone a new one
  # otherwise, we'd have to deal with all the intricacies of git
  feedback "Cloning RFR Tools"
  sudo rm -rf $RFRTOOLS
  pushd $DEXTER_LIB > /dev/null
  git clone --quiet --depth=1 -b $selectedbranch https://github.com/DexterInd/RFR_Tools.git
  cd $RFRTOOLS
  # useful in case we need it
  current_branch=$(git branch | grep \* | cut -d ' ' -f2-)
  popd > /dev/null
  feedback "Done Cloning RFR Tools"
}

install_script_tools() {
  # update script_tools first
  curl --silent -kL https://raw.githubusercontent.com/DexterInd/script_tools/$selectedbranch/install_script_tools.sh > $PIHOME/.tmp_script_tools.sh
  echo "Installing script_tools."
  bash $PIHOME/.tmp_script_tools.sh $selectedbranch > /dev/null
  ret_val=$?
  rm $PIHOME/.tmp_script_tools.sh
  if [[ $ret_val -ne 0 ]]; then
    echo "script_tools failed installing with exit code $ret_val. Exiting."
    exit 5
  fi
  # needs to be sourced from here when we call this as a standalone
  source $DEXTERSCRIPT/functions_library.sh
  feedback "Done installing script_tools"
}
################################################
######## Install/Remove Python Packages ########
################################################

# called by <<install_python_pkgs_and_dependencies>>
install_python_packages() {
  [[ $systemwide = "true" ]] && sudo python2 setup.py install \
              && [[ $usepython3exec = "true" ]] && sudo python3 setup.py install
  [[ $userlocal = "true" ]] && python2 setup.py install --user \
              && [[ $usepython3exec = "true" ]] && python3 setup.py install --user
  [[ $envlocal = "true" ]] && python2 setup.py install \
              && [[ $usepython3exec = "true" ]] && python3 setup.py install
}

# called by <<install_python_pkgs_and_dependencies>>
remove_python_packages() {
  # the 1st and only argument
  # takes the name of the package that needs to removed
  rm -f $PIHOME/.pypaths

  # get absolute path to python package
  # saves output to file because we want to have the syntax highlight working
  # does this for both root and the current user because packages can be either system-wide or local
  # later on the strings used with the python command can be put in just one string that gets used repeatedly
  if [[ $OS_CODENAME != "bookworm" ]]; then
  python2 -c "import pkgutil; import os; \
              eggs_loader = pkgutil.find_loader('$1'); found = eggs_loader is not None; \
              output = os.path.dirname(os.path.realpath(eggs_loader.get_filename('$1'))) if found else ''; print(output);" >> $PIHOME/.pypaths
  sudo python2 -c "import pkgutil; import os; \
              eggs_loader = pkgutil.find_loader('$1'); found = eggs_loader is not None; \
              output = os.path.dirname(os.path.realpath(eggs_loader.get_filename('$1'))) if found else ''; print(output);" >> $PIHOME/.pypaths
  fi
  if [[ $usepython3exec = "true" ]]; then
    python3 -c "import pkgutil; import os; \
                eggs_loader = pkgutil.find_loader('$1'); found = eggs_loader is not None; \
                output = os.path.dirname(os.path.realpath(eggs_loader.get_filename('$1'))) if found else ''; print(output);" >> $PIHOME/.pypaths
    sudo python3 -c "import pkgutil; import os; \
                eggs_loader = pkgutil.find_loader('$1'); found = eggs_loader is not None; \
                output = os.path.dirname(os.path.realpath(eggs_loader.get_filename('$1'))) if found else ''; print(output);" >> $PIHOME/.pypaths
  fi

  # removing eggs for $1 python package
  # ideally, easy-install.pth needs to be adjusted too
  # but pip seems to know how to handle missing packages, which is okay
  while read path;
  do
    if [ ! -z "${path}" -a "${path}" != " " ]; then
      echo "Removing ${path} egg"
      sudo rm -f "${path}"
    fi
  done < $PIHOME/.pypaths
}

# called way down bellow
install_remove_python_packages() {
  if [[ $installpythonpkg = "true" ]]; then
    echo "Removing \"$REPO_PACKAGE\" to make space for the new one"
    remove_python_packages "$REPO_PACKAGE"

    echo "Installing python package for RFR_Tools "
    # installing the package itself
    pushd $RFRTOOLS/miscellaneous > /dev/null
    install_python_packages
    popd > /dev/null
  fi
}

install_guis() {
    if [[ $installgui = "true" ]]; then
      pushd $RFRTOOLS/advanced_communication_options >/dev/null
      bash install.sh
      cd ../Scratch_GUI
      bash install.sh
      cd ../Troubleshooting_GUI
      bash install.sh
      popd > /dev/null
    fi
}
################################################
############ Calling All Functions  ############
################################################

install_git
check_if_run_with_pi
parse_cmdline_arguments "$@"
install_script_tools
install_pythons
update_install_aptget
clone_rfr_tools
install_remove_python_packages
install_guis
feedback "Done installing RFR_Tools library"
exit 0
