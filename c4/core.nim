import parseopt
import logging
import os
import osproc
export osproc
import tables
import times
import strutils
import strformat
import sequtils
import typetraits
import unittest

when isMainModule:
  import threads


type Mode = enum client, server, master

# TODO: use `finalizer` kw for every `new()` call
const
  logLevels = logging.Level.mapIt(($it)[3..^1].toLowerAscii).join("|")
  modes = Mode.mapIt($it).join("|")
  help = &"""
    -v, --version - print version
    -h, --help - print help
    -m, --mode=[{modes}] - launch server/client/both
  """


proc getCmdLogLevel*(): logging.Level =
  for kind, key, value in parseopt.getopt():
    if (kind == cmdLongOption and key == "loglevel") or (kind == cmdShortOption and key == "l"):
      return parseEnum[logging.Level]("lvl" & value)

  return logging.Level.lvlWarn


template app*(serverCode: untyped, clientCode: untyped) =
  ## Handles CLI args, sets up logging and runs client / server / overseer process.
  ##
  ## Run this in your main module.

  # default values
  var mode = Mode.master

  for kind, key, value in parseopt.getopt():
    case kind
      of parseopt.cmdLongOption, parseopt.cmdShortOption:
        case key
          of "version", "v":
            echo &"Nim {NimVersion}"
            echo &"Compiled @ {CompileDate} {CompileTime}"
            quit()

          of "help", "h":
            echo help
            quit()
          of "mode", "m":
            mode = parseEnum[Mode](value)
          else:
            discard
      else:
        discard

  # TODO: outOfMemHook

  # this part of code handles spawning & maintaining client & server subprocesses
  if mode == Mode.master:
    let
      serverProcess = startProcess(
        command=getAppFilename(),
        args=commandLineParams() & "--mode=server",
        options={poParentStreams},
      )
      clientProcess = startProcess(
        command=getAppFilename(),
        args=commandLineParams() & "--mode=client",
        options={poParentStreams},
      )

    while serverProcess.running and clientProcess.running:
      sleep(1000)

    logging.info "Client or server not running -> shutting down"
    if clientProcess.running:
      logging.info "Terminating client process"
      clientProcess.kill()
    if serverProcess.running:
      logging.info "Terminating server process"
      serverProcess.kill()

    quit()

  ## this part of code initializes systems and runs game loop
  logging.debug "Starting " & $mode & " process"

  try:
    case mode
      of client:
        clientCode
      of server:
        serverCode
      else:
        discard

  except Exception as exc:
    # log any exception from client/server before dying
    logging.fatal "Exception: " & exc.msg & "\n" & exc.getStackTrace()
    raise

  # TODO: GC supports real-time mode which this library makes use of. It means the GC will never run during game frames and will use fixed amount of frame idle time to collect garbage. This leads to no stalls and close to zero compromise on performance comparing to native languages with manual memory management.

  logging.debug "Finishing process"


when isMainModule:
  suite "Core module":
    test "Run without threads":
      app do:  # server code
        echo "Physics system running"
      do:  # client code
        echo "Video system running"

      sleep(1000)
      assert true

    test "Run with threads":
      app do:  # server code
        spawn("physics"):
          echo "Physics system running"

        joinAll()

      do:  # client code
        spawn("video"):
          echo "Video system running"

        joinAll()

      assert true
