%
% Demonstrates thermocouple configuration and measurement using the
% LJTick-InAmp and TCVoltsToTemp. This example is for devices such as
% the T4 that do not support built-in amplification and the thermocouple
% AIN_EF. For devices that support the thermocouple AIN_EF, such as the T7
% and T8, see 'ThermocoupleExampleAINEF' instead.
%
% support@labjack.com
%

clc  % Clear the MATLAB command window
clear  % Clear the MATLAB variables

% Make the LJM .NET assembly visible in MATLAB
ljmAsm = NET.addAssembly('LabJack.LJM');

% Creating an object to nested class LabJack.LJM.CONSTANTS
t = ljmAsm.AssemblyHandle.GetType('LabJack.LJM+CONSTANTS');
LJM_CONSTANTS = System.Activator.CreateInstance(t);

handle = 0;

try
    % Open first found LabJack

    % Any device, Any connection, Any identifier
    [ljmError, handle] = LabJack.LJM.OpenS('ANY', 'ANY', 'ANY', handle);

    % T8 device, Any connection, Any identifier
    % [ljmError, handle] = LabJack.LJM.OpenS('T8', 'ANY', 'ANY', handle);

    % T7 device, Any connection, Any identifier
    % [ljmError, handle] = LabJack.LJM.OpenS('T7', 'ANY', 'ANY', handle);

    % T4 device, Any connection, Any identifier
    % [ljmError, handle] = LabJack.LJM.OpenS('T4', 'ANY', 'ANY', handle);

    % Any device, Any connection, Any identifier
    % [ljmError, handle] = LabJack.LJM.Open(LJM_CONSTANTS.dtANY, ...
    %     LJM_CONSTANTS.ctANY, 'ANY', handle);

    showDeviceInfo(handle);
    devType = getDeviceType(handle);


    % Configure a thermocouple measurement on AIN6
    ainChannel = 6;

    % Supported thermocouple types:
    % LJM_ttB (val=6001)
    % LJM_ttE (val=6002)
    % LJM_ttJ (val=6003)
    % LJM_ttK (val=6004)
    % LJM_ttN (val=6005)
    % LJM_ttR (val=6006)
    % LJM_ttS (val=6007)
    % LJM_ttT (val=6008)
    % LJM_ttC (val=6009)
    tcType = LJM_CONSTANTS.ttK;

    % Assuming an InAmp with x51 gain and 1.25 V offset is used
    inAmpOffset = 1.25;
    inAmpGain = 51;

    tempUnitConf = 0; % 0=K, 1=°C, 2=°F

    % Use the internal temp sensor for CJC
    cjcRegisterName = System.String('TEMPERATURE_DEVICE_K');
    cjcSlope = 1; % Use 55.56 for LM34
    cjcOffset = 0; % Use 255.37 for LM34

    % Call eReadNames to get the InAmp output voltage and CJC sensor.
    numFrames = 2;
    aNames = NET.createArray('System.String', numFrames);
    aNames(1) = System.String.Format('AIN{0}', ainChannel);
    aNames(2) = cjcRegisterName;
    aValues = NET.createArray('System.Double', numFrames);
    LabJack.LJM.eReadNames(handle, numFrames, aNames, aValues, 0);
    % Convert the InAmp voltage to the raw thermocouple voltage.
    tcVolts = (aValues(1) - inAmpOffset) / inAmpGain;
    % Apply scaling to the CJC reading if necessary.
    % At this point, the reading must be in units Kelvin.
    cjcTempK = aValues(2)*cjcSlope + cjcOffset;
    % Convert voltage to the thermocouple temperature.
    [ljmError, tcTempK] = LabJack.LJM.TCVoltsToTemp(tcType, ...
                                                    tcVolts, ...
                                                    cjcTempK, ...
                                                    0);
    disp(' ');
    disp(['TC Temp: ' num2str(tcTempK) ' K']);
    disp(['TC Volts: ' num2str(tcVolts,'%.6f') ' V']);
    disp(['CJC Temp: ' num2str(cjcTempK) ' K']);
catch e
    showErrorMessage(e)
    LabJack.LJM.CloseAll();
    return
end

try
    % Close handle
    LabJack.LJM.Close(handle);
catch e
    showErrorMessage(e)
end
