SELECT TargetSetsFormula,
    TargetRepsFormula,
    TargetWeight
FROM UserExerciseProgressionTargets
WHERE UserID = $1
    AND ExerciseID = $2;