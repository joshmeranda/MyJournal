# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# logger is a VERY minimal logging framework for use within other bash scripts. #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

export LOG_LEVEL_CRITICAL=10 \
       LOG_LEVEL_ERROR=20 \
       LOG_LEVEL_WARNING=30 \
       LOG_LEVEL_INFO=40 \
       LOG_LEVEL_DEBUG=50

LOG_LEVEL_DEFAULT=$LOG_LEVEL_INFO

# Allows user to specify their own default log level by exporting a value for
# LOG_LEVEL before sourcing this script
LOG_LEVEL=${LOG_LEVEL:-$LOG_LEVEL_DEFAULT}

# Retrieve the prefix for any log entries, expecting the level identifier in
# '$1' (ex 'info').
prefix() {
    level="$1"
    timestamp="$(date --iso-8601=seconds)"

    echo -n "$timestamp [$level]"
}

# Log all data following '$1' to stdout using the log level given as '$1'.
write_log() {
    prefix="$(prefix "$1")"
    shift

    echo "$prefix $*"
}

# Determine if the log level value given as '$1' should be logged in the
# current environment.
should_log() {
    test "$1" -le "$LOG_LEVEL"
}

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# These will all log everything passed as arguments with the appropriate level  #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

log_critical() {
    should_log $LOG_LEVEL_CRITICAL && write_log critical "$@"
}

log_error() {
    should_log $LOG_LEVEL_ERROR && write_log error "$@"
}

log_warning() {
    should_log $LOG_LEVEL_WARNING && write_log warning "$@"
}

log_info() {
    should_log $LOG_LEVEL_INFO && write_log info "$@"
}

log_debug() {
    should_log $LOG_LEVEL_DEBUG && write_log debug "$@"
}