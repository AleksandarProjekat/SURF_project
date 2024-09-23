library ieee;
use ieee.std_logic_1164.all;

package ip_pkg is
    type state_type is (
        idle, StartLoop, InnerLoop, 
        ComputeRPos1, ComputeRPos2, ComputeRPos3, ComputeRPos4, ComputeRPos5,           
        SetRXandCX, BoundaryCheck, ComputePosition, ProcessSample,
        ComputeDerivatives,
        WaitForData1, WaitForData2, WaitForData3, WaitForData4,
        WaitForData5, WaitForData6, WaitForData7, WaitForData8,
        WaitForData9, WaitForData10, WaitForData11, WaitForData12,
        WaitForData13, WaitForData14, WaitForData15, WaitForData16,
        FetchDXX1_1, FetchDXX1_2, FetchDXX1_3, FetchDXX1_4, ComputeDXX1,
        FetchDXX2_1, FetchDXX2_2, FetchDXX2_3, FetchDXX2_4, ComputeDXX2, 
        FetchDYY1_1, FetchDYY1_2, FetchDYY1_3, FetchDYY1_4, ComputeDYY1,
        FetchDYY2_1, FetchDYY2_2, FetchDYY2_3, FetchDYY2_4, ComputeDYY2, 
        CalculateDerivatives, ApplyOrientationTransform_1, ApplyOrientationTransform,
        SetOrientations, UpdateIndex, ComputeFractionalComponents, ValidateRfrac, ValidateCfrac,
        ComputeWeightsR, ComputeWeightsC, UpdateIndexArray0, UpdateIndexArray1,
        NextSample, IncrementI, Finish
    );

    -- Deklaracija funkcije
    --function state_to_string(state: state_type) return string;

end ip_pkg;

