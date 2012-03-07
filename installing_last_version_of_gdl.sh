#!/bin/bash

# Copyrigth 2011 Daniel Molina García
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.


######################################
# Scope and description of the script
######################################
# This script has the intention of helping you to compile and install
# GDL and some of its dependencies on a computer running GNU/Linux
# where:
#
#  * You don't have super-user access.
#  * You have a space's quota, so no free MB for compiling all.
#
# Also, it has the aim (maybe not yet) of helping you to understand
# which is the utility of GDL dependencies, empowering you to 
# understand what you need and you don't. Personally, I found very
# difficult to have a working installation of GDL from source.
#
# The original scope of this script was to install GDL in any
# user's account of the aula Paolo Poropat at University of Trieste,
# Italy. GDL 0.9 should be installed yet on those computers, but there
# are reasons for using the development version (or the lastest
# stable one), since GDL is in a soon state and new compatibility
# features are added continuosly.
#
# If you are installing GDL on any other environment, this script
# still can be useful. However, you probably have to download other
# dependencies and make several changes on the script, but it is
# work done and it can save you time.
#
# This script is useful for those users which HASN'T SUPER-USER ACCESS
# to the OS. If you have it, you could simply install the *-dev
# versions of the dependencies and avoid to compile them.
#
# FIXME:
# If you don't have other reason for compiling GDL that the fact of
# having a working version, you
# haven't to do it. Just only run the install_gdl_0.9.1.sh script
# (but read the instructions on it before) which will copy to
# your account the software compiled using this method.


############
# Variables
############
# The name of the command for invoking GDL
# GDL_COMMAND_NAME="gdl-svn"

# Where to install GDL and the dependencies
INSTALLATION_DIR="$HOME/My_Programs"

GDL_INSTALLATION_DIR="$HOME/My_Programs/gdl"

# Where to compile GDL and the dependencies (it can create more than 1 GB
# of files, so if you have a quota of space used, you may want to use a usb
# device instead for saving the compiled programs.
COMPILATION_DIR="/media/49da33e5-356f-4819-a487-8cc7de7b895b"

# Probably the user want to have GDL in a more permanent site than dependencies
GDL_COMPILATION_DIR="$HOME/Compiling"

# Path to the directory with source tarballs.
PKGS_DIR="/media/49da33e5-356f-4819-a487-8cc7de7b895b"

# Names of the tarballs (without extension) with the source code of the
# dependencies that will be used for the installation. This script expects
# to find them packaged in the format specified below. If you have something
# different, correct the extraction command manually.
PLPLOT_PKG_NAME="plplot-5.9.9" #(.tar.gz package expected)
WXWIDGETS_PKG_NAME="wxWidgets-2.8.12" #(.tar.bz2 package expected)
MAGICK_PKG_NAME="ImageMagick-6.7.3-5" #(.tar.gz package expected) 
PSLIB_PKG_NAME="pslib-0.4.5" #(.tar.gz package expected) 
#HDF_PKG_NAME="hdf-4.2.6-linux" #(.tar.gz package expected)
#HDF5_PKG_NAME="hdf5-1.8.7" #(.tar.gz package expected)
NETCDF_PKG_NAME="netcdf-4.1.3" #(.tar.gz package expected)
#PYTHON_PKG_NAME="Python-2.7.2" #(.tgz expected) (!)

# PKGS_NAME is a string which contains the identificator of used dependencies
# It can be used for removing theese packages from inside a folder without risk for others
PKGS_NAME="${PLPLOT_PKG_NAME} ${WXWIDGETS_PKG_NAME} ${MAGICK_PKG_NAME} ${NETCDF_PKG_NAME}"

# Set to "YES" if you want to download and use the current development
# version of GDL. If "NO" (or other thing different to "YES") it will
# be used the GDL_PKG_NAME variable.
# USE_CVS_VERSION="NO"

# Complete path for an auxilary file that will be used for remember in which step
# of the installation you were and then start at this point, if you
# chose it.
AUXILIARY_FILE="${HOME}/installing_last_version_of_gdl.aux"

