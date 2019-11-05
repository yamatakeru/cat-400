import c4/lib/ogre/ogre as ogrelib
import c4/systems/video/ogre
import c4/utils/stringify


type
  VideoSystem* = object of ogre.VideoSystem
    playerNode*: ptr SceneNode

  Video* = object of ogre.Video


strMethod(VideoSystem, fields=false)
