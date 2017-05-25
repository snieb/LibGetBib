#!/usr/bin/bash

# Fetches BiBTeX data from Library Genesis for all e-books in current folder.

#waitTime=1  # seconds to wait between downloads
v=3  # 0: no output | 1: errors | 2: +downloads | 3: +finish | 5: everything
bibPath=".myLibGenFic.bib" # path to BiBTeX file
infilesPath=* # path of ebooks
url="http://libgen.io/book/bibtex.php?md5=" # URL for fetching BiBTeX data
# url="http://gen.lib.rus.ec/boorm k/bibtex.php?md5="
extensions="pdf epub mobi djvu chm txt doc docx rtf htm html rar zip lit cbr cbz azw3 azw ps eps prc kf8 iba bbeb fb2 fb2.zip tcr" # only check these file ext.s
#extensions="" # check all existing files

for file in $infilesPath; do

   # filter by extension
  if [[ -f $file ]] \
       && ( [[ -z $extensions ]] \
          || $(echo $extensions | grep -iq -e ${file##*.}))  \
  ; then
  
    # create hash
    hash=`md5sum -- "$file" || echo ""`
    if [[ -z $hash ]]; then
      [[ $v<1 ]] || echo "ERROR while hashing file: $file"
    else  # valid hash
      # extract actual hash (md5sum also prints filename)
      hash=${hash:0:32}
      
      # does entry already exist?
      if $(cat "$bibPath" | grep -iq -e "$hash"); then
        [[ $v<4 ]] || echo "Entry already exists: $file"
      else
        # fetch from internet & append to BiBTeX file
        [[ $v<2 ]] || echo "Fetching info on $file" 
        #lynx --source -- $url$hash \
        #curl -- $url$hash \
        wget --random-wait -q -O - -- $url$hash \
            | sed -n -e "/@book/,/url = /p" -e "/url = /a\}\n" \
            >> ${bibPath}
        [[ $v<2 ]] || echo "... done!"
        #sleep $waitTime
      fi
        
    fi
    
  else
    [[ $v<4 ]] || echo "Ignoring $file"
  fi
done