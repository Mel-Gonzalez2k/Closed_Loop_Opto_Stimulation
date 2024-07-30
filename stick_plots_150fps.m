%upload coordinates_S structure 

coors_x = coordinates_S.x_in_mm;
contain_y_all = coordinates_S.y_in_mm;   

first_x = coors_x(1,:); 

b =[];
len = length(contain_y_all);
chosen_dist = 1:len;
for i = 1:len; 
    b {i} = first_x + i; %keep adding 1 to previous frame
end 
new_mat = cell2mat(b);
x_restruct =reshape(new_mat,[6,length(chosen_dist)]);

frame_y_time = 1/150; %150 fps 

x_restruct_time = x_restruct * frame_y_time; 
figure; 
p = plot(x_restruct_time(:,1:19), (contain_y_all(1:19,:))','k','LineStyle','-','Marker','.','MarkerSize',20); 
set(gca, 'YDir','reverse')%y axis flipped
ylabel('Height (mm)')
xlabel('Step Duration (s)')
        




















