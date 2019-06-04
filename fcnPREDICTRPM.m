function [vi_int,vi_self,skewRAD,wi,...
            rotorAngINFLOW, rotorVelINFLOW,rotorvecVR, rotorRPM, rotorPx, rotorPy,...
            rotorMx, rotorMy, rotorQ,rotorCP, rotorMUinf,vi_int_total,vecINT] ...
            = fcnPREDICTRPM(flowq,flowRHO,geomNumROTORS,...
            geomNumBLADES,geomDIAMETER,rotorHUBLOCATIONS,rotorTHRUST,rotorRPM,...
            rotorAngINFLOW,rotorVelINFLOW, pitchVEHICLEdeg, vecBODY,tabLOOKUP,vecANGLST,...
            analysisROTORinterference)

%% ROTOR SPEED PREDICTION        
% This function uses flow conditions, vehicle geometry, vehicle forces and
% rotor data to determine the mutual interference velocity of each rotor (WIM)
% then using the velocity data to change the rotor inflow conditions to 
% determine a more accurate RPM required for each rotor to maintain a given thrust.

% Initialize for convergence
%     count=0;    % start counter to record number of error iterations until convergence is reached


    error=repmat(10000,1,1,geomNumROTORS);   % initialize error value to be above convergence value and 
    errorsum = sum(abs(error));

    vecFREE = repmat(sqrt(flowq/(flowRHO*0.5)),1,1, geomNumROTORS);
    vecPITCHdeg = repmat(pitchVEHICLEdeg,1,1, geomNumROTORS);    

    count = 0;

while errorsum(end) > 0.000001

    count = count +1;

% Interference velocity prediction
    % vi_int has 3 components (x,y,z) that are generated by WIM model
    % only z-component of vi_int is used in the RPMupdate function
    
    if analysisROTORinterference == 1
        [vi_int,vi_self,skewRAD,wi] ...
            = fcnWIM(flowRHO,geomNumROTORS,geomNumBLADES,geomDIAMETER,...
            rotorHUBLOCATIONS,rotorTHRUST,rotorRPM,vecPITCHdeg,vecFREE);

    elseif analysisROTORinterference ==0
     
         [vi_int,vi_self,skewRAD,wi] ...
            = fcnWIM(flowRHO,geomNumROTORS,geomNumBLADES,geomDIAMETER,...
            rotorHUBLOCATIONS,rotorTHRUST,rotorRPM,vecPITCHdeg,vecFREE);   
     
          vi_int = zeros(1,3,geomNumROTORS);
    
    end
% Rotor speed update - Inflow velocity and angle prediction
    [rotorAngINFLOW, rotorVelINFLOW, rotorvecVR, vecINT, vecBODY, rotorRPM_new, ...
    rotorPx, rotorPy, rotorMx, rotorMy, rotorQ, rotorCP, ...
    rotorMUinf] ...
        = fcnRPMUPDATE(flowq, flowRHO, vi_int(:,3,:), geomNumROTORS, rotorTHRUST,...
        pitchVEHICLEdeg, vecBODY, tabLOOKUP, vecANGLST, geomDIAMETER);
  
    vi_int_total = vecINT + vecBODY;
    vi_int_total = reshape(vi_int_total,[1 3 geomNumROTORS]);
    
    error                   = rotorRPM_new-rotorRPM;
    errorsum                  = sum(abs(error));
        
    rotorRPM                = rotorRPM_new; % rpm reassign to final variable/variable used in next loop

    
end

end