function height = calculate_jump_height(vGRF,sample_rate)



% Set the sample rate of the data
sample_rate = 100; % Hz

% Calculate the impulse of the vGRF
impulse = trapz(vGRF(:,2)) / sample_rate;

% Calculate the jump height using the impulse-momentum relationship
gravity = 9.81; % m/s^2
jump_height = impulse / (gravity * 2); % assuming symmetric takeoff and landing

% Display the jump height
fprintf('Jump height: %.2f meters\n', jump_height);