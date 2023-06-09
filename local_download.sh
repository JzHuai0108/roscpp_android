
my_loc=$1
LIBS_DIR=$my_loc/output/libs
prefix=$my_loc/output
SCRIPT_DIR=$my_loc/scripts

mkdir -p $LIBS_DIR
source $my_loc/scripts/config.sh
export OUTPUT_DIR="$prefix"
export TARGET_DIR=$OUTPUT_DIR/target
export LIBS_DIR=$OUTPUT_DIR/libs
source $SCRIPT_DIR/utils.sh

run_cmd() {
    cmd="$1".sh
    shift
    if [ -x $SCRIPT_DIR/$cmd ]; then
        cmd=$SCRIPT_DIR/$cmd
    elif [ -x $BASE_DIR/$cmd ]; then
        cmd=$BASE_DIR/$cmd
    fi
    $cmd "$@" || die "$cmd $@ died with error code $?"
}

export RBA_TOOLCHAIN=$my_loc/cmake/android.toolchain.cmake
echo "LIBS_DIR: $LIBS_DIR, prefix: $prefix, my_loc: $my_loc."
# Get all library dependencies.
run_cmd get_system_dependencies $my_loc/system_deps.rosinstall $LIBS_DIR
