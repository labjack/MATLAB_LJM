%
% Demonstrates how to read the Watchdog configuration from a LabJack using .NET.
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
    
    %Setup and call eReadNames to read the Watchdog configuration.
    numFrames = 15;
    aNames = NET.createArray('System.String', numFrames);
    aNames(1) = 'WATCHDOG_ENABLE_DEFAULT';
    aNames(2) = 'WATCHDOG_ADVANCED_DEFAULT';
    aNames(3) = 'WATCHDOG_TIMEOUT_S_DEFAULT';
    aNames(4) = 'WATCHDOG_STARTUP_DELAY_S_DEFAULT';
    aNames(5) = 'WATCHDOG_STRICT_ENABLE_DEFAULT';
    aNames(6) = 'WATCHDOG_STRICT_KEY_DEFAULT';
    aNames(7) = 'WATCHDOG_RESET_ENABLE_DEFAULT';
    aNames(8) = 'WATCHDOG_DIO_ENABLE_DEFAULT';
    aNames(9) = 'WATCHDOG_DIO_STATE_DEFAULT';
    aNames(10) = 'WATCHDOG_DIO_DIRECTION_DEFAULT';
    aNames(11) = 'WATCHDOG_DIO_INHIBIT_DEFAULT';
    aNames(12) = 'WATCHDOG_DAC0_ENABLE_DEFAULT';
    aNames(13) = 'WATCHDOG_DAC0_DEFAULT';
    aNames(14) = 'WATCHDOG_DAC1_ENABLE_DEFAULT';
    aNames(15) = 'WATCHDOG_DAC1_DEFAULT';
    aValues = NET.createArray('System.Double', numFrames);
    LabJack.LJM.eReadNames(handle, numFrames, aNames, aValues, 0);

    disp('Watchdog configuration:')
    for i=1:numFrames,
        disp(['    ' char(aNames(i)) ' : ' num2str(aValues(i))])
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