################################################### END OF VARIABLE SETTING

##########################
# The core of the script
##########################

function install_gdl-presentation {
    echo "I'll try to assist you installing the last version of GDL."
    echo "Just as at this moment, I'll often pause the execution,"
    echo "waiting for a confirmation to continue. Then, it will"
    echo "be time for cheking if something was wrong until the pause."
    echo "If necessary, exit me entering 3 and try to fix the problem."
    echo "Then, execute me again and I'll repeat again the last step."
    echo "I am supposing that you have set the variables of this script up yet!"
}

###########################################################
# Noticing about adding ${INSTALLATION_DIR} to the ${PATH}
###########################################################
function finishing_notes {
    echo "IMPORTANT:"
    echo "If not yet, probably you want to add ${INSTALLATION_DIR} to your \$PATH,"
    echo "so you can have access to the new programs that have been installed there."
    echo "You can run the following command for geting it:"
    echo -e "\t echo \"PATH=${GDL_INSTALLATION_DIR}/bin:\$PATH\" >> \${HOME}/.bashrc"
}

###############################
# wxWidgets
# Download link: http://wxwidgets.org/downloads/
# README: docs/readme.txt
# Probably you need to install libgtk2.0-dev package for configuring
###############################
function pslib-extraction {
    rm -rf ${COMPILATION_DIR}/${PSLIB_PKG_NAME}
    tar -xvzf ${PKGS_DIR}/${PSLIB_PKG_NAME}.tar.gz -C $COMPILATION_DIR
}

function pslib-configuration {
    cd ${COMPILATION_DIR}/${PSLIB_PKG_NAME}
    ./configure --prefix=$INSTALLATION_DIR
    cd -
}

function pslib-compilation {
    cd ${COMPILATION_DIR}/$PSLIB_PKG_NAME
    make
    cd -
}

function pslib-installation {
    cd ${COMPILATION_DIR}/$PSLIB_PKG_NAME
    make install
    cd -
}


function wxwidgets-extraction {
    rm -rf ${COMPILATION_DIR}/${WXWIDGETS_PKG_NAME}
    tar -xvjf ${PKGS_DIR}/${WXWIDGETS_PKG_NAME}.tar.bz2 -C $COMPILATION_DIR
}

function wxwidgets-configuration {
    cd ${COMPILATION_DIR}/$WXWIDGETS_PKG_NAME
    ./configure --prefix=$INSTALLATION_DIR
    cd -
}

function wxwidgets-compilation {
    cd ${COMPILATION_DIR}/$WXWIDGETS_PKG_NAME
    make
    cd -
}

function wxwidgets-installation {
    cd ${COMPILATION_DIR}/$WXWIDGETS_PKG_NAME
    make install
    cd -
}

################################
# PLplot
# Download link: http://sourceforge.net/project/showfiles.php?group_id=2915&package_id=2865
################################

function plplot-extraction {
    rm -rf ${COMPILATION_DIR}/${PLPLOT_PKG_NAME}
    tar -xvzf ${PKGS_DIR}/${PLPLOT_PKG_NAME}.tar.gz -C $COMPILATION_DIR
}

function plplot-configuration {
    cd ${COMPILATION_DIR}/$PLPLOT_PKG_NAME
    rm -rf build_dir
    mkdir -p build_dir
    cd -
    cd ${COMPILATION_DIR}/$PLPLOT_PKG_NAME/build_dir

    # FIXME: How to use with wxwidgets and benefits for GDL. (Recognised automatically?)

    # There is an error in INSTALL file. It's writen plplot_cmake as the
    # name of a directory needed by cmake.
    cmake -DCMAKE_INSTALL_PREFIX=${INSTALLATION_DIR} \
          -DENABLE_DYNDRIVERS=OFF \
          -DPLD_wxwidgets=${INSTALLATION_DIR} \
          .. # Theese points are not an error!
    cd -
}

