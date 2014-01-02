%
% Demonstrates how to set and read a single digital state using .NET.
%
% support@labjack.com
%

clc %Clear the MATLAB command window
clear %Clear the MATLAB variables

ljmAsm = NET.addAssembly('LabJack.LJM'); %Make the LJM .NET assembly visible in MATLAB

t = ljmAsm.AssemblyHandle.GetType('LabJack.LJM+CONSTANTS');
LJM_CONSTANTS = System.Activator.CreateInstance(t); %creating an object to nested class LabJack.LJM.CONSTANTS

handle = 0;

try
    %Open first found LabJack
    [ljmError, handle] = LabJack.LJM.Open(LJM_CONSTANTS.dtANY, LJM_CONSTANTS.ctANY, 'ANY', handle);
    %[ljmError, handle] = LabJack.LJM.OpenS('ANY', 'ANY', 'ANY', handle);
    
    showDeviceInfo(handle);
    
    %Setup and call eWriteName to set the DIO state.
    name = 'FIO0';
    state = 0; %0 = output-low, 1 = output-high
    LabJack.LJM.eWriteName(handle, name, state);
    
    disp(['Set ' name ' state: ' num2str(state)])
    
    %Setup and call eReadName to read the DIO state.
    name = 'FIO1';
    state = 0;
    [ljmerror, state] = LabJack.LJM.eReadName(handle, name, state);
    
    disp([name ' state: ' num2str(state)])
catch e
    showErrorMessage(e)
end

try
    % Close handle
    LabJack.LJM.Close(handle);
catch 
    showErrorMessage(e)
end