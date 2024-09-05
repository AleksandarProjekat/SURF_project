package ip_pkg is
type state_type is (
            idle, StartLoop, InnerLoop, 
            ComputeRPos1, ComputeRPos2, ComputeRPos3, ComputeRPos4, ComputeRPos5,           
            SetRXandCX, BoundaryCheck, ComputePosition, ProcessSample,
            ComputeDerivatives,
            WaitForData1,WaitForData2,WaitForData3,WaitForData4,
            WaitForData5,WaitForData6,WaitForData7,WaitForData8,
            WaitForData9,WaitForData10,WaitForData11,WaitForData12,
            WaitForData13,WaitForData14,WaitForData15,WaitForData16,
            FetchDXX1_1, FetchDXX1_2, FetchDXX1_3, FetchDXX1_4, ComputeDXX1,
            FetchDXX2_1, FetchDXX2_2, FetchDXX2_3, FetchDXX2_4, ComputeDXX2, 
            FetchDYY1_1, FetchDYY1_2, FetchDYY1_3, FetchDYY1_4, ComputeDYY1,
            FetchDYY2_1, FetchDYY2_2, FetchDYY2_3, FetchDYY2_4, ComputeDYY2, 
        CalculateDerivatives, ApplyOrientationTransform_1, ApplyOrientationTransform,
        SetOrientations, UpdateIndex, ComputeFractionalComponents, ValidateRfrac, ValidateCfrac,
        ComputeWeightsR, ComputeWeightsC, UpdateIndexArray0, UpdateIndexArray1,
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
            when SetRXandCX             => return "SetRXandCX";
            when BoundaryCheck          => return "BoundaryCheck";
            when ComputePosition        => return "ComputePosition";
            when ProcessSample          => return "ProcessSample";
            when ComputeDerivatives     => return "ComputeDerivatives";
            when WaitForData1           => return "WaitForData1";
	        when WaitForData2           => return "WaitForData2";
	        when WaitForData3           => return "WaitForData3";
	        when WaitForData4           => return "WaitForData4";
	        when WaitForData5           => return "WaitForData5";
	        when WaitForData6           => return "WaitForData6";
	        when WaitForData7           => return "WaitForData7";
	        when WaitForData8           => return "WaitForData8";
	        when WaitForData9           => return "WaitForData9";
	        when WaitForData10          => return "WaitForData10";
	        when WaitForData11          => return "WaitForData11";
	        when WaitForData12          => return "WaitForData12";
	        when WaitForData13          => return "WaitForData13";
	        when WaitForData14          => return "WaitForData14";
	        when WaitForData15          => return "WaitForData15";
	        when WaitForData16          => return "WaitForData16";
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
			when ApplyOrientationTransform_1 => return "ApplyOrientationTransform_1";
            when ApplyOrientationTransform => return "ApplyOrientationTransform";
            when SetOrientations        => return "SetOrientations";
            when UpdateIndex            => return "UpdateIndex";
            when ComputeFractionalComponents => return "ComputeFractionalComponents";
			when ValidateRfrac        => return "ValidateRfrac";
            when ValidateCfrac        => return "ValidateCfrac";
            
            when ComputeWeightsR        => return "ComputeWeightsR";
            when ComputeWeightsC        => return "ComputeWeightsC";
            when UpdateIndexArray0       => return "UpdateIndexArray0";
			when UpdateIndexArray1       => return "UpdateIndexArray1";			
            when NextSample             => return "NextSample";
            when IncrementI             => return "IncrementI";
            when Finish                 => return "Finish";
            when others                 => return "unknown state";
        end case;
    end function state_to_string;

end package body ip_pkg;