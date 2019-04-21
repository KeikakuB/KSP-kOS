DECLARE GLOBAL FUNCTION EXIT {
    PRINT "EXEC 'EXIT'...".
    UNLOCK STEERING.
    UNLOCK THROTTLE.

    //This sets the user's throttle setting to zero to prevent the throttle
    //from returning to the position it was at before the script was run.
    SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
    PRINT "END 'EXIT'.".
}.
