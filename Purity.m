function [PurityRate Sol] = Purity(MinPts,MainData,Label) 

    K_Dist = bin2dec(int2str(MinPts));
    EpsCell = [];
    
 %% Preparing Data
 
  % Keep Best Eps
    global OptimalEps;
    if isempty(OptimalEps)
        OptimalEps(1) = 0;
    end
    
    global EpsCost;
    if isempty(EpsCost)
        EpsCost(1) = 0;
    end
 
  % Calculate k-dist
    nData = size(MainData,1);
    if K_Dist >= nData
        K_Dist = randi([1 nData-1],1);
    end

 %% Finding Eps Values
 
        % Calculate Current Eps
         Eps = AnalyticalEps(MainData,K_Dist);
         CurrentEpsCost = unifrnd(0.97,1,1);

        if OptimalEps(1) ~= 0
           
            OptimalEps(OptimalEps ==0) = [];
            EpsCost(EpsCost ==0) = [];
            
            if size(OptimalEps,2) == 1
                OptimalEps = OptimalEps';
            end
            
            if size(EpsCost,2) == 1
                EpsCost = EpsCost';
            end
            
            [nonRepeatedEps IndexEps] = unique(OptimalEps);
            AllEpsCost = EpsCost(IndexEps);
            nonRepeatedEps = [nonRepeatedEps Eps];
            AllEpsCost = [AllEpsCost CurrentEpsCost];
            
            % Add all Eps and Purity in a structure
            EpsCell.Eps = [];
            EpsCell.Purity = [];
            
            for i=1:numel(nonRepeatedEps)
                EpsCell.Eps = [EpsCell.Eps nonRepeatedEps(i)];
                EpsCell.Purity = [EpsCell.Purity AllEpsCost(i)];
            end
            
            %% Tournament Selection
             TournamentSize = min(size(unique(EpsCell.Eps),2), 3); % We assume the minimum tournament size is 3
             TS = TournamentSelection(EpsCell.Eps,EpsCell.Purity,TournamentSize);
             Eps = EpsCell.Eps(TS);
        end
      
 %% Finding the Optimal Purity by running DBSCAN
 OptResult = zeros(numel(Eps),2);   % Save Results for each Eps and MinPts
 Types = zeros(numel(Eps),size(MainData,1));
 Classes = zeros(numel(Eps),size(MainData,1));
 %%%%%% Call DBSCAN function %%%%%% We can call any version of DBSCAN function.
 % Here, we call the standalone DBSCAN algorithm.
 [class,type] = dbscan(MainData,K_Dist,Eps);
 %%%%%% ------------------------------------ %%%%%%

 PurityRate = CostPurity(Label,class');          % Call Cost Function
 OptResult(1,1) = Eps;
 OptResult(1,2) = PurityRate;
 Types(1,:) = type;
 Classes(1,:) = class;

   % Sort Result Matrix and then save the best outcomes as:
   [Value Index] = sort(OptResult,1,'descend');
  
   % Sorted Matrix 
   Results = OptResult(Index(:,end));
   Results = [Results Value(:,end)];
   
    if ~isempty(Results)
      BestEps = Results(1,1);
      Sol.Purity = PurityRate;
      Sol.MinPts = K_Dist;
      Sol.BestEps = BestEps;
      Sol.Type = Types(find(Eps==BestEps),:);
      Sol.Class = Classes(find(Eps==BestEps),:);
      Sol.nCluster = size(unique(Sol.Class),2);
      Sol.EpsCell = EpsCell;
      
    else
      BestEps = 0;
      Sol.MinPts = 0;
      Sol.BestEps = BestEps;
      Sol.Purity = PurityRate;
      Sol.Type = [];
      Sol.Class = [];
      Sol.nCluster = 0;
      Sol.EpsCell = [];
    end
    
 end
 
 