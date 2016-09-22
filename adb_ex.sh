#!/bin/bash
#@(#) AUTHOR='N.Mueller,nico.mueller@digifors.de, phone: 0341.24146870'
#@(#) VERSION=0.1
#@(#) DATE=19-09.2016
#@(#) File: abe_ex.sh
#@(#) Parameter: [-i|-?|-h|-help]
##
## Last Modified By:
##      nico.mueller@digifors.de
##      Phone: 0341.24146870
##      DigiFors GmbH
##      Schongauer Str. 29-31
##      04328 Leipzig
##

AUTHOR='N.Mueller,nico.mueller@digifors.de, phone: 0341.24146870'
VERSION=0.1
DATE=19-09.2016
COMMENT="Script to extract unencryptet Android Backup Files"
PROG=`echo $0 | sed 's|.*/||'`
PROG_OPTIONS="-i|-?|-h|-help"
NAME=`echo $PROG | cut -f1 -d '.'`
HOSTNAME=`uname -n`


_SETLOCAL() {
## ----------------- CHANGE BASED ON SYSTEM NEEDS --------------------------------------
CMD_DD=/bin/dd
CMD_AWK=/usr/bin/awk
CMD_CAT=/bin/cat
CMD_GUNZIP=/usr/bin/gunzip
CMD_TAR=/usr/bin/tar
}

## ----------------- DO NOT EDIT BELOW THIS LINE ---------------------------------------
BS='1'
SKIP='24'


###############################################################
## Some logging information. fix format.
## $1: message string
##
sh_log()
{
        echo "$(date +"%d.%m.%Y %H:%M:%S"):$HOSTNAME:$NAME $*" >&2
}


###############################################################
## do_exit: Exit installation process
## $1 exit code (!= 0).
##
do_exit()
{
  sh_log "ERROR: do_exit"
  case "$1" in
  0)
                sh_log "ERROR: Execution failure. RC=$1"
        ;;
  1)
                sh_log "ERROR: Execution aborted - exit shell."
                exit $1
        ;;
  *)
                sh_log "ERROR: Execution failure. RC=$1"
                ;;
  esac

        return $1
}

####################################################################
## usage
## show command line options
usage() {
 sh_log "INFO : Usage $PROG [-i|-h]"
 sh_log "INFO : $COMMENT"
 sh_log "INFO : -i: select the android backup file"
}



####################################################################
## extract
## extract the adb image
extract() {
 read -p "The ADB Backup Filename: " INFILE
 sh_log "INFO : Read ${INFILE} File with Blocksize $BS and skip $SKIP Byte" 

 [ ! -f "${INFILE}" ] && { sh_log "ERROR: ${INFILE} file not found."; continue; }

 if [ -f "${INFILE}" ]
    then
        sh_log "INFO : The File ${INFILE} exits"
	FLINE=$(head -n 1 ${INFILE})
        sh_log "INFO : First Line of ${INFILE} is ${FLINE}"
        if [ "${FLINE}" == "ANDROID BACKUP" ]
 	   then
		sh_log "INFO : ${INFILE} looks like Android Backup File"
	        ${CMD_DD} if=${INFILE} bs=1 skip=24 of=${INFILE}.compress
		if [ -f "${INFILE}.compress" ]
		    then
			sh_log "INFO : Create Tarball from ${INFILE}.compress" 
			sh_log "INFO : Please be patient ....."
			### prepend the gzip magic number and compress method to the actual data
			printf "\x1f\x8b\x08\x00\x00\x00\x00\x00" | ${CMD_CAT} - ${INFILE}.compress | ${CMD_GUNZIP} -c > ${INFILE}.tar 2> /dev/null
		 	if [ -f "${INFILE}.tar" ]
			    then
				sh_log "INFO : Ectract Tarball"	
				${CMD_TAR} xf ${INFILE}.tar
			else
			    do_exit 1 $ERRNO
			fi
		cleanup
	
		fi
	   else
		sh_log "INFO : ${INFILE} is not a Android Backup File"
		do_exit 1 $ERRNO 
	fi
 fi 

}

####################################################################
## cleanup
## house keeping - remove temporary files
cleanup() {
 sh_log "INFO : House keeping"
 rm -f ${INFILE}.compress
 rm -f ${INFILE}.tar
}


##//////////////////////////////////////////////////////////////////
## MAIN
##//////////////////////////////////////////////////////////////////

_SETLOCAL

if [ "${#}" -eq "1" ]; then
        case "$1" in
        -i)     
		extract 
                ;;
        -?)
                usage
        	;;
        *)      usage
                do_exit 0 $ERRNO $LINENO
                ;;
        esac
fi


# EOF  

