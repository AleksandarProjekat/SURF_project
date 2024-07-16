package ip_pkg is
type state_type is (
idle, StartLoop, InnerLoop, 
            ComputeRPos1, ComputeRPos2, ComputeRPos3, ComputeRPos4, ComputeRPos5,
            ComputeCPos1, ComputeCPos2, ComputeCPos3, ComputeCPos4, ComputeCPos5,
            SetRXandCX, BoundaryCheck, PositionValidation, ComputePosition, ProcessSample,
        ComputeDerivatives, WaitForData,WaitForData1,
        FetchDXX1, FetchDXX2, ComputeDXX,
        FetchDYY1, FetchDYY2, ComputeDYY,
    CalculateDerivatives, ApplyOrientationTransform,
            SetOrientations, UpdateIndex, ComputeFractionalComponents, ValidateIndices, 
            ComputeWeightsR, ComputeWeightsC, UpdateIndexArray0, UpdateIndexArray1, CheckNextColumn0, CheckNextColumn1, CheckNextRow0, CheckNextRow1,
            NextSample, IncrementI, Finish
    );
    function state_to_string(state: state_type) return string;
end package ip_pkg;
package body ip_pkg is
    function state_to_string(state: state_type) return string is
    begin
        case state is
            when idle                   => return "idle";
            when StartLoop              => return "StartLoop";
            when InnerLoop              => return "InnerLoop";
            when ComputeRPos1           => return "ComputeRPos1";
            when ComputeRPos2           => return "ComputeRPos2";
            when ComputeRPos3           => return "ComputeRPos3";
            when ComputeRPos4           => return "ComputeRPos4";
            when ComputeRPos5           => return "ComputeRPos5";
            when ComputeCPos1           => return "ComputeCPos1";
            when ComputeCPos2           => return "ComputeCPos2";
            when ComputeCPos3           => return "ComputeCPos3";
            when ComputeCPos4           => return "ComputeCPos4";
            when ComputeCPos5           => return "ComputeCPos5";
            when SetRXandCX             => return "SetRXandCX";
            when BoundaryCheck          => return "BoundaryCheck";
            when PositionValidation     => return "PositionValidation";
            when ComputePosition        => return "ComputePosition";
            when ProcessSample          => return "ProcessSample";
            when ComputeDerivatives     => return "ComputeDerivatives";
            when WaitForData            => return "WaitForData";
			when WaitForData1            => return "WaitForData1";
            when FetchDXX1              => return "FetchDXX1";
            when FetchDXX2              => return "FetchDXX2";
            when ComputeDXX             => return "ComputeDXX";
            when FetchDYY1              => return "FetchDYY1";
            when FetchDYY2              => return "FetchDYY2";
            when ComputeDYY             => return "ComputeDYY";
            when CalculateDerivatives   => return "CalculateDerivatives";
            when ApplyOrientationTransform => return "ApplyOrientationTransform";
            when SetOrientations        => return "SetOrientations";
            when UpdateIndex            => return "UpdateIndex";
            when ComputeFractionalComponents => return "ComputeFractionalComponents";
            when ValidateIndices        => return "ValidateIndices";
            when ComputeWeightsR        => return "ComputeWeightsR";
            when ComputeWeightsC        => return "ComputeWeightsC";
            when UpdateIndexArray0       => return "UpdateIndexArray0";
			when UpdateIndexArray1       => return "UpdateIndexArray1";
            when CheckNextColumn0        => return "CheckNextColumn0";
			when CheckNextColumn1        => return "CheckNextColumn1";
            when CheckNextRow0           => return "CheckNextRow0";
			when CheckNextRow1           => return "CheckNextRow1";
            when NextSample             => return "NextSample";
            when IncrementI             => return "IncrementI";
            when Finish                 => return "Finish";
            when others                 => return "unknown state";
        end case;
    end function state_to_string;
end package body ip_pkg;