function plplot-compilation {
    cd ${COMPILATION_DIR}/${PLPLOT_PKG_NAME}/build_dir
    make
    cd -
}

function plplot-installation {
    cd ${COMPILATION_DIR}/${PLPLOT_PKG_NAME}/build_dir
    make install
    cd -
}

################################
# ImageMagick
# The Image Magick version used when writing this script was 6.7.3-1
# Download link: ftp://ftp.imagemagick.org/pub/ImageMagick
################################

function magick-extraction {
    rm -rf ${COMPILATION_DIR}/${MAGICK_PKG_NAME}
    tar -xvzf ${PKGS_DIR}/${MAGICK_PKG_NAME}.tar.gz -C ${COMPILATION_DIR}
}

function magick-configuration {
    cd ${COMPILATION_DIR}/${MAGICK_PKG_NAME}
    ./configure --prefix=$INSTALLATION_DIR
    cd -
}

function magick-compilation {
    # It avoids the no version number by default of the .tar.gz
    cd ${COMPILATION_DIR}/${MAGICK_PKG_NAME}
    make
    cd -
}

function magick-checking {
    # It avoids the no version number by default of the .tar.gz
    cd ${COMPILATION_DIR}/${MAGICK_PKG_NAME}
    make check # It's not neccesary, but it's good
    cd -
}

function magick-installation {
    # It avoids the no version number by default of the .tar.gz
    cd ${COMPILATION_DIR}/${MAGICK_PKG_NAME}
    make install
    cd -
}

######################
# NetCDF
# Download link: http://www.unidata.ucar.edu/downloads/netcdf/index.jsp
# (C/C++/Fortran Stable Releases)
######################

function netcdf-extraction {
    rm -rf ${COMPILATION_DIR}/${NETCDF_PKG_NAME}
    tar -xvzf ${PKGS_DIR}/${NETCDF_PKG_NAME}.tar.gz -C $COMPILATION_DIR
}

function netcdf-configuration {
    cd ${COMPILATION_DIR}/$NETCDF_PKG_NAME
    ./configure --prefix=${HOME}/${INSTALLATION_DIR} \
                --disable-netcdf-4 \
#               --enable-hdf4
    cd -
}

function netcdf-compilation {
    cd ${COMPILATION_DIR}/${NETCDF_PKG_NAME}
    make
    cd -
}

#function netcdf-checking {
#    cd ${COMPILATION_DIR}/$NETCDF_PKG_NAME
#    make check # It would be fine if you get 13 GB of writable space
#}

function netcdf-installation {
    cd ${COMPILATION_DIR}/$NETCDF_PKG_NAME
    make install
    cd -
}

# HDF5 - which gives support for NetCDF-4 features
##################################################
# You can understand HDF issues better reading the INSTALL
# file of NetCDF.
# A tested by NetCDF HDF5 package can be downloaded from 
# ftp://ftp.unidata.ucar.edu/pub/netcdf/netcdf-4/


##############################
# GDL
# Download link:
#  * Stable release: http://sourceforge.net/projects/gnudatalanguage/
#  * Development version in a tar: http://gnudatalanguage.cvs.sourceforge.net/viewvc/gnudatalanguage/?view=tar
#  * Development version through CVS:
#    $  cvs -d:pserver:anonymous@gnudatalanguage.cvs.sourceforge.net:/cvsroot/gnudatalanguage login
#    $ cvs -z3 -d:pserver:anonymous@gnudatalanguage.cvs.sourceforge.net:/cvsroot/gnudatalanguage co -P .
##############################


