SET DESIRED_RADIUS TO 90000.
SET RADIUS_FUZZ TO 10000.
SET MAX_TURN_DEGREES TO 45.
SET MAX_TURN_ALTITUDE TO 10000.
set CLEARANCE_DELAY_IN_SECONDS to 1.
SET TIME_TO_START_CIRCULARIZING_BEFORE_APO_IN_SECONDS TO 10.

//First, we'll clear the terminal screen to make it look nice
CLEARSCREEN.

//Next, we'll lock our throttle to 100%.
SET MYTHROTTLE TO 1.0.
LOCK THROTTLE TO MYTHROTTLE.   // 1.0 is the max, 0.0 is idle.

//This is our countdown loop, which cycles from 10 to 0
PRINT "Counting down:".
FROM {local countdown is 3.} UNTIL countdown = 0 STEP {SET countdown to countdown - 1.} DO {
    PRINT "..." + countdown.
    WAIT 1. // pauses the script here for 1 second.
}

//This is a trigger that constantly checks to see if our thrust is zero.
//If it is, it will attempt to stage and then return to where the script
//left off. The PRESERVE keyword keeps the trigger active even after it
//has been triggered.
WHEN MAXTHRUST = 0 THEN {
    PRINT "Staging".
    STAGE.
    PRESERVE.
}.

//This will be our main control loop for the ascent. It will
//cycle through continuously until our apoapsis is greater
//than 100km. Each cycle, it will check each of the IF
//statements inside and perform them if their conditions
//are met

// Wait for clearance of launch pad.
WAIT CLEARANCE_DELAY_IN_SECONDS.

SET MYSTEER TO HEADING(90,90).
LOCK STEERING TO MYSTEER. // from now on we'll be able to change steering by just assigning a new value to MYSTEER
UNTIL SHIP:OBT:APOAPSIS > DESIRED_RADIUS {

    SET CURRENT_ANGLE TO 90 - ((SHIP:ALTITUDE / MAX_TURN_ALTITUDE) * MAX_TURN_DEGREES).
    IF CURRENT_ANGLE < 45 {
        SET CURRENT_ANGLE TO 45.
    }.
    SET MYSTEER TO HEADING(90,CURRENT_ANGLE).
}.
PRINT "desired apoapsis reached, cutting throttle".

SET MYTHROTTLE TO 0.
SET MYSTEER TO HEADING(90,0).

SET REACHED_APOAPSIS TO SHIP:OBT:APOAPSIS.

// Are we close to the apoapsis?
WAIT UNTIL (ETA:APOAPSIS < TIME_TO_START_CIRCULARIZING_BEFORE_APO_IN_SECONDS OR ETA:APOAPSIS > ETA:PERIAPSIS).
PRINT "Close to apoapsis, starting to circularize.".

SET MYSTEER TO HEADING(90,0).
SET MYTHROTTLE TO 1.

// Is the orbit circularized-ish?
WAIT UNTIL SHIP:OBT:APOAPSIS > REACHED_APOAPSIS + RADIUS_FUZZ.

PRINT "Orbit circularized".

SET MYTHROTTLE TO 0.
//This sets the user's throttle setting to zero to prevent the throttle
//from returning to the position it was at before the script was run.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
