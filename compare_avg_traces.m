function compare_avg_traces(ctr, exp)
exp_name = 'completed_skeleton';

for i = 1:size(ctr,1)%mean_avg_height_ctr{i},
    [toe_mm_ctr{i}, heights_by_cycle_ctr{i},base_trace_ctr{i}] =  plot_indiv_heights_swings(exp_name,ctr{i});
end
each_mean_ctr = cat(1,toe_mm_ctr{:}); %4 indiv groups of avg per mouse in mm from video

for i = 1:size(exp,1)
    [toe_mm_exp{i},heights_by_cycle_exp{i}, base_trace_exp{i}, idx_stim{i}] =  plot_indiv_heights_swings(exp_name,exp{i});
end
close all;
x_norm = 0:0.01:1; %0:1:100;

%control 
max_ctr_row = max(each_mean_ctr,[],2); %compute the largest element in each row, each row is a mouse
baseline_ctr = max_ctr_row - each_mean_ctr;  %4 indiv groups of avg per mouse in mm from ground

mean_base_ctr = mean(baseline_ctr);%avg of the 4 mice
std_base_ctr = std(baseline_ctr);%std from 4 indiv groups 
SEM_base_ctr = std_base_ctr/sqrt(size(baseline_ctr,1)); %sigma/sqrt(N = 4 mice)
%figure; plot(x_norm, baseline_ctr)

%experimental  
EN1 = toe_mm_exp(find(contains(exp,'EN1_M_2.2')));
EN3 = toe_mm_exp(find(contains(exp,'EN3_F_2.2')));
EN4 = toe_mm_exp(find(contains(exp,'EN4_F_')));
EN5 = toe_mm_exp(find(contains(exp,'EN5_M_2.2'))); 

double_EN1 = (cat(1,EN1{:}));
double_EN3 = (cat(1,EN3{:}));
double_EN4 = (cat(1,EN4{:}));
double_EN5 = (cat(1,EN5{:}));


%stimulation************************************* 
stim_EN1 = cell2mat(idx_stim(find(contains(exp,'EN1_M_2.2'))))';
stim_EN3 = cell2mat(idx_stim(find(contains(exp,'EN3_F_2.2'))))';
stim_EN4 = cell2mat(idx_stim(find(contains(exp,'EN4_F_'))))';
stim_EN5 = cell2mat(idx_stim(find(contains(exp,'EN5_M_2.2'))))';

each_mean_stim = [mean(stim_EN1); mean(stim_EN3); mean(stim_EN4); mean(stim_EN5)];
mean_stim = mean(each_mean_stim);
std_stim = std(each_mean_stim);
SEM_stim = std_stim/sqrt(size(each_mean_stim,1));

%each_mean_exp = [mean(double_EN1); double_EN3; mean(double_EN4); mean(double_EN5)];
each_mean_exp = [mean(double_EN1); mean(double_EN3); mean(double_EN4); mean(double_EN5)];

max_exp_row = max(each_mean_exp,[],2); 
baseline_exp = max_exp_row - each_mean_exp; %
figure; h = plot(x_norm, baseline_exp)
legend(h);

%check midstance graphs for EN3
EN3_baseline = max_exp_row(2) - double_EN3;
figure; h = plot(x_norm, EN3_baseline)
% legend(h);

mean_base_exp = mean(baseline_exp);
std_base_exp = std(baseline_exp);
SEM_base_exp = std_base_exp/sqrt(size(baseline_exp,1));

figure;
hold on
%sem_pos_ctr =  mean_ctr_height + sem_ctr_height;
sem_pos_ctr =  array1 + SEM_base_ctr;
sem_neg_ctr =  array1 - SEM_base_ctr;
rep_x = [x_norm, fliplr(x_norm)];
inBetween_ctr = [sem_pos_ctr, fliplr(sem_neg_ctr)];
fill(rep_x, inBetween_ctr,'k','FaceAlpha',.3,'EdgeAlpha',.3)
plot(x_norm, array1,'color','k','LineWidth', 1.5);shg
%plot([mean_swing_ctr mean_swing_ctr],[0 200],'r')

xticks([0 1])
xlabel('Step cycle duration')
ylim([0 14])
yticks([0 7 14])
ylabel('Paw withdrawal (mm)')


%plot mean height throughout cycle +-sem for experimentals
sem_pos_exp =  array2 + SEM_base_exp;
sem_neg_exp =  array2 - SEM_base_exp;
rep_x = [x_norm, fliplr(x_norm)];
inBetween_exp = [sem_pos_exp, fliplr(sem_neg_exp)];
fill(rep_x, inBetween_exp,'b','FaceAlpha',.3,'EdgeAlpha',.3)
xline(mean_stim, 'b', 'LineWidth', 1);
xline(mean_stim + SEM_stim , 'b--', 'Alpha', .6)
xline(mean_stim - SEM_stim , 'b--') 
plot(x_norm, array2,'color', 'b','LineWidth', 1.5);shg  


xticks([0 1])
xlabel('Step cycle duration')
title('Stimulation: Swing')
ylim([0 14])
yticks([0 7 14])
ylabel('Paw withdrawal (mm)')

end 
