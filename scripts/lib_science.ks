DECLARE GLOBAL FUNCTION DO_SCIENCE_BATCH {
    // Run all science experiments which don't have anything stored and keep the experiments
    PRINT "EXEC 'DO_SCIENCE_BATCH'...".

    //SET TESTS TO SHIP:PARTS.
    //FOR t IN TESTS {
        //PRINT t:NAME.
    //}.
    LOCAL LPARTS TO LEXICON().
    LPARTS:ADD("sensorThermometer", "Thermometer").
    LPARTS:ADD("sensorBarometer", "Barometer").
    LPARTS:ADD("GooExperiment", "GooExperiment").
    LPARTS:ADD("science.module", "Science Jr.").
    LOCAL i IS 0.
    FOR name IN LPARTS:KEYS {
        LOCAL friendly_name IS LPARTS[name].
        SET PARTS TO SHIP:PARTSNAMED(name).
        LOCAL found_empty_science_experiment IS FALSE.
        LOCAL count_with_data IS 0.
        LOCAL count IS 0.
        FOR part IN PARTS {
            SET count TO count + 1.
            SET M TO part:GETMODULE("ModuleScienceExperiment").
            IF NOT found_empty_science_experiment AND NOT M:HASDATA {
                SET found_empty_science_experiment TO TRUE.
                M:DEPLOY.
                WAIT UNTIL M:HASDATA.
            }.
            IF M:HASDATA {
                SET count_with_data TO count_with_data + 1.
            }.
        }.
        IF count = 0 {
            PRINT "No " + friendly_name + " parts found.".
        }
        ELSE IF NOT found_empty_science_experiment AND count_with_data > 0 {
            PRINT "No empty " + friendly_name + " parts found.".
        }
        ELSE {
            PRINT "Ran experiment on: " + friendly_name + " (" + (count - count_with_data) + " left).".
        }.
        SET i TO i + 1.
    }.
    PRINT "END 'DO_SCIENCE_BATCH'.".
}
