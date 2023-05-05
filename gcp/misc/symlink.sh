#!/bin/bash

SOURCE_DIR="../../base"
DEST_DIR="."

exclude_files=('locals.tf')

function check_exclude_file() {
    for i in ${exclude_files[@]}; do
        if [ "`echo $1 | grep ${i}`" ]; then
            return 1
        fi
    done
    return 0
}

echo "Creating symbolic links..."

mkdir -p "$DEST_DIR"
cd "$DEST_DIR" || exit

for file in "$SOURCE_DIR"/*; do
  check_exclude_file $file
  if [ $? == 0 ]; then
    file_base="$(basename "${file}")"
    file_no_ext="${file_base%.*}"
    ln -sf "${SOURCE_DIR}/${file_base}" "${file_no_ext}.link.tf"
  fi
done

echo "Creating symbolic links...done!"
