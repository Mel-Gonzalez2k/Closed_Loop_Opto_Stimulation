function [toe_height_mean, heights_by_cycle_norm, baseline_trace, idx_stim] = plot_indiv_traces(exp_name, animal_name)
%plot_indiv_heights_WIP('completed_skeleton','EN1_M_2.2_midstance')

[~,txt,raw] =xlsread('N:\Undergrads\Mel\DLC_Live_Project\Video_final_analysis\DLC_Live_Video_Info.xlsx');
titles = txt(1,1:size(txt,2));
video_column = find(strcmp(titles, 'mouse_phase_num'));
all_videos = txt(:,video_column);
video_row = find(contains(all_videos, animal_name));
all_stims =raw(:,find(strcmp(titles, 'Calculate_stim')));
idx_stim = all_stims(video_row);

accum_length = 0;
trans_inds(1) = 0;
 for i = 1:length(video_row)
    mouse_name = raw{video_row(i),strncmp(titles, 'mouse_phase_num',16)};
    video_path = ['N:\Undergrads\Mel\DLC_Live_Project\Video_final_analysis\' exp_name '\' mouse_name];
    load([video_path '\coordinates_S.mat']);
    

    curr_pixels_x = coordinates_S.x_in_mm; %change back to _mm or _pixel
    curr_pixels_y = coordinates_S.y_in_mm; %change back to _mm or _pixel
       
     for j = 2:size(curr_pixels_x,2)-1
        curr_b = [curr_pixels_y(:,j+1)*1]; 
        for k = 1:size(curr_pixels_x,1)
           heights_cell{i}(k,j-1) = [curr_b(k,:)]; 
        end
    end
    
%   stance and swing frames of all videos from the same animal are combined
    stance_inds{i} = (coordinates_S.stance_inds + accum_length)';
    swing_inds{i}= (coordinates_S.swing_inds +accum_length)';
    Num_Step_Cycles(i) =  length(coordinates_S.stance_inds)-1;
    max_step_dur(i)= max(diff(coordinates_S.stance_inds))+1;
    accum_length =  size(curr_pixels_y,1)+accum_length;
    trans_inds(i+1)= length(stance_inds{i})+trans_inds(i);
end

% combine heights from all videos of animal
heights_mat = cat(1,heights_cell{:});
stance_inds_mat = cell2mat(stance_inds);
swing_inds_mat = cell2mat(swing_inds);
tot_Num_Step_Cycles = sum(Num_Step_Cycles);
tot_max_step_dur = max(max_step_dur);
trans_inds = trans_inds(~(trans_inds==0));

% sort heights by step cycles 
heights_by_cycle = nan(size(heights_mat,2),length(stance_inds_mat)-1,tot_max_step_dur);
percent_of_step = nan(size(heights_mat,2),length(stance_inds_mat)-1,tot_max_step_dur);

for l=1:size(heights_mat,2)
     for i= 1:length(stance_inds_mat)-1
        curr_step_cycle = stance_inds_mat(i):stance_inds_mat(i+1);
        curr_step_cycle_size = length(curr_step_cycle);
        if sum(i==trans_inds)>0 
            heights_by_cycle(l,i,:)=nan;
            swing_ind_norm(l,i) = nan;
%             stance_ind_norm(l,i) = nan;
        else
            curr_swing= swing_inds_mat(swing_inds_mat< curr_step_cycle(end)& swing_inds_mat> curr_step_cycle(1));
            heights_by_cycle(l,i,1:curr_step_cycle_size) = heights_mat(curr_step_cycle,l);    
            percent_of_step(l,i,1:curr_step_cycle_size) = 0:1/(curr_step_cycle_size-1):1;
            swing_ind_per_cycle(l,i) = curr_swing-curr_step_cycle(1)+1;
            swing_ind_norm(l,i) = percent_of_step(l,i,swing_ind_per_cycle(l,i));
        end
    end
end
% calculate the normalize transition to swing for each normalized step cycle
 swing_ind_norm =  swing_ind_norm(1,:);
 swing_ind_norm(swing_ind_norm==0)=nan;
 mean_swing_norm = nanmean(swing_ind_norm);
 swing_ind_per_cycle =  swing_ind_per_cycle(1,:);
 swing_ind_per_cycle(swing_ind_per_cycle==0)=nan;
 
x_norm = 0:0.01:1;% normalize each step cycle to 0-1 
for i = 1:size(heights_by_cycle,1)
    for j = 1:size(heights_by_cycle,2)
          curr_size = sum(~isnan(heights_by_cycle(i,j,:)));
          if curr_size==0
              heights_by_cycle_norm(i,j,:) =nan;
          else
            for k = 1:length(x_norm)
                [~,curr_ind] = find(percent_of_step(i,j,:)==x_norm(k));
                if curr_ind
                   heights_by_cycle_norm(i,j,k) =  heights_by_cycle(i,j,curr_ind);
                else
                   heights_by_cycle_norm(i,j,k) = interp1(squeeze(percent_of_step(i,j,1:curr_size)),squeeze(heights_by_cycle(i,j,1:curr_size)),x_norm(k));
                end
            end
          end
    end
end

% calculate the mean height throughout the step cycle
mean_height = squeeze(nanmean(heights_by_cycle_norm,2));
std_height = squeeze(nanstd(heights_by_cycle_norm,[],2));
toe_height_mean = mean_height(4,:);

indiv_traces = squeeze(heights_by_cycle_norm(4, :, :));
M = max(indiv_traces,[],"all");
baseline_trace = M - indiv_traces; 

%stimulations BREAKPOINT HEREE*******************************************
all_stims =raw(:,find(strcmp(titles, 'Calculate_stim')));
idx_stim = cell2mat(all_stims(video_row));
mean_stim = mean(idx_stim);
std_stim = std(idx_stim);
sem_stim = std_stim/sqrt(length(idx_stim));

%calculate max heights***************************************************
clean_swing = swing_ind_norm(~isnan(swing_ind_norm));
clean_traces = baseline_trace(1:2:end,:);
[maxValues, maxIndices] = max(clean_traces, [], 2);


figure
% plot(x_norm, baseline_trace);
h = plot(x_norm, baseline_trace);
legend(h(1:2:j)); %j is # of steps with nan in between
hold on
% xline(mean_stim, 'b', 'LineWidth', 1);
% xline(mean_stim + sem_stim , 'b--', 'Alpha', .6)
% xline(mean_stim - sem_stim , 'b--') 
xticks([0 1])
xlabel('Step cycle duration')
ylim([0 12])
ylabel('Toe height (mm)')
title([animal_name ' paw withdrawl height'])

end 