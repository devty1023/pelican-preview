#!/bin/bash

PELICAN=pelican
BASEDIR=$(pwd)
INPUTDIR=$BASEDIR/content
OUTPUTDIR_BASE=$BASEDIR/output/
CONFILE=$BASEDIR/pelicanconf.py
THEMES=$BASEDIR/pelican-themes
BASE_URL=http://pelican-preview.herokuapp.com/
STATIC_DIR=$BASEDIR/static
HOME_HTML=home-$(date +"%Y-%m-%d").html


echo -e '\E[37;44m'"\033[1mStep 0-A: Removing output/ dir \033[0m"
rm -rf output/

if [ ! -d $THEMES ]; then
    echo -e '\E[37;44m'"\033[1mStep 0-B: Cloning from git repository\033[0m"
    git clone --recursive https://github.com/getpelican/pelican-themes ./pelican-themes
fi


# STEP1: Pull from themes from github
echo -e '\E[37;44m'"\033[1mStep 1: Pulling themes from github\033[0m"
echo pulling updates from git repository...
cd pelican-themes && git pull && cd ..
echo git pull done!

# STEP2: Generate html for all themes
echo -e '\E[37;44m'"\033[1mStep 2: Generate output for all themes..\033[0m"
for theme in $THEMES/*; do
    # generate new configuration file to modifyt SITEURL
    TMPCONF=$BASEDIR/${theme#$THEMES/}conf.py
    cp $CONFILE $TMPCONF
    echo SITEURL = \"$BASE_URL${theme#$THEMES/}\" >> $TMPCONF
    echo -en "\033[1mgenerating ${theme#$THEMES/}...\033[0m"   
    if $PELICAN $INPUTDIR -o $OUTPUTDIR_BASE${theme#$THEMES/} -s $TMPCONF -t $theme &>/dev/null 2>&1; then
        echo -e "\033[1msuccess!\033[0m"
    else
        echo -e '\E[47;31m'"\033[1mERROR: failed to generate ${theme#$THEMES/}!\033[0m"
        ## remove failed theme as candidate
        rm -rf output/${theme#$THEMES/}
        #$PELICAN $INPUTDIR -o $OUTPUTDIR_BASE${theme#pelican-themes/} -s $CONFILE -t $theme -D # poor man's way of generating erorr lines..
    fi
    rm ${TMPCONF%.py}.*
done

# STEP3: Generate home-<timestamp>.html file using jinja2
echo -e '\E[37;44m'"\033[1mStep 3: Generate home.html...\033[0m"
python index_page_gen.py > $HOME_HTML

# STEP4: Generate index.php
echo -e '\E[37;44m'"\033[1mStep 4: Generate index.php...\033[0m"
echo "<?php include_once(\"$HOME_HTML\");?>" > index.php

# STEP5: move static/, index.php, and home.html file to output folder
echo -e '\E[37;44m'"\033[1mStep 5: Move static and index.html files..\033[0m"
cp -r static output
mv index.php output/
mv $HOME_HTML output/

# STEP6: Git and push to heroku
cd output/
## create Procfile to indicate using nginx (Apache is behaving weird..)
echo http://pelican-preview.herokuapp.com/ > Procfile
## push to heroku
git init && git remote add heroku git@heroku.com:pelican-preview.git && git add -A && git commit -m "automatic commit for $HOME_HTML" && git push heroku master --force
cd ..
