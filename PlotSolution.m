function PlotSolution(data,class)

    [a1, b1, c1] = unique(class);
        
    nCluster = numel(a1);
    Color = hsv(nCluster);

    for j=1:nCluster
        Members=(c1==j); 
        if (j==1)
            plot(data(Members,1),data(Members,2),'r*','MarkerSize',5,'MarkerFaceColor','red');
        else
            plot(data(Members,1),data(Members,2),'ko','MarkerSize',5,'MarkerFaceColor', Color(j-1,:));
        end
        hold on;
    end
    set(gca,'fontsize',12);
    grid on;
    hold off;
end