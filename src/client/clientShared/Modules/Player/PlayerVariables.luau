-- [General variables] --------------------------------------------------------------------------
local lcl = {}
local plrVariables = {} -- pH = PlayerHandler
-------------------------------------------------------------------------------------------------

plrVariables = {
    FOV = 90,
    WALKSPEED   = 13,
    RUN_SPEED   = 25,
    JUMP_POWER  = 40,
    JUMP_HEIGHT = 7.2,
    RUN_DUR     = 8,

    camStates ={HEAD_BOB = "headBob", IN_DIALOGUE = "inDialogue", STATE_TRANSITION = "transition"}
}

return plrVariables