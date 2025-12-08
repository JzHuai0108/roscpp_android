# Configures environment variables required for other scripts to work properly.
# Always source this file before using the scripts.

# Configure the Android NDK and toolchain
export ANDROID_ABI=arm64-v8a
export ANDROID_STL=c++_static       # or c++_shared, see https://developer.android.com/ndk/guides/cpp-support
export ANDROID_PLATFORM=android-31
# android 7.0 is android api level 24
# Enable this value for debug build
#CMAKE_BUILD_TYPE=Debug
export CMAKE_BUILD_TYPE=Release

# Define the number of simultaneous jobs to trigger for the different
# tasks that allow it. Use the number of available processors in the
# system.
export PARALLEL_JOBS=$(nproc)

# Export common paths
export SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
export BASE_DIR=$SCRIPT_DIR/..

# Try to locate a valid Android NDK if ANDROID_NDK_HOME is unset or invalid.
_rba_validate_ndk_root() {
    local candidate="$1"
    if [ -z "$candidate" ]; then
        return 1
    fi
    if [ -f "$candidate/ndk-build" ] || [ -f "$candidate/ndk-build.cmd" ]; then
        (cd "$candidate" >/dev/null 2>&1 && pwd)
        return 0
    fi
    return 1
}

_rba_version_score() {
    local tokenized="${1//[^0-9.]/.}"
    local IFS='.'
    local part
    local score=0
    for part in $tokenized; do
        [ -z "$part" ] && continue
        if [[ "$part" =~ ^[0-9]+$ ]]; then
            score=$((score * 1000 + part))
        fi
    done
    echo "$score"
}

_rba_append_latest_ndk_child() {
    local parent="$1"
    [ -d "$parent" ] || return
    local best_path=""
    local best_score=-1
    local child
    for child in "$parent"/*; do
        [ -d "$child" ] || continue
        local base=$(basename "$child")
        local score=$(_rba_version_score "$base")
        if [ "$score" -gt "$best_score" ]; then
            best_score="$score"
            best_path="$child"
        fi
    done
    [ -z "$best_path" ] || _ndk_candidates+=("$best_path")
}

# Keep user-provided value only if it is valid.
if [ -n "$ANDROID_NDK_HOME" ]; then
    if ! _resolved_ndk="$(_rba_validate_ndk_root "$ANDROID_NDK_HOME")"; then
        echo "[config.sh] Warning: ANDROID_NDK_HOME='$ANDROID_NDK_HOME' is not a valid NDK root. Attempting auto-detection." >&2
        unset ANDROID_NDK_HOME
    else
        export ANDROID_NDK_HOME="$_resolved_ndk"
    fi
fi

if [ -z "$ANDROID_NDK_HOME" ]; then
    _ndk_candidates=()

    # Candidates derived from common SDK env vars.
    for _sdk_root in "$ANDROID_HOME" "$ANDROID_SDK_ROOT"; do
        if [ -z "$_sdk_root" ]; then
            continue
        fi
        _ndk_candidates+=("${_sdk_root}/ndk-bundle")
        [ -d "${_sdk_root}/ndk" ] && _rba_append_latest_ndk_child "${_sdk_root}/ndk"
    done

    # Typical host-specific installation roots.
    for _root in "$HOME/Library/Android/sdk" "$HOME/Android/Sdk" "/opt/android/sdk" "/opt/android-sdk" "/opt/android-sdk-linux"; do
        [ -d "$_root" ] || continue
        _ndk_candidates+=("${_root}/ndk-bundle")
        [ -d "${_root}/ndk" ] && _rba_append_latest_ndk_child "${_root}/ndk"
    done

    # Historical defaults used inside our Docker images.
    _ndk_candidates+=("/opt/android/sdk/android-ndk-r23c" "/opt/android-sdk-linux/ndk")

    for _candidate in "${_ndk_candidates[@]}"; do
        if _resolved_ndk="$(_rba_validate_ndk_root "$_candidate")"; then
            export ANDROID_NDK_HOME="$_resolved_ndk"
            break
        fi
    done

    if [ -z "$ANDROID_NDK_HOME" ]; then
        echo "[config.sh] Warning: Unable to auto-detect ANDROID_NDK_HOME. Please export it manually." >&2
    fi
fi

