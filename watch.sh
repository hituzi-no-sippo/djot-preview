#!/usr/bin/env bash
#
# @(#) v0.1.0 2024-03-09T16:27:47+09:00
# @(#) Copyright (C) 2024 hituzi-no-sippo
# @(#) LICENSE: MIT-0 (https://choosealicense.com/licenses/mit-0/)

# Suppress Lefthook outputs
# References
# - https://github.com/evilmartians/lefthook/blob/49da7f3a9324466270af7c85c3ab16e5b0e8b7ae/docs/configuration.md#skip_output
# - https://github.com/evilmartians/lefthook/blob/49da7f3a9324466270af7c85c3ab16e5b0e8b7ae/docs/usage.md#lefthook_quiet
# v1.6.5 Commit on 2024-03-04
declare -x -r LEFTHOOK_QUIET='meta,skips,empty_summary,success,execution'

declare -r COMMAND_TO_CONVERT='convert-djot-to-html'

watch() {
  # Reasons for not running watchexec in Lefthook.
  # - You can not stop a watchexec process
  # - You can not see results of Lefthook
  #
  # A Lefthook configuration when tested if watchexec work within Lefthook.
  # ``` YAML
  # watch-djot:
  #   parallel: true
  #   commands:
  #     devserver:
  #       run: devserver
  #     watch-djot:
  #       run: |
  #         watchexec --exts djot \
  #           -- \
  #           lefthook run convert-djot-to-html
  # ```
  #
  # watchexec options
  # - `emit-events-to=stdin`
  #    Outputs a path of modified file to STDIN.
  #
  # Do not enclose '--file=$(cut --delimiter=":" --fields=2)'
  # with using double quotionmarks (`"`).
  # This is because
  # if enclose with using double quotionmarks,
  # `$(cut --delimiter=":" --fields=2)` do not extract a path of modified file.
  watchexec \
    --exts=dj \
    --poll=1s \
    --on-busy-update=do-nothing \
    --emit-events-to=stdin \
    --postpone \
    -- \
    "lefthook run $COMMAND_TO_CONVERT" \
    '--file="$(cut --delimiter=":" --fields=2)"'
}

main() {
  # NOTE
  # At this point,
  # this script does not convert Djot file that are not managed by Git to HTML.
  if lefthook run "$COMMAND_TO_CONVERT"; then
    watch

    lefthook run remove-html-converted-from-djot
  fi
}

main
