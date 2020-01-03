import tables

import c4/threads
import c4/systems/physics/simple
import c4/entities

import ../messages


const
  movementQuant* = 0.02
  paddleMovementSpeed* = 0.5

type
  PhysicsSystem* = object of SimplePhysicsSystem
    ball*: Entity
    paddles*: array[2, Entity]
    gates*: array[2, Entity]
    walls*: seq[Entity]

  Physics* = object of SimplePhysics
    movementRemains*: float


method init*(self: ref PhysicsSystem) =
  # ball
  self.ball = newEntity()
  self.ball[ref Physics] = (ref Physics)(position: (x: 0.5, y: 0.5), width: 0.01, height: 0.01)

  # paddles
  self.paddles[0] = newEntity()
  self.paddles[0][ref Physics] = (ref Physics)(position: (x: 0.5, y: 0.05), width: 0.25, height: 0.01)
  self.paddles[1] = newEntity()
  self.paddles[1][ref Physics] = (ref Physics)(position: (x: 0.5, y: 0.95), width: 0.25, height: 0.01)

  # gates
  self.gates[0] = newEntity()
  self.gates[0][ref Physics] = (ref Physics)(position: (x: 0.5, y: 0.0), width: 1.0, height: 0.02)
  self.gates[1] = newEntity()
  self.gates[1][ref Physics] = (ref Physics)(position: (x: 0.5, y: 1.0), width: 1.0, height: 0.02)

  # walls
  let leftWall = newEntity()
  leftWall[ref Physics] = (ref Physics)(position: (x: 0.0, y: 0.5), width: 0.02, height: 1.0)
  self.walls.add(leftWall)

  let rightWall = newEntity()
  rightWall[ref Physics] = (ref Physics)(position: (x: 1.0, y: 0.5), width: 0.02, height: 1.0)
  self.walls.add(rightWall)

method update*(self: ref PhysicsSystem, dt: float) =
  for entity, physics in getComponents(ref Physics):
    physics.update(dt)

    physics.movementRemains -= dt
    if physics.movementRemains < 0:
      physics.movementRemains = 0
      physics.speed = (x: 0.0, y: 0.0)

    if physics.position != physics.previousPosition:
      (ref SetPositionMessage)(
        entity: entity,
        x: physics.position.x,
        y: physics.position.y,
      ).send("network")
