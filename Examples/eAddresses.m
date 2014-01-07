%
% Demonstrates how to use the eAddresses (LJM_eAddresses) function using .NET.
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
    [ljmError, handle] = LabJack.LJM.OpenS('ANY', 'ANY', 'ANY', handle);
    %[ljmError, handle] = LabJack.LJM.Open(LJM_CONSTANTS.dtANY, LJM_CONSTANTS.ctANY, 'ANY', handle);
    
    showDeviceInfo(handle);

    %Setup and call eAddresses to write/read values.
    numFrames = 3;
    aAddresses = NET.createArray('System.Int32', numFrames);
    aAddresses(1) = 1000; %DAC0
    aAddresses(2) = 55110; %TEST_UINT16
    aAddresses(3) = 55110; %TEST_UINT16
    aTypes = NET.createArray('System.Int32', numFrames);
    aTypes(1) = LJM_CONSTANTS.FLOAT32;
    aTypes(2) = LJM_CONSTANTS.UINT16;
    aTypes(3) = LJM_CONSTANTS.UINT16;
    aWrites = NET.createArray('System.Int32', numFrames);
    aWrites(1) = LJM_CONSTANTS.WRITE;
    aWrites(2) = LJM_CONSTANTS.WRITE;
    aWrites(3) = LJM_CONSTANTS.READ;
    aNumValues = NET.createArray('System.Int32', numFrames);
    aNumValues(1) = 1;
    aNumValues(2) = 1;
    aNumValues(3) = 1;
    aValues = NET.createArray('System.Double', numFrames);
    aValues(1) = 2.5; %write 2.5 V
    aValues(2) = 12345; %write 12345
    aValues(3) = 0; %read
    LabJack.LJM.eAddresses(handle, numFrames, aAddresses, aTypes, aWrites, aNumValues, aValues, 0);

    disp('eAddresses results:')
    for i=1:numFrames,
        disp(['  Address: ' num2str(aAddresses(i)) ', data type: ' num2str(aTypes(i)) ', write: ' num2str(aWrites(i)) ', value: ' num2str(aValues(i))])
    end
catch e
    showErrorMessage(e)
end

try
    % Close handle
    LabJack.LJM.Close(handle);
catch e
    showErrorMessage(e)
end
