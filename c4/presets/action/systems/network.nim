import logging
import strformat

import "../../../config"
import "../../../core/messages"
import "../../../core/entities"
import "../../../systems"
import "../../../systems/network/enet"

import physics


type
  ActionNetworkSystem* = object of NetworkSystem


method process(self: ref ActionNetworkSystem, message: ref CreateEntityMessage) =
  ## Sends message to video system.
  procCall ((ref NetworkSystem)self).process(message)
  message.send(config.systems.video)

method process(self: ref ActionNetworkSystem, message: ref MoveMessage) =
  ## Sends message to video system.
  procCall ((ref NetworkSystem)self).process(message)
  message.send(config.systems.video)

method process(self: ref ActionNetworkSystem, message: ref RotateMessage) =
  ## Sends message to video system.
  procCall ((ref NetworkSystem)self).process(message)
  message.send(config.systems.video)

# TODO: combine next 2 methods?

method process*(self: ref ActionNetworkSystem, message: ref ConnectionOpenedMessage) =
  ## When new peer connects, we want to create a corresponding entity, thus we forward this message to physics system.
  ## 
  ## Also we need to prepare scene on client side, that's why we send this message to video system as well.

  if config.mode == server:
    message.send(config.systems.physics)

  elif config.mode == client:
    message.send(config.systems.video)

method process*(self: ref ActionNetworkSystem, message: ref ConnectionClosedMessage) =
  ## When peer disconnects, we want to delete corresponding entity, thus we forward this message to physics system.
  ## 
  ## Also we need to unload scene on client side, that's why we send this message to video system as well.

  procCall ((ref NetworkSystem)self).process(message)

  if config.mode == server:
    message.send(config.systems.physics)

  elif config.mode == client:
    message.send(config.systems.video)

    logging.debug "Flushing local entities"
    entities.flush()