function gdl-download_extraction {
    # I'm not sure if is a good idea to download the package in $PKGS_DIR
    # instead of GDL_COMPILATION_DIR
    rm -rf ${GDL_COMPILATION_DIR}/gnudatalanguage
    wget http://gnudatalanguage.cvs.sourceforge.net/viewvc/gnudatalanguage/?view=tar \
	 -O ${PKGS_DIR}/gdl-cvs.tar.gz
    tar -xvzf ${PKGS_DIR}/gdl-cvs.tar.gz -C ${GDL_COMPILATION_DIR}

#    else
#	tar -xvzf ${PKGS_DIR}/${GDL_PKG_NAME}.tar.gz -C $COMPILING_DIR
#	cd ${COMPILING_DIR}/${GDL_PKG_NAME}
#    fi
}

function gdl-configuration {
#         FIXME: Name of the gdl command 
    cd ${GDL_COMPILATION_DIR}/gnudatalanguage/gdl
    rm -rf build_dir
    mkdir -p build_dir
    cd -
    cd ${GDL_COMPILATION_DIR}/gnudatalanguage/gdl/build_dir
    cmake -DCMAKE_INSTALL_PREFIX=${GDL_INSTALLATION_DIR} \
          -DNETCDF=OFF \
	  -DPSLIB=OFF \
          -DPLPLOTDIR=${INSTALLATION_DIR} \
          -DMAGICKDIR=${INSTALLATION_DIR} \
	  -DWXWIDGETS=${INSTALLATION_DIR} \
          -DHDF=OFF \
          -DHDF5=OFF \
          -DCMAKE_BUILD_TYPE=Debug \
          -DPYTHON=OFF \
          ..
    cd -

}

function gdl-compilation {
    cd ${GDL_COMPILATION_DIR}/gnudatalanguage/gdl/build_dir
    make
    cd -
}

function gdl-installation {
    cd ${GDL_COMPILATION_DIR}/gnudatalanguage/gdl/build_dir
    make install
    cd -
}

function non_free_idl_source_routines-install {
    mkdir -p ${INSTALLATION_DIR}/share/non_free_idl_routines
    cd ${INSTALLATION_DIR}/share/non_free_idl_routines
    for i in "CONGRID" "TEK_COLOR" "HIST_EQUAL" "ROT" "PROFILES"
    do
	wget http://www.astro.washington.edu/docs/idl/cgi-bin/getpro/library07.html?${i} -O ${i}
    done
    cd -
    echo "PRINT, 'Some IDL routines from astro.washington.edu added.'" >> ${HOME}/.gdl_startup
    echo "PATH=!PATH + ':${INSTALLATION_DIR}/share/non_free_idl_routines'" >> ${HOME}/.gdl_startup
}


function present_program {
    echo "------------------------"
    echo " $1"
    echo "------------------------"
}

function present_action {
    echo -e "\n* $2 of $1 is going to start:\n"
}

