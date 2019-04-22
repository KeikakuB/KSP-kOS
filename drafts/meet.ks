# initially, assume that both orbits are on the same plane
# todo find target, or I guess set it up in the game? then find in code
# todo compute periods or my orbit and the target's orbit and figure out how to change our orbit to meet eventually
# todo wait until we should meet 
# todo burn twice (to transfer to the target's orbit)
PRINT "EXEC 'MEET'...".

IF NOT HASTARGET {
    PRINT "Please set the traget you are trying to meet.".
    BREAK.
}

SET T TO TARGET.

IF SHIP:Body != T:Body {
    PRINT "Target must orbiting the same body as your ship.".
    BREAK.
}


PRINT SHIP:OBT:PERIOD.
PRINT TARGET:OBT:PERIOD.
PRINT "END 'MEET'.".
