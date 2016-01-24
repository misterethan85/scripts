#!/bin/sh

###############################################################################
# Author: Ethan Hicks                                                         #
# Created on: 1-22-2016				                                                #
# Use: parses text file like the one linked below and                         #
# Verifies the relevant patches are installed on                              #
# your IBM systems.                                                           #
#                                                                             #
#									                                                            #
# 									                                                          #
#									                                                            #
#                                                                             #
# http://aix.software.ibm.com/aix/efixes/security/openssl_advisory15.asc      #
###############################################################################



PROGNAME=`/bin/basename $0`
PROGPATH=`echo $0 | sed -e 's,[\\/][^\\/][^\\/]*$,,'`
REVISION="1.0"
FILE=$1
APARS=`sed -n /'IBM has assigned the following APARs to this problem'/,/'Subscribe to the APARs here'/p $FILE | egrep -i "6|7" | awk '{print $2,$3,$4}'`
CHECK=`cat $FILE | grep "APARS" | awk '{print $2 }'`

if [ "$USER" != "root" ]
then
  user_greet ()   # Function definition embedded in an if/then construct.
  {
    echo 
    echo "Hello $USER, Version $REVISION of $PROGNAME is now executing from the $PROGPATH Directory."
    echo
  }
fi  

user_greet 

is_installed() # Verifies The neccessary tools are installed.
{
   which $1 > /dev/null 2>&1
   if [ "$?" -ne 0 ]
   then
   printf "\nERROR: %s not installed. \n\n" $1
   exit 255
   fi
}

is_installed sed
is_installed head
is_installed tail
is_installed tr
is_installed grep


error_checks () # helps in troubleshooting why file wont work or is unreadable.
{
    if [ ! -e "$FILE" ] 
    then
    echo "File check error: file $FILE does not exist!"
    exit $STATE_UNKNOWN

    elif [ ! -r "$FILE" ] 
    then
    echo "File check error: file $FILE is not readable!"
    exit $STATE_UNKNOWN
    fi
}

error_checks


cve_info() # Gets CVE Numbers from file.

{
    if [ "$#" -ne 1 ]
    then
    echo "Getting CVE's"
    echo 
    cveid=`cat $FILE | grep "CVEID" | awk '{print $2 }'`
    echo $cveid
    echo
    fi
}    

cve_info

package_info() # Gets list of vulnerable packages.
{
    echo "Fectching packages"
    echo
    package=`sed -n '/------/,/^$/p' $FILE | head | grep -v '-' | sed '/^$/d' | sed 's/|//'| sed 's/\,//g'| awk '{print $1,$2,$3}'`
    echo $package
    echo
}

package_info

get_apars () # Checks for available APARS or EFIXES
{
    echo "Searching for APARS and available EFIXES"
    echo
    if [ "$CHECK" = 'A.' ] 
    then
    echo $APARS
    echo
    else
    echo " There are no APARS or EFIXES currently available for this issue."
    echo
    fi
}

get_apars


echo "**************************************************************************************"

make_file () # Builds the text file to be merged onto the CSV Master.
{

echo $cveid &>>temp.txt
echo $package &>>temp.txt
echo $APARS &>>temp.txt
echo &>>temp.txt

}




make_file



#format_final_file () # Overwrites existing CSV file and appends new data from text file created to end of CSV.  
#{
#OutFileName="Security_Patch_Tracking.csv" # Fix the output name
#
#i=0                                       # Reset a counter
#for filename in ./*.csv; do 
# if [ "$filename"  != "$OutName" ] ;      # Avoid recursion 
# then 
#   if [[ $i -eq 0 ]] ; then 
#      head -1  $filename >   $OutFileName # Copy header if it is the first file
#   fi
#   tail -n +2  $filename >>  $OutFileName # Append from the 2nd line each file
#   i=$(( $i + 1 ))                        # Increase the counter
# fi
#
#rm ./temp.csv > /dev/null 2>&1
#
#done
#}
#
#format_final_file


