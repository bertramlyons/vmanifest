#!/bin/ksh
#  Usage:  vmanifest [full path of directory]
#
#  * Assumes a single directory that contains a set of content files and a set of individual .md5 files
#  ** Generates manifest of md5s from individual md5 text files
#  ** Creates new md5s of the payload files
#  ** Runs diff against old manifest and new manifest and reports result
#  * Not recursive - input directory must contain all files directly
#
#  Remember to make the script executable: chmod +x vmanifest.sh
#
#  Requirements: for MAC OS only, assumes existence of MD5 utility that comes with MAC OS
#  This is an example script written by Bertram Lyons at IASA, 2015, in Paris, France for demonstration


#  the version of the script

VERSION=1.0


#  Clear the Terminal and announce the tool

clear
echo "MD5 Manifest Verifier: Version - $VERSION"
echo "Written for IASA  demonstration only"
echo "AVPreserve, 2015; running `date`"


# syntax check (must have only one parameter: input directory)

if [ ! -d "$1" ];
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

# create new directory on the user's desktop called "md5_verification" and inform user
# change the OUTPATH below to specify a different location for output files
OUTPATH=~/desktop/md5_verification
if [ ! -d "$OUTPATH" ]; then
    echo "Creating new metadata folder for the requested directory..."
    mkdir -p "$OUTPATH"
    echo ""
fi

# begin accumulating md5s from all .md5 files in directory and
# placing results in a single new manifest.txt file

echo "Extracting pre-written md5s from md5 files..."
ls -1 | grep ".md5$" | while read file ; do
    cat "$file"
done | sort -k2 > "$OUTPATH/manifest.txt"
COUNTERMD5=$(wc -l "$OUTPATH/manifest.txt" | awk '{print $1}')

# begin generating new md5s from all content files in directory and
# placing results in a single new nmanifest.txt file

echo ""
echo "Generating new md5s for payload files..."

COUNTERFILE=0
for i in !(*.md5);
do COUNTERFILE=$(("$COUNTERFILE"+1));
NENTRY=$(md5 -r "$i");
echo $NENTRY >> $OUTPATH/nmanifest.txt;
unset NENTRY;
done

# compare old md5 manifest with new md5 manifest to determine any issues

echo ""
echo "Comparing old md5s with new md5s..."

cd $OUTPATH

RESULT=$(diff -s manifest.txt nmanifest.txt)

# determine if any problems exist based on the results of the diff function above

if [ "$RESULT" = "Files manifest.txt and nmanifest.txt are identical" ]
then
    echo "MD5 Verifier Tool" >> $OUTPATH/verification_result.txt
    NOW=$(date)
    echo "Date performed: $NOW" >> $OUTPATH/verification_result.txt
    echo "$COUNTERMD5 md5s found" >> $OUTPATH/verification_result.txt
    echo "$COUNTERFILE files evaluated" >> $OUTPATH/verification_result.txt
    echo "Result: All files are accounted for and all files match previous MD5s." >> $OUTPATH/verification_result.txt
    echo "" >> $OUTPATH/verification_result.txt
    echo "Files verified:" >> $OUTPATH/verification_result.txt
    FILES=$(cat $OUTPATH/manifest.txt)
    echo "$FILES" >> $OUTPATH/verification_result.txt
# inform user of success and how many files processed
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
    FILECHECK=$(("$COUNTERFILE"-"$COUNTERMD5"))
    if [ $MD5CHECK -ne $FILECHECK ]
    then
        if [ $MD5CHECK -lt $FILECHECK ]
        then
            echo "MD5 Verifier Tool" >> $OUTPATH/verification_result.txt
            NOW=$(date)
            echo "Date performed: $NOW" >> $OUTPATH/verification_result.txt
            echo "$COUNTERMD5 md5s found" >> $OUTPATH/verification_result.txt
            echo "$COUNTERFILE files evaluated" >> $OUTPATH/verification_result.txt
            echo "There are more files here than checksums to verify." >> $OUTPATH/verification_result.txt
            echo "Result: $RESULT." >> $OUTPATH/verification_result.txt
# inform user of success and how many files processed
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
            echo "MD5 Verifier Tool" >> $OUTPATH/verification_result.txt
            NOW=$(date)
            echo "Date performed: $NOW" >> $OUTPATH/verification_result.txt
            echo "$COUNTERMD5 md5s found" >> $OUTPATH/verification_result.txt
            echo "$COUNTERFILE files evaluated" >> $OUTPATH/verification_result.txt
            echo "There are more checksums here than files to verify." >> $OUTPATH/verification_result.txt
            echo "Result: $RESULT." >> $OUTPATH/verification_result.txt
# inform user of success and how many files processed
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
        echo "MD5 Verifier Tool" >> $OUTPATH/verification_result.txt
        NOW=$(date)
        echo "Date performed: $NOW" >> $OUTPATH/verification_result.txt
        echo "$COUNTERMD5 md5s found" >> $OUTPATH/verification_result.txt
        echo "$COUNTERFILE files evaluated" >> $OUTPATH/verification_result.txt
        echo "Checksums do not match." >> $OUTPATH/verification_result.txt
        echo "Result: $RESULT." >> $OUTPATH/verification_result.txt
# inform user of success and how many files processed
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
