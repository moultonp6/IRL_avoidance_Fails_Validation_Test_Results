% Draw single objectworld with specified reward function.
function obstacle_draw(reward,example_samples,test_samples,mdp_params,mdp_data,paper_quality)

if nargin < 6
    paper_quality = 0;
end

% Initialize window.'states',states,'states',states,
if paper_quality
    VMARGIN = 0.4;
    HMARGIN = 0.4;
else
    VMARGIN = 1.0;
    HMARGIN = 1.0;
end
margin_wsp_low = 2.2;
margin_wsp_high = 7.5;
% axis([-HMARGIN  mdp_data.bounds(1)+HMARGIN  -VMARGIN  mdp_data.bounds(2)+VMARGIN]);
axis([-HMARGIN  mdp_data.bounds(1)+HMARGIN  margin_wsp_low  margin_wsp_high]);
if paper_quality
    % Expand axes.
    set(gca,'position',[0 0 1 1]);
    set(gca,'color','none','xgrid','off','ygrid','off','visible','off');
    set(gca,'xtick',[]);
    set(gca,'ytick',[]);
else
%     set(gca,'xtick',0:mdp_data.bounds(1));
%     set(gca,'ytick',0:mdp_data.bounds(2));
end
daspect([1 1 1]);
hold on;

% Draw the reward function.
% Create regular samples.
STEP_SIZE = 0.05; % 0.2
% x = -HMARGIN: STEP_SIZE: (mdp_data.bounds(1)+HMARGIN);
% y = -VMARGIN: STEP_SIZE: (mdp_data.bounds(2)+VMARGIN);
x = -HMARGIN: STEP_SIZE: (mdp_data.bounds(1)+HMARGIN);
y = margin_wsp_low-0.0: STEP_SIZE: (margin_wsp_high+0.0);
[X,Y] = meshgrid(x,y);
pts = [X(:) Y(:)];
R = feval(strcat(reward.type,'evalreward'),reward,mdp_data,[],zeros(size(pts,1),mdp_data.udims),pts * mdp_data.sensor_basis,[],[],[],[]);

% Convert back into image.
C = reshape(R,size(X,1),size(X,2));

% Interpolate.
C = interp2(C,4);

% Visualize.
C = C - min(min(C));
if max(max(C))~=0
	C = C/max(max(C));
    C = C*64;
	fig = image(x, y, C);
end

ylim([margin_wsp_low margin_wsp_high])

% Draw feature positions. % seems like only rbf rectangular
obstacle_drawfeature(reward,0.0,0.0,1.0,[],[]);

if strcmp(reward.type,'sum')
    max_r = -Inf;
    min_r = Inf;
    for i=1:length(reward.features)
        if strcmp(reward.features{i}.type,'rbf')
            if reward.theta(i) > max_r
                max_r = reward.theta(i);
            end
            if reward.theta(i) < min_r
                min_r = reward.theta(i);
            end
        end
    end
    rng_r = max_r-min_r;
    for i=1:length(reward.features)
        if strcmp(reward.features{i}.type,'rbf')
            c = (reward.theta(i)-min_r)/rng_r;
            w = sqrt(1.0/reward.features{i}.width);
            strt = [reward.features{i}.pos(:,1) reward.features{i}.pos(:,end)] - w;
            extn = w*2.0;'states',states,
            rectangle('Position',[strt(1) strt(2) extn extn],'Curvature',[1 1],'EdgeColor',[c c c]);
        end
    end
end

path = mdp_params.patht;

% Draw the paths.
if ~isempty(example_samples)
    % draw trajectories ... vvv
    if ~paper_quality
    for i=1:length(test_samples)
        % Collect all points in this trajectory.
        % pts = objectworldcontrol(mdp_data,test_samples{i}.s,test_samples{i}.u);
        %pts = [test_samples{i}.s; pts];
        pts = test_samples{i}.states;
        
        % comment the next line to plot successfully when we segement the
        % path into two parts
%         pts = [test_samples{i}.s; pts]; % add the starting point for drawing
        col = [0.5 0.5 0.7];
        color_list = linspace(0, 1, length(test_samples)+1);
        % Plot the points.
        if 1        % --- Changed to 1 from 0 by me to prevent plotting examples
       %             --- Deactivated by me to prevent plotting example samples
% %             plot(pts(:,1),pts(:,end),'-','color',[color_list(i),0.5,0.7],'marker','.','markersize',14,'linewidth',1.5);
        else
