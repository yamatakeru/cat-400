import "../../core/messages"
import "../../core/entities"
import "../../utils/stringify"


type PlayerMoveMessage* = object of Message
  ## Message for defining player's movement direction. The movement direction is relative to player's sight direction.
  yaw*: float  ## Angle (in radians) around Y axis.
  pitch*: float  ## Angle (in radians) around X axis.

messages.register(PlayerMoveMessage)
strMethod(PlayerMoveMessage)


type PlayerRotateMessage* = object of Message
  ## Message for defining player's rotation. See ``MoveMessage`` for reference.
  yaw*, pitch*: float

messages.register(PlayerRotateMessage)
strMethod(PlayerRotateMessage)


type SetPositionMessage* = object of EntityMessage
  ## Send this message to client in order to update object's position.
  x*, y*, z*: float

messages.register(SetPositionMessage)
strMethod(SetPositionMessage)
  

type SetRotationMessage* = object of EntityMessage
  ## Send this message to client in order to update object's rotation.
  yaw*: float  ## Angle (in radians) around Y axis.
  pitch*: float  # Angle (in radians) around X axis.

messages.register(SetRotationMessage)
strMethod(SetRotationMessage)
