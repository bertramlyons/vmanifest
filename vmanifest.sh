#!/bin/ksh
#  Usage:  vmanifest [full path of directory]
#
#  * Assumes a single directory that contains a set of content files and a set of individual .md5 files
#  ** Generates manifest of md5s from individual md5 text files
#  ** Creates new md5s of the payload files
#  ** Runs diff against old manifest and new manifest and reports result
#  * Not recursive
#
#  Remember to make the script executable - chmod +x vmanifest.sh
#
#  Requirements: for MAC OS only
#  This is an example script written at IASA, 2015


#  the version of the script

VERSION=1.0


#  Clear the Terminal and announce the tool

clear
echo "MD5 Manifest Verifier: Version - $VERSION"
echo "Written for IASA  demonstration only"
echo "AVPreserve, 2015; running `date`"


# syntax check (must have only one parameter: input directory)

if [ -z "$1" ];
then echo "Syntax: $0 <input directory>"
exit 1
fi

# change to the requested directory and inform the user of such

cd "$1"
echo ""
echo "Preparing to gather md5s from the following directory as requested: "
pwd
echo ""
echo ""

# create new directory on the users desktop called "md5_verification" and inform user

echo "Creating new metadata folder for the requested directory..."
mkdir ~/desktop/md5_verification
echo ""

# begin gathering md5s from all .md5 files in directory and
# placing results in a manifest.txt file

echo "Extracting pre-written md5s from md5 files..."
COUNTERMD5=0
for i in *.md5; do

#   NAME=${i%.*}
COUNTERMD5=$(("$COUNTERMD5"+1));
ENTRY=$(sed -n '1p' "$i");
echo $ENTRY >> ~/desktop/md5_verification/manifest.txt;
unset ENTRY;
done

echo ""
echo "Generating new md5s for payload files..."

COUNTERFILE=0
for i in !(*.md5);
do COUNTERFILE=$(("$COUNTERFILE"+1));
NENTRY=$(md5 -r "$i");
echo $NENTRY >> ~/desktop/md5_verification/nmanifest.txt;
unset NENTRY;
done

echo ""
echo "Comparing old md5s with new md5s..."

cd ~/desktop/md5_verification

RESULT=$(diff -s manifest.txt nmanifest.txt)

# determine problem
if [ "$RESULT" = "Files manifest.txt and nmanifest.txt are identical" ]
then
    echo "MD5 Verifier Tool" >> ./verification_result.txt
    NOW=$(date)
    echo "Date performed: $NOW" >> ./verification_result.txt
    echo "$COUNTERMD5 md5s found" >> ./verification_result.txt
    echo "$COUNTERFILE files evaluated" >> ./verification_result.txt
    echo "Result: All files are accounted for and all files match previous MD5s." >> ./verification_result.txt
    echo "" >> ./verification_result.txt
    echo "Files verified:" >> ./verification_result.txt
    FILES=$(cat ~/desktop/md5_verification/manifest.txt)
    echo "$FILES" >> ./verification_result.txt
# inform user of success and how many file processed
    echo ""
    echo "Analysis complete."
    echo "$COUNTERMD5 md5s found"
    echo "$COUNTERFILE files processed"
    echo ""
    echo "Result: All files are accounted for and all files match previous MD5s."
    echo ""
    exit
else
    MD5CHECK=$(("$COUNTERMD5"-"$COUNTERFILE"))
    FILECHECK=$(("COUNTERFILE"-"$COUNTERMD5"))
    if [ $MD5CHECK -ne $FILECHECK ]
    then
        if [ $MD5CHECK -lt $FILECHECK ]
        then
            echo "MD5 Verifier Tool" >> ./verification_result.txt
            NOW=$(date)
            echo "Date performed: $NOW" >> ./verification_result.txt
            echo "$COUNTERMD5 md5s found" >> ./verification_result.txt
            echo "$COUNTERFILE files evaluated" >> ./verification_result.txt
            echo "There are more files here than checksums to verify." >> ./verification_result.txt
            echo "Result: $RESULT." >> ./verification_result.txt
# inform user of success and how many file processed
            echo ""
            echo "Analysis complete."
            echo "$COUNTERMD5 md5s found"
            echo "$COUNTERFILE files processed"
            echo "There are more files here than checksums to verify."
            echo ""
            echo "Result: $RESULT"
            echo ""
            exit
        else
            echo "MD5 Verifier Tool" >> ./verification_result.txt
            NOW=$(date)
            echo "Date performed: $NOW" >> ./verification_result.txt
            echo "$COUNTERMD5 md5s found" >> ./verification_result.txt
            echo "$COUNTERFILE files evaluated" >> ./verification_result.txt
            echo "There are more checksums here than files to verify." >> ./verification_result.txt
            echo "Result: $RESULT." >> ./verification_result.txt
# inform user of success and how many file processed
            echo ""
            echo "Analysis complete."
            echo "$COUNTERMD5 md5s found"
            echo "$COUNTERFILE files processed"
            echo "There are more checksums here than files to verify."
            echo ""
            echo "Result: $RESULT"
            echo ""
            exit
        fi
    else
        echo "MD5 Verifier Tool" >> ./verification_result.txt
        NOW=$(date)
        echo "Date performed: $NOW" >> ./verification_result.txt
        echo "$COUNTERMD5 md5s found" >> ./verification_result.txt
        echo "$COUNTERFILE files evaluated" >> ./verification_result.txt
        echo "Checksums do not match." >> ./verification_result.txt
        echo "Result: $RESULT." >> ./verification_result.txt
# inform user of success and how many file processed
        echo ""
        echo "Analysis complete."
        echo "$COUNTERMD5 md5s found"
        echo "$COUNTERFILE files processed"
        echo "Checksums do not match."
        echo ""
        echo "Result: $RESULT"
        echo ""
        exit
    fi
fi
