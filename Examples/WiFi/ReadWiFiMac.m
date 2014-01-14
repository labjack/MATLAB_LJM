%
% Demonstrates how to read the WiFi MAC from a LabJack using .NET.
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
    %[ljmerror, handle] = LabJack.LJM.Open(LJM_CONSTANTS.dtANY, LJM_CONSTANTS.ctANY, 'ANY', handle);
    
    showDeviceInfo(handle);
    
    %Call eAddresses to read the WiFi MAC. Note that we are reading a byte array
    %which is the big endian binary representation of the 64-bit MAC.
    numFrames = 1;
    aAddresses = NET.createArray('System.Int32', numFrames);
    aAddresses(1) = 60024;
    aTypes = NET.createArray('System.Int32', numFrames);
    aTypes(1) = LJM_CONSTANTS.BYTE;
    aWrites = NET.createArray('System.Int32', numFrames);
    aWrites(1) = LJM_CONSTANTS.READ;
    aNumValues = NET.createArray('System.Int32', numFrames);
    aNumValues(1) = 8;
    aValues = NET.createArray('System.Double', aNumValues(1));
    LabJack.LJM.eAddresses(handle, numFrames, aAddresses, aTypes, aWrites, aNumValues, aValues, 0);
    
    %Convert returned values to bytes 
    macBytes = uint8(aValues);
    
    %Convert big endian byte array to a 64-bit signed integer value
    [computerType, maxSize, endian] = computer;
    if endian == 'L'
        macBytes = macBytes(end:-1:1);
    end
    macNumber = typecast(macBytes, 'int64');
    
    %Convert the MAC value/number to its string representation
    macString = '';
    [ljmError, macString] = LabJack.LJM.NumberToMAC(macNumber, macString);
    
    disp(['WiFi MAC : ' num2str(macNumber) ' - ' char(macString)])
catch e
    showErrorMessage(e)
end

try
    % Close handle
    LabJack.LJM.Close(handle);
catch e
    showErrorMessage(e)
end
