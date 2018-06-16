import logging
import strformat

import c4.systems.physics.ode as ode_physics
import c4.presets.action.systems.physics
import c4.systems
import c4.config
import c4.core.entities
import c4.wrappers.ode.ode
import "../messages"


type
  SandboxPhysicsSystem* = object of ActionPhysicsSystem
    cubes: seq[Entity]    


method init*(self: ref SandboxPhysicsSystem) =
  # Disable gravitation for now
  procCall ((ref ActionPhysicsSystem)self).init()
  
  self.world.worldSetGravity(0, 0, 0)

method process*(self: ref SandboxPhysicsSystem, message: ref SystemReadyMessage) =
  # We want to reset our scene when physics system is ready.
  new(ResetSceneMessage).send(self)

method process*(self: ref SandboxPhysicsSystem, message: ref ResetSceneMessage) =
  logging.debug "Resetting scene"

  self.cubes = @[]

  let cubeCoords = @[
    (-1.5, 0.5, -10.0), (-0.5, 0.5, -10.0), (0.5, 0.5, -10.0), (1.5, 0.5, -10.0),
    (-1.0, 1.5, -10.0), (0.0, 1.5, -10.0), (1.0, 1.5, -10.0),
    (-0.5, 2.5, -10.0), (0.5, 2.5, -10.0),
    (0.0, 3.5, -10.0),
  ]

  var cube: Entity

  for coords in cubeCoords:
    cube = newEntity()
  #   (ref CreateEntityMessage)(entity: cube).send(config.systems.network)

    var physics = new(ActionPhysics)
    config.systems.physics.initComponent(physics)
    physics.body.bodySetPosition(coords[0], coords[1], coords[2])

    var mass = ode.dMass()
    mass.addr.massSetBoxTotal(10.0, 1.0, 1.0, 1.0)
    physics.body.bodySetMass(mass.addr)

    self.cubes.add(cube)

  #   cube[ref Physics] = physics
  #   var position = physics.body.bodyGetPosition()
  #   (ref MoveMessage)(
  #     entity: cube,
  #     x: position[][0],
  #     y: position[][1],
  #     z: position[][2],
  #   ).send(config.systems.network)

  #   # TODO: add RotateMessage

  logging.debug "Scene loaded"