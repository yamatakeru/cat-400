import deques
import logging
import strformat

import core.messages
import core.entities
import utils.stringify


type
  MessageQueue* = Deque[ref Message]

  System* = object {.inheritable.}
    messageQueue: MessageQueue


# ---- System procs ----
method store*(self: ref System, message: ref Message) {.base.} =
  self.messageQueue.addLast(message)

method process*(self: ref System, message: ref Message) {.base.} =
  discard

method init*(self: ref System) {.base.} =
  self.messageQueue = initDeque[ref Message]()

method update*(self: ref System, dt: float) {.base.} =
  # process all messages
  if self.messageQueue.len > 0:
    var message: ref Message
    while self.messageQueue.len > 0:
      message = self.messageQueue.popFirst()
      self.process(message)  # may create new messages during work


# ---- Message procs ----
proc send*(self: ref Message, system: ref System) =
  if not system.isNil:
    system.store(self)

proc send*(self: ref Message, systems: seq[ref System]) =
  for system in systems:
    self.send(system)


# ---- messages ----
type
  SystemReadyMessage* = object of Message  ## \
    ## This message is sent to a system when its initialization is complete

  SystemQuitMessage* = object of Message  ## \
    ## This message is a signal to disconnect and terminate systems and whole process

messages.register(SystemReadyMessage)
messages.register(SystemQuitMessage)


# ---- helpers ----
template `as`*(instance: typed, T: typedesc): untyped =
  ## Converts ``instance`` to ``T`` type: ``createEntityMessage.as(ref Message)``
  (T)(instance)
