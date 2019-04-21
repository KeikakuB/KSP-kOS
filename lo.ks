DECLARE PARAMETER DESIRED_RADIUS IS 90000.

// Get into stable low orbit from a planet's surface.
// WARNING: Currently only tested and designed for working on KERBIN
RUN ONCE lib_launch.
RUN ONCE lib_circularize_orbit.
RUN ONCE lib_exit.

CLEARSCREEN.

LAUNCH(DESIRED_RADIUS).
CIRCULARIZE_ORBIT().
EXIT().
