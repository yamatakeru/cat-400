# systems/video.nim
import logging
import os  # required for `/` proc
import tables
import math

import c4/entities
import c4/systems
import c4/systems/video/ogre
# in order to use ogre bindings like `self.resourceManager.addResourceLocation`, we have to import `c4/lib/ogre/ogre` module; to avoid name clash with `c4/systems/video/ogre`, we use `import ... as ...`
import c4/lib/ogre/ogre as ogre_lib

type CustomVideoSystem* = object of VideoSystem


method init(self: ref CustomVideoSystem) =
  # call base method, which will perform default initialization
  procCall self.as(ref VideoSystem).init()

  # write something to ensure custom `init()` is called
  logging.debug "Initializing custom video system"

  logging.debug "Loading custom video resources"

  self.resourceManager.addResourceLocation(defaultMediaDir / "packs" / "SdkTrays.zip", "Zip", resGroup="Essential")
  self.resourceManager.addResourceLocation(defaultMediaDir, "FileSystem", resGroup="General")
  self.resourceManager.addResourceLocation(defaultMediaDir / "models", "FileSystem", resGroup="General")
  self.resourceManager.addResourceLocation(defaultMediaDir / "materials" / "scripts", "FileSystem", resGroup="General")
  self.resourceManager.addResourceLocation(defaultMediaDir / "materials" / "textures", "FileSystem", resGroup="General")
  self.resourceManager.initialiseAllResourceGroups()

  self.sceneManager.setAmbientLight(initColourValue(0.5, 0.5, 0.5))

  let light = self.sceneManager.createLight("MainLight")
  light.setPosition(20.0, 80.0, 50.0)

type
  CustomVideo* = object of Video


method attach(self: ref CustomVideo) =
  procCall self.as(ref Video).attach()
  let videoSystem = systems.get("video").as(ref CustomVideoSystem)
  let entity = videoSystem.sceneManager.createEntity("ogrehead.mesh")
  self.node.attachObject(entity)

  let line = videoSystem.sceneManager.createManualObject()
  line[].begin("BaseWhiteNoLighting", OT_LINE_LIST)
  # x line
  line[].position(0, 0, 0)
  line[].position(200, 0, 0)
  # y line
  line[].position(0, 0, 0)
  line[].position(0, 100, 0)
  discard line[].end()

  self.node.attachObject(line)

method process(self: ref CustomVideoSystem, message: ref SystemReadyMessage) =
  let ogre = newEntity()
  ogre[ref Video] = new(CustomVideo)
  ogre[ref Video].node.setPosition(0, -20, -300.0)

method update(self: ref CustomVideoSystem, dt: float) =
  const speed = PI  # rotate PI per second
  let angle = speed * dt
  for video in getComponents(ref Video).values:
    video.node.yaw(initRadian(angle))

  procCall self.as(ref VideoSystem).update(dt)
