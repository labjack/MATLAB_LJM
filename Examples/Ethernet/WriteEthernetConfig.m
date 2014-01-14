%
% Demonstrates how to set ethernet configuration settings on a LabJack using
% .NET.
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
    
    %Setup and call eWriteNames to set the ethernet configuration.
    numFrames = 4;
    aNames = NET.createArray('System.String', numFrames);
    aNames(1) = 'ETHERNET_IP_DEFAULT';
    aNames(2) = 'ETHERNET_SUBNET_DEFAULT';
    aNames(3) = 'ETHERNET_GATEWAY_DEFAULT';
    aNames(4) = 'ETHERNET_DHCP_ENABLE_DEFAULT';
    aValues = NET.createArray('System.Double', numFrames);
    [ljmError, aValues(1)] = LabJack.LJM.IPToNumber('192.168.1.207', 0);
    aValues(1) = typecast(int32(aValues(1)), 'uint32');
    [ljmError, aValues(2)] = LabJack.LJM.IPToNumber('255.255.255.0', 0);
    aValues(2) = typecast(int32(aValues(2)), 'uint32');
    [ljmError, aValues(3)] = LabJack.LJM.IPToNumber('192.168.1.1', 0);
    aValues(3) = typecast(int32(aValues(3)), 'uint32');
    aValues(4) = 1;
    LabJack.LJM.eWriteNames(handle, numFrames, aNames, aValues, 0);
    
    disp('Set ethernet configuration:')
    str = '';
    for i=1:numFrames,
        if isempty(strfind(char(aNames(i)), 'ETHERNET_DHCP_ENABLE_DEFAULT'))
            [ljmError, str] = LabJack.LJM.NumberToIP(typecast(uint32(aValues(i)), 'int32'), str);
            disp(['    ' char(aNames(i)) ' : ' num2str(aValues(i)) ' - ' char(str)])
        else
            disp(['    ' char(aNames(i)) ' : ' num2str(aValues(i))])
        end
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
