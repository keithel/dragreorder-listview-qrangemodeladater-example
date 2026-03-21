#!/bin/bash
# test_step.sh

# This is a script that you run with `git rebase --exec` that will help
# you test each test step to make sure that it compiles, runs, and the
# behavior matches the desired step content.

QT_PATH="$HOME/Qt/6.11.0/gcc_64"
BUILD_DIR="build_test"
GIT_DIR=$(git rev-parse --git-dir 2>/dev/null)
LOG_FILE="$GIT_DIR/../failed_commits.txt"

cleanup() {
    if [ -n "$BUILD_DIR" -a -f "$BUILD_DIR/CMakeCache.txt" ]; then
        echo "Cleaning up $BUILD_DIR..."
        rm -Rf "$BUILD_DIR"
    fi
}
trap cleanup EXIT
trap 'echo -e "\nTesting aborted by user."; exit 1' SIGINT

if [[ -z "$GIT_EXEC_PATH" || ! -d "$GIT_DIR/rebase-merge" ]]; then
    SCRIPT_PATH=$(realpath --relative-to=. "${BASH_SOURCE[0]}")
    echo >&2 "Not running under git rebase action."
    echo >&2 "If you would like to test multiple steps, please re-run under 'git rebase'."
    echo >&2 "To test the entire branch from the root:"
    echo >&2 "    $ git rebase --root --exec \"$SCRIPT_PATH\""
    echo >&2
    echo >&2 "To test the entire branch starting from a particular sha1 hash:"
    echo >&2 "    $ git rebase ~<sha1 hash> --exec \"$SCRIPT_PATH\""
    LOG_FILE=/dev/stdout
else
    echo "Confirmed: Running under Git Rebase action."
fi

# Clean and Build
rm -rf $BUILD_DIR
$QT_PATH/bin/qt-cmake -G Ninja -B $BUILD_DIR -S .
cmake --build $BUILD_DIR --parallel

if [ $? -ne 0 ]; then
    echo "BUILD FAILED for commit: $(git rev-parse HEAD)"
    exit 1
fi

# Show the commit message
git log -1
echo

# Run the App
echo "Starting App... Please test drag-reorder and close the window when done."
./$BUILD_DIR/qml/appTaskApp
echo "App exit code $?"

# Interactive Judgment with default 'y', converting input to lowercase and
# defaulting to 'y' if empty
read -n 1 -r -p "Did this step work as expected? (Y/n): " user_val
echo
user_val=${user_val:-y}
user_val=$(echo "$user_val" | tr '[:upper:]' '[:lower:]')

if [ "$user_val" != "y" ]; then
    read -r -p "Enter failure details: " failure_msg

    # Record the failure to a log file
    {
        echo "$(git rev-parse --short HEAD): $(git log -1 --pretty=%s)"
        echo "    $failure_msg"
    } >> "$LOG_FILE"

    echo "Marked as FAILED."
else
    echo "Marked as PASSED."
fi

exit 0
