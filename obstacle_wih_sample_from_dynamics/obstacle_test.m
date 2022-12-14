% Run example tests on objectworld with fixed "flower petal" reward.
function [rho, sf] = obstacle_test(a, s, r, example_optimal, test_file_name, ...
    example_human, weight_input, folderName, patht)
% two_examples --- example_optimal
two_obstacles = 0;
% 4 algorithm, 5 tests, 8 restarts

algorithms = {'ame','gpirl'};
algorithm_params = {struct(),struct(),struct(),struct()};
fprintf(1,'Starting run %i %i %i\n',a,s,r);

% Set up constants.
test_metric_names = metricnames();
test_params = struct(...
        'training_sample_lengths',700,...
        'training_samples',8,...
        'test_samples',0,...
        'example_restarts',1,...
        'test_restarts',1,...
        'example_optimal',example_optimal,...
        'example_recompute_optimal',example_optimal,...
        'test_optimal',0,...
        'cells_state',30,...
        'cells_action',10,...
        'verbosity',4);
restarts = 8;
world = 'obstacle_';

% Obstacle
obs_params = {};
obs_params.x0 = [0; 4.2];
obs_params.xT = [];
obs_params.fn_handle = @move_constant_v;

% obs{1}.a = [1.2 1.2;0.4 1];
%obs{1}.a = [1;1];
% obs{1}.a = [1.2; 1.44];
obs{1}.a = [1.25; 1.5];

% obs{1}.a = [1.4; 1.68];
obs{1}.a = [1.344; 1.6128];
% 1.15 1.42 [1.2; 1.44 (the optimal trajectory is a bit small)]
% [1.06; 1.27]; the optimal trajectory is bit high in real test
% [1.2; 1.44 ]; still a bit high
% obs{1}.a = [1.3; 1.56];

% obs{1}.p = [2 1;1 1];
obs{1}.p = [1;1];
% obs{1}.partition = [-pi 0;0 pi];
obs{1}.partition = [-pi, pi];
obs{1}.sf = [1.2;1.2]; % the safety factor
obs{1}.th_r = 0*pi/180;
obs{1}.rho = 1;
% opt_sim.dt = 0.025; %integration time steps
opt_sim.dt = 1; % set to 1 ...
opt_sim.i_max = 10; %maximum number of iterations
opt_sim.tol = 0.05; %convergence tolerance
opt_sim.plot = true; %enabling the animation
opt_sim.obstacle = []; %no obstacle is defined
% obs{1}.x0 = [5; 3.8];%4
% obs{1}.x0 = [5; 4.15];
obs{1}.x0 = [5.2; 3.6];   % -- Deactivated by me

% obs{1}.x0 = [5.2; 3.6];     % My code replacing above line

obs{1}.tailEffect = false; % the tail effect is turned off..

if two_obstacles
    %obs{1}.a = [1.5; 2.8];
    %obs{1}.a = [1.0; 3.8];
    obs{1}.a = [1.1; 1.4];
    %obs{1}.x0 = [2.95; 4.2 - 2.52 ];
    obs{1}.x0 = [2.95; 4.2 - 0.6 ];
    obs{1}.tailEffect = false;
    
    obs{2}.tailEffect = false;
    %obs{2}.x0 = [7.5; 4.2 + 3.3];
    obs{2}.x0 = [7.5; 4.2 + 0.6];
    obs{2}.a = obs{1}.a;
    obs{2}.p = obs{1}.p;
    obs{2}.partition = obs{1}.partition;
    obs{2}.sf = obs{1}.sf;
    obs{2}.th_r = obs{1}.th_r;
    obs{2}.rho = obs{1}.rho; 
end

opt_sim.obstacle = obs;

obs_params.opt_sim = opt_sim;

% Prepare MDP parameters.
% 'obs' stands for ... combination of RBFs
% 'cartesian' stands for ... gaussian process
mdp_cat_name = 'Examples';
mdp_param_names = {'4','8','16','32','64'};
mdp_params = {struct('sensors',2,...
                     'motors',2,...
                     'seed',0,...
                     'fixed_pattern',3,...
                     'feature_type','obs',... 'cartesian' grid simple 'obs' - EBFs
                     'obs_params', obs_params,...
                     'rbf_features',2,...
                     'feature_radius',0.5,...
                     'centers', [0.5 0.4])}; % change to the pattern I defined.
if two_obstacles
    mdp_params{1}.centers = [0.2 0.4; 0.8 0.6];
    mdp_params{1}.fixed_pattern = 4;
end
mdp_params = repmat(mdp_params,1,length(mdp_param_names));

% Prepare test parameters.
test_params = {setdefaulttestparams(test_params)};
test_params = repmat(test_params,1,length(mdp_param_names));
test_params{1}.training_samples = 1;
test_params{2}.training_samples = 8;
test_params{3}.training_samples = 16;
test_params{4}.training_samples = 32;
test_params{5}.training_samples = 64;

% Set random seeds.
for step=1:length(mdp_params)
    mdp_params{step}.seed = mdp_params{step}.seed+r-1;
end

mdp_params{s}.folder_name = folderName;
if nargin > 8
    mdp_params{s}.patht = patht;
end
% Run single test.2
if nargin > 5
    test_result = runtest(algorithms{a},algorithm_params{a},...
                          world,mdp_params{s},test_params{s},...
                          example_human, weight_input); % the thrid one corresponding to the MDP
else
    test_result = runtest(algorithms{a},algorithm_params{a},...
                          world,mdp_params{s},test_params{s});
end
% Save test result and auxiliary data.
% save([test_file_name '_' num2str(a) '_' num2str(s) '_' num2str(r) '.mat'],...
%     'test_file_name','test_params','test_metric_names',...
%     'mdp_params','mdp_cat_name','mdp_param_names',...
%     'algorithms','names','colors','order','restarts','test_result');

visualize(test_result, example_human)

if nargout > 0
    uu = test_result.irl_result.example_samples{1,1}.u(1,:);
    % just avoiding the error
    % uu = [1,1];
    rho = uu(1);
    sf = uu(2);
end