# do_step <PROGRAM> <ACTION_1> [ACTION_2 ... ACTION_N]
#
# do_step basically will ask to the user individual confirmation to execute the previously
# defined functions  <PROGRAM>-<ACTION_1> && [<PROGRAM>-<ACTION_2> ...],
# but with some exceptions controled by $START_PROGRAM and $START_ACTION:
#
# do_step flux:
#   if   $START_PROGRAM == "done"     then check $START_ACTION
#   elif $START_PROGRAM == <PROGRAM>  then check $START_ACTION
#                                          START_PROGRAM="done"
#
#   else                              do nothing
#
#   if   $START_ACTION  == "done"     then ask to user for exec of <PROGRAM>-<ACTION_I>
#   elif $START_ACTION  == <ACTION_I> then ask to user for exec of <PROGRAM>-<ACTION_I>
#                                          START_ACTION="done"
#   else                                   try this condition again with <ACTION_I+1>
#
#   if at the end of the loop
#      $START_ACTION != "done"        then $START_ACTION was wrong.
#
#  There is also a "next" flag for $START_PROGRAM which let the user to skip an action.
function do_step {

    # Protecting the use of this function from an accidental wrong use
    if [[ $# < 2 ]]
    then
	echo "Error: do_step needs at least a program and one action."
	exit 1
    fi

    # CURRENT_PROGRAM is sintatic sugar for $1 (<PROGRAM>), not used as a global variable.
    CURRENT_PROGRAM=$1

    # If this is the PROGRAM to recover or we recovered one before...
    if [[ $START_PROGRAM == "done" || $CURRENT_PROGRAM == $START_PROGRAM ]]
    then
        # Flag $START_PROGRAM to indicate that any PROGRAM has been matched yet
        START_PROGRAM="done"

        present_program $CURRENT_PROGRAM

        # Remove <PROGRAM> from $@ and check every passed <ACTION_I>
        shift
	for i in "$@" 
	do

            # CURRENT_ACTION is ony sintatic sugar for $i (<ACTION_I>)
	    CURRENT_ACTION=$i

	    # If user, inside this loop, chose skip last action, reflag $START_ACTION
	    # and continue normally
            if [[ $START_ACTION == "next" ]]
            then
                 START_ACTION=$CURRENT_ACTION
            fi

            # If this is the ACTION to recover or we recovered one before...
            # Else, go to the next ACTION.
            if [[ ( $START_ACTION == "done" ) || ( $CURRENT_ACTION == $START_ACTION ) ]]
            then

                # Flag $START_ACTION to indicate that any ACTION has been matched yet
                START_ACTION="done"

		#######################
		# ASK-TO-THE-USER PART
		#######################
                # Ask the user to select an option (think that ACTION of this loop is not done yet!)
                echo "Do you want to start ${CURRENT_ACTION} of ${CURRENT_PROGRAM}?"
                select OPT in "Yes." "No, go to the next step." "No, I have to fix something and then try again." "It worked fine, but I want to exit now."
                do

	            if [[ $OPT == "Yes." ]]
	            then
			# Continue, execute ACTION and ask for the next ACTION
			break
	            elif [[ $OPT == "No, I have to fix something and then try again." ]]
	            then
			# End execution of gdl_install. Next time it will be repeated this ACTION
			exit 2
                    elif [[ $OPT == "No, go to the next step." ]]
                    then
			# Don't exec ACTION, but grab next ACTION
			# If in next ACTION, gd_install exits by previous $OPT,
			# these ACTION and not this will be recovered.
			START_ACTION="next"
			break
		    elif [[ $OPT == "It worked fine, but I want to exit now." ]]
		    then
			# End execution of gdl_install but grab the name of next action for recovery
			START_ACTION="exit"
			exit 1
		    fi
	        done

		# Save the current PROGRAM and ACTION, although skiped by "next" flag
                echo -e "${CURRENT_PROGRAM}\n${CURRENT_ACTION}" > $AUXILIARY_FILE

		# If user asked it, finish execution
		if [[ $START_ACTION == "exit" ]]
		then
		    exit 0
		
		elif [[ $START_ACTION != "next" ]]

		# If user didn't ask to skip the ACTION, exec the ACTION
                then 
		    present_action $CURRENT_PROGRAM $CURRENT_ACTION
	            ${CURRENT_PROGRAM}-${CURRENT_ACTION}
		    
                    echo
		    echo "----------------------------------------------------------"
                    echo " * $CURRENT_ACTION of $CURRENT_PROGRAM has finished."
                    echo "----------------------------------------------------------"
                fi
            fi
        done

        # At this point, if START_ACTION != "done", the user introduced a bad ACTION
        if [[ ${START_ACTION} != "done" && ${START_ACTION} != "next" ]]
        then
           echo "Error: Action ${START_ACTION} is not a valid action for program ${CURRENT_PROGRAM}."
           echo "       This is the list of available actions:" "$*"
           exit 1
        fi

    fi
}

function show_help {
    echo "Use: $0 [OPTION]"
    echo
    echo "Options:"
    echo "  -h"
    echo "  --help      Display this message and exits"
    echo "  -v" 
    echo "  --version   Show the version of this script and exits"
    echo "  -r"
    echo "  --restart   Restart the state of the installation"
    # This could be improved for not deleting which was no compiled/installed
    echo "  -u"          
    echo "  --uninstall Delete \$COMPILING_DIR and \$INSTALLING_DIR"
    echo "  -s <program> [<action>]"
    echo "  --start <program> [<action>]"
    echo "              Start in program <program> and action <action>"
    echo
    echo "You should want to change the variables of the first part of"
    echo "the script for adjusting better its behavour."
    echo "Homepage: "
}


#############################################################
# THE SCRIPT START HERE
#############################################################

# Important initialization of variables
START_PROGRAM="install_gdl"
START_ACTION="presentation"

#############
# Options
#############
if   [[ ( $1 = "--help" ) || ( $1 = "-h" ) ]]
then
   show_help
   exit 0

elif [[ ( $1 = "--version" ) || ( $1 = "-v" ) ]]
then
   echo "install_gdl.sh 0.1"
   exit 0

# Warning! This delete everything which is inside the folders.
elif [[ ( $1 = "--uninstall" ) || ( $1 = "-u" ) ]]
then
   rm -rf $INSTALLATION_DIR $COMPILING_DIR $AUXILIARY_FILE
   exit 0

elif [[ ( $1 = "--restart" ) || ( $1 = "-r" ) ]]
then
   rm -f $AUXILIARY_FILE
   exit 0

elif [[ ( $1 = "--start" ) || ( $1 = "-s" ) ]]
then

   # This option needs at list $1: -s and $2 <program> 
   if [[ $# < 2 ]]
   then
      echo "-s option needs at least one parameter"
      echo "See: $0 --help"
      exit 1
   fi

   START_PROGRAM=$2

   if [[ $# = 2 ]]
   then
       # This assignement let that the correct do_step enters executes all the ACTIONs
       START_ACTION="done"
   elif [[ $# = 3 ]]
   then
       START_ACTION=$3
   else
       echo "-s accepts only two parameters. "
       exit 1
   fi
fi

###############################################
# Creating directories if they don't exist yet
###############################################
mkdir -p $INSTALLATION_DIR $COMPILATION_DIR \
    $GDL_INSTALLATION_DIR $GDL_COMPILATION_DIR

##########################################
# Recovering the installation state
##########################################

# If -s was NOT used (START_ACTION != "presentation") and exists
# $AUXILIARY_FILE (probably, because it was created automatically in a
# previous session), load the values of $AUXILIARY_FILE
if [[ ( $START_ACTION == "presentation" ) && ( -e $AUXILIARY_FILE ) ]]
then
    START_PROGRAM=`head -n 1 $AUXILIARY_FILE`
    START_ACTION=`tail -n 1 $AUXILIARY_FILE`

# Maybe a kind of "while read line; do ... $line; done" is more elegant
fi

#################
# Main part
#################

# At every execution, show the important directories that will be used
echo 
echo 'IMPORTANT: Check that main directories are OK:'
echo -e '\t Dir where dependencies are packaged:' $PKGS_DIR
echo -e '\t Dir for dependencies compilation:   ' $COMPILATION_DIR
echo -e '\t Dir for GDL compilation:            ' $GDL_COMPILATION_DIR
echo -e '\t Dir for dependencies installation:  ' $INSTALLATION_DIR
echo -e '\t Dir for GDL installation:           ' $GDL_INSTALLATION_DIR

# Forze the user to check it
echo 'Press ENTER when you are sure...'
read enter

do_step install_gdl presentation
do_step wxwidgets extraction configuration compilation installation
do_step magick extraction configuration compilation checking installation
do_step plplot extraction configuration compilation installation
do_step netcdf extraction configuration compilation installation
do_step gdl download_extraction configuration compilation installation
do_step non_free_idl_source_routines install
finishing_notes

# FIXME: Make a rule for fixing that after finishing the normal execution appears
# the next echo.

# At this point, if START_PROGRAM != "done", the user introduced a bad PROGRAM
if [[ $START_PROGRAM != "done" ]]
then
    echo "Error: Program ${START_PROGRAM} is not a valid program."
    exit 1
fi

exit 0
