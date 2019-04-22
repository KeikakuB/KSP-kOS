DECLARE FUNCTION EXECUTE_MANEUVER_NODE {
    // Execute the next maneuver node.
    LOCAL ND IS NEXTNODE.

    //print out node's basic parameters - ETA and deltaV
    PRINT "Node in: " + ROUND(ND:ETA) + ", deltaV: " + ROUND(ND:DELTAV:MAG).

    //calculate ship's max acceleration
    LOCAL MAX_ACC IS SHIP:MAXTHRUST/SHIP:MASS.

    // Now we just need to divide deltav:mag by our ship's max acceleration
    // to get the estimated time of the burn.
    // TODO use Tsiolkovsky rocket equation for more precise calculation
    LOCAL BURN_DURATION IS ND:DELTAV:MAG/MAX_ACC.
    PRINT "Crude Estimated burn duration: " + ROUND(BURN_DURATION) + "s".

    WAIT UNTIL ND:ETA <= (BURN_DURATION/2 + 60).

    LOCAL NP IS ND:DELTAV. 
    //points to node, don't care about the roll direction.
    LOCK STEERING TO NP.

    //now we need to wait until the burn vector and ship's facing are aligned
    WAIT UNTIL VANG(NP, SHIP:FACING:VECTOR) < 0.25.

    //the ship is facing the right direction, let's wait for our burn time
    WAIT UNTIL ND:ETA <= (BURN_DURATION/2).

    LOCAL TSET IS 0.
    LOCK THROTTLE TO TSET.

    LOCAL IS_DONE IS FALSE.
    //initial deltav
    LOCAL DV0 IS ND:DELTAV.
    UNTIL IS_DONE
    {
        //recalculate current max_acceleration, as it changes while we burn through fuel
        SET MAX_ACC TO SHIP:MAXTHRUST/SHIP:MASS.

        //throttle is 100% until there is less than 1 second of time left to burn
        //when there is less than 1 second - decrease the throttle linearly
        SET TSET TO MIN(ND:DELTAV:MAG/MAX_ACC, 1).

        //here's the tricky part, we need to cut the throttle as soon as our nd:deltav and initial deltav start facing opposite directions
        //this check is done via checking the dot product of those 2 vectors
        IF VDOT(DV0, ND:DELTAV) < 0
        {
            PRINT "End burn, remain dv " + ROUND(ND:DELTAV:MAG,1) + "m/s, vdot: " + ROUND(VDOT(DV0, ND:DELTAV),1).
            LOCK THROTTLE TO 0.
            BREAK.
        }

        //we have very little left to burn, less then 0.1m/s
        if nd:deltav:mag < 0.1
        {
            PRINT "Finalizing burn, remain dv " + ROUND(ND:DELTAV:MAG,1) + "m/s, vdot: " + ROUND(VDOT(DV0, ND:DELTAV),1).
            //we burn slowly until our node vector starts to drift significantly from initial vector
            //this usually means we are on point
            WAIT UNTIL VDOT(DV0, ND:DELTAV) < 0.5.

            LOCK THROTTLE TO 0.
            PRINT "End burn, remain dv " + ROUND(ND:DELTAV:MAG,1) + "m/s, vdot: " + ROUND(VDOT(DV0, ND:DELTAV),1).
            SET IS_DONE TO TRUE.
        }
    }
    UNLOCK STEERING.
    UNLOCK THROTTLE.
    WAIT 1.

    //we no longer need the maneuver node
    REMOVE ND.
}
