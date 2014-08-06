#!/bin/bash
#set up project name
ENV_NAME="shorty_book"
ENV_OPSTS="--no-site-packages --distribute"

unset PYTHONDONTWRITEBYTECODE
echo "Making Virtual Environment"
os="`uname -a`"
if [[ "$os" == *Linux* ]]; then
    source /etc/bash_completion.d/virtualenvwrapper
else
    source `which virtualenvwrapper.sh`
fi



cd $WORKON_HOME
mkvirtualenv --distribute $ENV_OPTS $ENV_NAME
cd -
workon $ENV_NAME
export DJANGO_SETTINGS_MODULE=$ENV_NAME.settings.local
echo $VIRTUAL_ENV

#install requirements
if [ ! -d ${HOME}/.pip-packages ]
then
    mkdir -p ${HOME}/.pip-packages
fi


if [  -d $WORKON_HOME/shorty_book/build/ ]
then
    rm -rf $WORKON_HOME/shorty_book/build/
fi

pip install --download ${HOME}/.pip-packages --exists-action w -r requirements-dev.txt
pip install --no-index --exists-action w --find-links=file://${HOME}/.pip-packages/ -r requirements-dev.txt

#check if postgres installed
RESULT=`psql -l | grep "shorty_book" | wc -l | awk '{print $1}'`;
if test $RESULT -eq 0; then
    echo "Creating Database";
    psql -c "create role shorty_book with createdb encrypted password 'shorty_book' login;"
    psql -c "create database shorty_book with owner shorty_book;"
else
    echo "Database exists"
fi

#run initial migrations and syncdb
python manage.py syncdb --migrate

#link up with git!
if [ -d .git ]; then
  echo "Git exists";
else
    echo "Setting up Git"
    git init .
    git remote add origin "git@github.com:Lightmatter/shorty_book.git"
    #todo - add all and make initial push
fi

#todo - git flow init

chmod +x manage.py
