[row, col] = size(data);
[Right_Turn_All, Left_Turn_All, Centered, Left05, Left10, Left15, Right05, Right10, Right15] = deal(NaN(row,col));

%Pulling out centered/left/and right turn values
for ii = 1:size(data,1)
    if data(ii,3) > data(ii,4)
        Left_Turn_All(ii,:) = data(ii,1:5);
    elseif data(ii,3) < data(ii,4)
        Right_Turn_All(ii,:) = data(ii,1:5);
    elseif data(ii,3) == data(ii,4)
        Centered(ii,:) = data(ii,1:5);
    end
end

for ii = 1:size(Left_Turn_All,1)
    if Left_Turn_All(ii,4) == 5
        Left05(ii,:) = Left_Turn_All(ii,:);
    elseif Left_Turn_All(ii,4) == 10
        Left10(ii,:) = Left_Turn_All(ii,:);
    elseif Left_Turn_All(ii,4) == 15
        Left15(ii,:) = Left_Turn_All(ii,:);
    end
end


for ii = 1:size(Right_Turn_All,1)
    if Right_Turn_All(ii,3) == 5
        Right05(ii,:) = Right_Turn_All(ii,:);
    elseif Right_Turn_All(ii,3) == 10
        Right10(ii,:) = Right_Turn_All(ii,:);
    elseif Right_Turn_All(ii,3) == 15
        Right15(ii,:) = Right_Turn_All(ii,:);
    end
end

% Clearing out missing values and 0-indexing trial info
Centered = rmmissing(Centered);
Left_Turn_All = rmmissing(Left_Turn_All);
Right_Turn_All = rmmissing(Right_Turn_All);
Right05 = rmmissing(Right05);
Right10 = rmmissing(Right10);
Right15 = rmmissing(Right15);
Left05 = rmmissing(Left05);
Left10 = rmmissing(Left10);
Left15 = rmmissing(Left15);
Right05(:,1) = Right05(:,1)-1;
Right10(:,1) = Right10(:,1)-1;
Right15(:,1) = Right15(:,1)-1;
Left05(:,1) = Left05(:,1)-1;
Left10(:,1) = Left10(:,1)-1;
Left15(:,1) = Left15(:,1)-1;

% Resaving separated matrices
save('L5.mat', 'Left05');
save('L10.mat', 'Left10');
save('L15.mat', 'Left15');
save('R5.mat', 'Right05');
save('R10.mat', 'Right10');
save('R15.mat', 'Right15');
save('C.mat', 'Centered');
