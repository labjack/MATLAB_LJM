%
% Demonstrates thermocouple configuration and measurement using the
% thermocouple AIN_EF features. This example is for devices such as
% the T7 and T8 that support built-in amplification and the thermocouple
% AIN_EF. For devices without built-in amplification, such as the T4,
% see 'ThermocoupleExampleInAmp' instead.
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

    % Configure a thermocouple measurement on AIN0
    ainChannel = 0;

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

    tempUnitConf = 0; % 0=K, 1=°C, 2=°F

    % Use an internal temp sensor for CJC
    cjcRegisterName = System.String('TEMPERATURE_DEVICE_K');
    if devType == LJM_CONSTANTS.dtT8
        % Use the TEMPERATURE# sensor associated to the AIN for CJC
        cjcRegisterName = System.String.Format('TEMPERATURE{0}', ...
                                               ainChannel);
    end
    [ljmError, cjcAddress, ~] = LabJack.LJM.NameToAddress(cjcRegisterName, ...
                                                          0, ...
                                                          0);
    cjcSlope = 1; % Use 55.56 for LM34
    cjcOffset = 0; % Use 255.37 for LM34

    % For converting LJM TC type constant to TC AIN_EF index
    % Thermocouple type:
    %               B  E  J  K  N  R  S  T  C
    TC_INDEX_LUT = [28,20,21,22,27,23,25,24,30];

    % Configure the thermocouple AIN_EF
    numFrames = 5;
    aNames = NET.createArray('System.String', numFrames);
    aNames(1) = System.String.Format('AIN{0}_EF_INDEX', ainChannel);
    aNames(2) = System.String.Format('AIN{0}_EF_CONFIG_A', ainChannel);
    aNames(3) = System.String.Format('AIN{0}_EF_CONFIG_B', ainChannel);
    aNames(4) = System.String.Format('AIN{0}_EF_CONFIG_D', ainChannel);
    aNames(5) = System.String.Format('AIN{0}_EF_CONFIG_E', ainChannel);
    aValues = NET.createArray('System.Double', numFrames);
    aValues(1) = TC_INDEX_LUT(tcType - 6001); % AIN#_EF_INDEX
    aValues(2) = tempUnitConf; % AIN#_EF_CONFIG_A
    aValues(3) = cjcAddress; % AIN#_EF_CONFIG_B
    aValues(4) = cjcSlope; % AIN#_EF_CONFIG_D
    aValues(5) = cjcOffset; % AIN#_EF_CONFIG_E
    LabJack.LJM.eWriteNames(handle, numFrames, aNames, aValues, 0);

    % Setup and call eWriteNames to configure the AIN on the LabJack.
    if devType == LJM_CONSTANTS.dtT8
        % LabJack T8 configuration

        % AIN0:
        %     Range = ±0.075 V.
        %     Resolution index = 0 (default)
        numFrames = 2;
        aNames = NET.createArray('System.String', numFrames);
        aNames(1) = System.String.Format('AIN{0}_RANGE', ainChannel);
        aNames(2) = System.String.Format('AIN{0}_RESOLUTION_INDEX', ...
                                         ainChannel);
        aValues = NET.createArray('System.Double', numFrames);
        aValues(1) = 0.075; % AIN#_RANGE
        aValues(2) = 0; % AIN#_RESOLUTION_INDEX
    else
        % LabJack T7 (or default) configuration

        % AIN0:
        %     Range = ±0.1 V.
        %     Resolution index = 0 (default)
        %     Negative Channel = 199 (Single-ended)
        %     Settling = 0 (auto)
        numFrames = 4;
        aNames = NET.createArray('System.String', numFrames);
        aNames(1) = System.String.Format('AIN{0}_RANGE', ainChannel);
        aNames(2) = System.String.Format('AIN{0}_RESOLUTION_INDEX', ...
                                         ainChannel);
        aNames(3) = System.String.Format('AIN{0}_NEGATIVE_CH', ainChannel);
        aNames(4) = System.String.Format('AIN{0}_SETTLING_US', ainChannel);
        aValues = NET.createArray('System.Double', numFrames);
        aValues(1) = 0.1; % AIN#_RANGE
        aValues(2) = 0; % AIN#_RESOLUTION_INDEX
        aValues(3) = 199; % AIN#_NEGATIVE_CH
        aValues(4) = 0; % AIN#_SETTLING_US
    end
    LabJack.LJM.eWriteNames(handle, numFrames, aNames, aValues, 0);

    % Setup and call eReadNames to read thermocouple AIN_EF values.
    numFrames = 4;
    aNames = NET.createArray('System.String', numFrames);
    aNames(1) = System.String.Format('AIN{0}_EF_READ_A', ainChannel);
    aNames(2) = System.String.Format('AIN{0}_EF_READ_B', ainChannel);
    aNames(3) = System.String.Format('AIN{0}_EF_READ_C', ainChannel);
    aNames(4) = System.String.Format('AIN{0}_EF_READ_D', ainChannel);
    aValues = NET.createArray('System.Double', numFrames);
    LabJack.LJM.eReadNames(handle, numFrames, aNames, aValues, 0);
    switch tempUnitConf
        case 0
            tempUnitStr = 'K';
        case 1
            tempUnitStr = '°C';
        case 2
            tempUnitStr = '°F';
    end
    disp(' ');
    disp(['TC Temp: ' num2str(aValues(1)) ' ' tempUnitStr]);
    disp(['TC Volts: ' num2str(aValues(2),'%.6f') ' V']);
    disp(['CJC Temp: ' num2str(aValues(3)) ' ' tempUnitStr]);
    disp(['CJC Equivalent TC Volts: ' num2str(aValues(4),'%.6f') ' V']);
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