%             color1 = [0.4660 0.8 0.1880];
            color1 = [0, 0, 0];
            color2 = [1, 0.0, 0.0];
            sizem = 5;
            switch i
                case 1
                    plot(pts(:,1),pts(:,end),'-','color',color1,'marker','o','markersize',sizem+1,'linewidth',1.5,...
                        'MarkerFaceColor','m'); 
                case 2
                    plot(pts(:,1),pts(:,end),'-','color',color1,'marker','^','markersize',sizem,'linewidth',1.5,...
                        'MarkerFaceColor','m'); 
                case 3
                    plot(pts(:,1),pts(:,end),'-','color',color1,'marker','v','markersize',sizem,'linewidth',1.5,...
                        'MarkerFaceColor','m');    
                case 4
                    if  path(end-2:end-2) == 'a' || path(end-2:end-2) == 'c'
                        plot(pts(:,1),pts(:,end),'-','color',color1,'marker','d','markersize',sizem,'linewidth',1.5,'MarkerEdgeColor',color1,...
                            'MarkerFaceColor','m');
                    else
                        plot(pts(:,1),pts(:,end),':','color',color2,'marker','d','markersize',sizem,'linewidth',1.5,'MarkerEdgeColor',color2,...
                        'MarkerFaceColor','y');
                    end
                case 5
                    if path(end-2:end-2) == 'a' || path(end-2:end-2) == 'c'
                        plot(pts(:,1),pts(:,end),'-','color',color1,'marker','s','markersize',sizem,'linewidth',1.5,'MarkerEdgeColor',color1,...
                            'MarkerFaceColor','m');
                    else     
                        plot(pts(:,1),pts(:,end),':','color',color2,'marker','s','markersize',sizem,'linewidth',1.5,'MarkerEdgeColor',color2,...
                            'MarkerFaceColor','y');
                    end
                case 6
                    plot(pts(:,1),pts(:,end),'-','color',color2,'marker','o','markersize',sizem+1,'linewidth',1.5,...
                        'MarkerFaceColor','y'); 
                case 7
                    plot(pts(:,1),pts(:,end),'-','color',color2,'marker','^','markersize',sizem,'linewidth',1.5,...a
                        'MarkerFaceColor','y'); 
                case 8
                    plot(pts(:,1),pts(:,end),'-','color',color2,'marker','v','markersize',sizem,'linewidth',1.5,...
                        'MarkerFaceColor','y');    
                case 9
                    plot(pts(:,1),pts(:,end),'-','color',color2,'marker','d','markersize',sizem,'linewidth',1.5,'MarkerEdgeColor',color2,...
                        'MarkerFaceColor','y');
                case 10
                    plot(pts(:,1),pts(:,end),'-','color',color2,'marker','s','markersize',sizem,'linewidth',1.5,'MarkerEdgeColor',color2,...
                        'MarkerFaceColor','y');  
            end
        end
        % Plot starting point.
        %plot(pts(1,1),pts(1,end),'color',col,'marker','o','markersize',5,'linewidth',2);
        % Plot ending point.
        fig_end = plot(pts(end,1),pts(end,end),'color',col,'marker','x','markersize',10,'linewidth',2);
        set(get(get(fig_end,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
    end
    end
    
    for i=1:length(example_samples)
        % Collect all points in this trajectory.
        % pts = obstacle_control(mdp_data,example_samples{i}.s,example_samples{i}.u);
        % changed to read states directly
        pts = example_samples{i}.states;
%        pts = example_samples{i}.states_draw;
        pts = [example_samples{i}.s; pts];
        T = size(pts,1);
        col = ones(1,3)*0.0;
        % Plot the points.
        if paper_quality
            width_factor = 2;
        else
            width_factor = 1;
        end
%         this three lines are commented for ploting
%          --- Uncommented by me
        plot(pts(:,1),pts(:,end),'-','color',col,'marker','.','markersize',14*width_factor,'linewidth',1.5);

        % Plot starting point.
%         plot(pts(1,1),pts(1,end),'color',col,'marker','o','markersize',5,'linewidth',2);
        % Plot ending point.
        
%         fig = plot(pts(end,1),pts(end,end),'color',col,'marker','x','markersize',10*width_factor,'linewidth',2);
%         set(get(get(fig,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
    end
end

% legend('Computed','1','2','3','4','5','6','7','8','9','10')
% N = [0.67, 0.51, 0.83, 0.59, 0.00, 0.58, 0.30, 0.00, 0.00, ...
% 0.85];
% N = 1 - N;
% path = '/home/swei/Documents/IRL_with_dynamical_system/obstacle_wih_sample_from_dynamics/result/eight_subject/Jun_12_01/testb2/';

%%
% enable the next two lines for figure plot -- but seems like we won't need
% it anymore
% N = load([path, 'weight_input.mat']);
% N = N.weight_input;

N = length(test_samples);
%%
% ---- Commented by me to remove the legend box

% legendCell = cellstr(num2str(N', 'Weight=%-g'));
% legendCell = [legendCell; cellstr('IRL generated')];
% legend(legendCell,'FontSize',14)

x0 = 0;
y0 = 0;
width = 1080;
height = 530;
set(gcf,'position',[x0,y0,width,height])
set(gca,'xtick',[])

% my_title_pre = strcat('result/example/demo_', num2str(length(test_samples)));
% my_title_pre = strcat('result/weights_test/test_far_4_close_3/demo_', num2str(length(test_samples)));
% my_title_pre = strcat('result/eight_subject/demo_', num2str(length(test_samples)));
my_title_pree = strcat(mdp_params.folder_name, 'demo_');
my_title_pre = strcat(my_title_pree, num2str(length(test_samples)));
my_title = strcat(my_title_pre, '.jpg');
% my_title_fig = strcat(my_title_pre, '.fig');
saveas(gcf, my_title)
% savefig(my_title_fig)
% ---- Disabled by me below section----
% imgn = path(end-2:end-1);
% NNN = path(end-12:end-8);
% switch NNN
%     case '05_01'
%         NN = 1;
%     case '05_02'
%         NN = 2;
%     case '06_01'
%         NN = 3;
%     case '06_02'
%         NN = 4;
%     case '10_01'
%         NN = 5;
%     case '10_02'
%         NN = 6;
%     case '12_01'
%         NN = 7;
%     case '12_02'
%         NN = 8;
% end
% -------

% enable the next line for figure plot -- but seems like we won't need
% it anymore
% my_title_pree = strcat('result/eight_subject/plot/', 'sub_', num2str(NN), '_', imgn);
% my_title_pree = strcat('result/eight_subject/plot/', 'sub_', num2str(N), '_', imgn);

% Disabled by me : my_title_pree = strcat('result/temp', 'sub_', num2str(N), '_', imgn);
my_title_pree = strcat('result/temp', 'sub_', num2str(N), '_');

my_title = strcat(my_title_pree, '.jpg');
% my_title_fig = strcat(my_title_pree, '.fig');
saveas(gcf, my_title)
% savefig(my_title_fig)

% Finished.
hold off;
