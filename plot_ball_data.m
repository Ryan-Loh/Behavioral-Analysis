function plot_ball_data(Data)
close all;
    
    xaxis=Data.BallV_Data.VBallReshapedFor;
    yaxis=Data.BallV_Data.VBallReshapedLat;
    left=Data.Left_Turns;
    right=Data.Right_Turns;
    center=Data.Centered;
    x=input('Are turns calculated? (0 or 1)'); 
    for ii=1:size(Data.Ephys_Ball_Data,1)
        figure(1)
        hold on
        plot(cumsum(Data.Ephys_Ball_Data{ii,1}(4,:)));
        axis equal;
        title('Mouse Behavior - All Trials');
    end
    if x==true 
        for ii=1:size(Data.Left_Turns,2)
            figure(2)
            hold on
            plot(cumsum(xaxis{left(ii),1}),cumsum(yaxis{left(ii),1}), 'b')
            axis equal;
            title('Left Turn Trials');
        end

        for ii=1:size(Data.Right_Turns,2)
            figure(3)
            hold on
            plot(cumsum(xaxis{right(ii),1}),cumsum(yaxis{right(ii),1}), 'g')
            axis equal
            title('Right Turn Trials');
        end

        for ii=1:size(Data.Centered,2)
            figure(4);
            hold on
            plot(cumsum(xaxis{center(ii),1}),cumsum(yaxis{center(ii),1}), 'k')
            axis equal
            title('Centered Trials');
        end
    end
end