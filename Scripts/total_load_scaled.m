% Load the data from the Excel file
data = readtable('Load_data_total.xlsx');

% Extract timestamps, P_TOT, and Q_TOT
timestamps = data.index; % Original timestamps in seconds since epoch
p_tot = data.P_TOT_SUM;      % Active power
q_tot = data.Q_TOT_SUM;      % Reactive power

% Convert timestamps to a relative time vector (seconds from the start)
time_relative = seconds(datetime(timestamps, 'ConvertFrom', 'posixtime') - datetime(timestamps(1), 'ConvertFrom', 'posixtime'));

% Define the target time range (0 to 4 seconds) with points matching PV_Generation and SOC
n_points_target = 40001; % Match the size of PV_Generation and SOC
dense_time = linspace(0, 4, n_points_target)'; % 40001 points from 0 to 4 seconds

% Scale the original time to the new range (0 to 4 seconds)
scaled_time = (time_relative / max(time_relative)) * 4;

% Verify lengths before interpolation
if length(scaled_time) ~= length(p_tot) || length(scaled_time) ~= length(q_tot)
    error('Scaled time and power vectors have different lengths.');
end

% Interpolate P_TOT and Q_TOT to the dense time grid using spline interpolation
dense_p_tot = interp1(scaled_time, p_tot, dense_time, 'spline');
dense_q_tot = interp1(scaled_time, q_tot, dense_time, 'spline');

% Ensure non-negative values if applicable (optional, depending on context)
% dense_p_tot = max(0, dense_p_tot); % Uncomment if P_TOT should be non-negative
% dense_q_tot = max(0, dense_q_tot); % Uncomment if Q_TOT should be non-negative

% Create output data matrix: [time, P_TOT, Q_TOT]
output_data = [dense_time, dense_p_tot, dense_q_tot];

% Save to workspace for Simulink with a name consistent with your model
assignin('base', 'Load_Consumption_data', [dense_time, dense_p_tot]); % Match Load_Consumption format

% Display values around 1-1.5 seconds for verification
idx_dense = find(dense_time >= 1 & dense_time <= 1.5);
disp('Dense values around 1-1.5 seconds (subset):');
disp([dense_time(idx_dense(1:5:end)), dense_p_tot(idx_dense(1:5:end)), dense_q_tot(idx_dense(1:5:end))]); % Show every 5th point

% Plot original and dense data
figure;
subplot(2,1,1);
plot(scaled_time, p_tot, '-o', 'DisplayName', 'Original P_TOT');
hold on;
plot(dense_time, dense_p_tot, '-', 'DisplayName', 'Dense P_TOT');
xlabel('Time (seconds)');
ylabel('P_TOT (W)');
title('Active Power (P_TOT) with Dense Spline Interpolation (4s Duration)');
legend;
grid on;

subplot(2,1,2);
plot(scaled_time, q_tot, '-o', 'DisplayName', 'Original Q_TOT');
hold on;
plot(dense_time, dense_q_tot, '-', 'DisplayName', 'Dense Q_TOT');
xlabel('Time (seconds)');
ylabel('Q_TOT (VAR)');
title('Reactive Power (Q_TOT) with Dense Spline Interpolation (4s Duration)');
legend;
grid on;