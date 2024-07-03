package ip_pkg is
type state_type is (
    idle, StartLoop, InnerLoop, 
    ComputeRPos1, ComputeRPos2, ComputeRPos3, ComputeRPos4, ComputeRPos5,
    ComputeCPos1, ComputeCPos2, ComputeCPos3, ComputeCPos4, ComputeCPos5,
    SetRXandCX, BoundaryCheck, PositionValidation, ComputePosition, ProcessSample,
    ComputeDerivatives, WaitForData1,WaitForData2,WaitForData3,WaitForData4,
    FetchDXX1_1, FetchDXX1_2, FetchDXX1_3, FetchDXX1_4, ComputeDXX1,
    FetchDXX2_1, FetchDXX2_2, FetchDXX2_3, FetchDXX2_4, ComputeDXX2, 
    FetchDYY1_1, FetchDYY1_2, FetchDYY1_3, FetchDYY1_4, ComputeDYY1,
    FetchDYY2_1, FetchDYY2_2, FetchDYY2_3, FetchDYY2_4, ComputeDYY2, 
    CalculateDerivatives, ApplyOrientationTransform,
    SetOrientations, UpdateIndex, ComputeFractionalComponents, ValidateIndices, 
    ComputeWeightsR, ComputeWeightsC, UpdateIndexArray, CheckNextColumn, CheckNextRow,
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
            when WaitForData1            => return "WaitForData1";
	            when WaitForData2            => return "WaitForData2";
		
            when FetchDXX1_1            => return "FetchDXX1_1";
            when FetchDXX1_2            => return "FetchDXX1_2";
            when ComputeDXX1            => return "ComputeDXX1";
            when FetchDXX2_1            => return "FetchDXX2_1";
            when FetchDXX2_2            => return "FetchDXX2_2";
            when ComputeDXX2            => return "ComputeDXX2";
            when FetchDYY1_1            => return "FetchDYY1_1";
            when FetchDYY1_2            => return "FetchDYY1_2";
            when ComputeDYY1            => return "ComputeDYY1";
            when FetchDYY2_1            => return "FetchDYY2_1";
            when FetchDYY2_2            => return "FetchDYY2_2";
            when ComputeDYY2            => return "ComputeDYY2";
            when CalculateDerivatives   => return "CalculateDerivatives";
            when ApplyOrientationTransform => return "ApplyOrientationTransform";
            when SetOrientations        => return "SetOrientations";
            when UpdateIndex            => return "UpdateIndex";
            when ComputeFractionalComponents => return "ComputeFractionalComponents";
            when ValidateIndices        => return "ValidateIndices";
            when ComputeWeightsR        => return "ComputeWeightsR";
            when ComputeWeightsC        => return "ComputeWeightsC";
            when UpdateIndexArray       => return "UpdateIndexArray";
            when CheckNextColumn        => return "CheckNextColumn";
            when CheckNextRow           => return "CheckNextRow";
            when NextSample             => return "NextSample";
            when IncrementI             => return "IncrementI";
            when Finish                 => return "Finish";
            when others                 => return "unknown state";
        end case;
    end function state_to_string;

end package body ip_pkg;
