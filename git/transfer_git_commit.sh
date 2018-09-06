#!/bin/bash

GITHUB_REPO=https://github.com/smartdevicelink/sdl_core/commit/
PRE_COMMIT_HOOK="SYNC-10345"

function get_script_name() {
  echo `basename $1`
}

SCRIPT_NAME=$(get_script_name $0)
GIT_CHECKOUT="git checkout"
GIT_PULL_ORIGIN="git pull origin"
GIT_BRANCH="git branch"


function echo_and_do() {
  echo $1
  $1
}

function error_echo() {
  RED='\033[0;31m'
  NO_COLOR='\033[0m' # No Color

  echo -e "${RED}$1${NO_COLOR}"
}

function is_current_directory_is_git_repository() {
  git -C ./ rev-parse

  if [ $? -ne 0 ]; then
    error_echo $(pwd)" ain't git repository folder"
    exit 1
  fi
}

function is_current_git_branch_suitable() {
  current_branch=$(git branch | grep \* | cut -d ' ' -f2)

  if [ "$current_branch" == "$1" ]; then
    echo "yes"
  else
    echo "no"
  fi
}

function get_commit_name() {
  regexp="\[PATCH\][[:space:]](.*)"
  path_subject=$(head -n 4 $1 | tail -n 1) #4-th patch's line contains subject/commit name

  if [[ $path_subject =~ $regexp ]]; then
    echo "${BASH_REMATCH[1]}"
  else
    error_echo "Can't handle commit name"
    exit 1
  fi
}

function get_changed_files() {
  regexp_short_file_name="[.]{3}([^|]+)[[:space:]]{1,}\|"
  declare -a short_file_name_arr;
  result_line=''

  while read line
  do
    [[ $line =~ $regexp_short_file_name ]] && short_file_name_arr+=(${BASH_REMATCH[1]})
  done < $1

  patch_content=$(cat $1)
  for item in ${short_file_name_arr[@]}; do
    [[ $patch_content =~ diff[[:space:]]--git[[:space:]]a\/([^ ]+$item) ]] && result_line+=' '${BASH_REMATCH[1]} 
  done

  echo $result_line
}

function download_patch() {
  wget -q $GITHUB_REPO$PATCH_NAME

  if [ ! -f $PATCH_NAME ]; then
    error_echo "File $PATCH_NAME not found!"
    exit 1
  fi
}




echo "$SCRIPT_NAME says 'Hello, my lazy friend'"

is_current_directory_is_git_repository

if [ "$(is_current_git_branch_suitable $1)" == "no" ]; then
  echo_and_do "$GIT_CHECKOUT master"
  echo_and_do "$GIT_PULL_ORIGIN master"
  echo_and_do "$GIT_BRANCH $1"
  echo_and_do "$GIT_CHECKOUT $1"
fi

PATCH_NAME=$2.patch

download_patch $PATCH_NAME

COMMIT_NAME=$(get_commit_name $PATCH_NAME)
CHANGED_FILES=$(get_changed_files $PATCH_NAME)

echo_and_do "git apply $PATCH_NAME"
echo_and_do "rm $PATCH_NAME"
echo_and_do "git add $CHANGED_FILES"
git commit -m "$COMMIT_NAME" -m $PRE_COMMIT_HOOK

echo "$SCRIPT_NAME says 'All was success, bye-bye'"

