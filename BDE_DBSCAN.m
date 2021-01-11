% Run: you can easily run the BDE-DBSCAN algorithm by 'F5' with the default dataset
% -------------------------------------------------------------------------
% Function: BDE-DBSCAN
% -------------------------------------------------------------------------
% Aim:
% Choosing DBSCAN Parameters Automatically using Differential Evolution
% -------------------------------------------------------------------------
% Cost Funiction:
% Cost function is 'Purity' at 'Purity.m' line 73. You can easily change
% the cost function to other metrics such as Dunn Index, Entropy, etc.
% by changing line 73 at 'Purity.m'.
% -------------------------------------------------------------------------
% Input:
% data (MxN) = a matrix by M samples and N features. If the data is
% 2-dimensional (N=2), you can plot data easily; otherwise, just the first
% two columns are plotted (see lines 215-220).
% label = an array (Mx1) based on each sample in data set;
% Label is just used for two reasons:
% (1) plot the data at lines 215-220
% (2) calculate the purity metric. If you use another cost function such as
% above-mentioned functions, you can skip lable.
% -------------------------------------------------------------------------
% Output:
% Purity = The measurement of purity criterion
% nClust = The number of generated Clusters
% K-Dist = The value of MinPoints parameter
% Eps = The value of Eps parameter
% BestSol = A cell of optimal results
% pop = A cell of generated population with detailed information
% BestCost = An array of incremental trend of purity in each Iteration
% -------------------------------------------------------------------------
% Example of use:
% (1) Call input data:
% load('data');
% load('label');
% (2) Run the program:
% type 'BDE_DBSCAN' in the command window to run the program or press 'F5'
% -------------------------------------------------------------------------
% Using different versions of DBSCAN:
% You can change the used standalone DBSCAN version with any revised version in 'Purity.m' at line 70.
% -------------------------------------------------------------------------
% Citation:
% Please cite the paper as follows:
%@article{Karami2014,
%	author = {Amin Karami and Ronnie Johansson},
%	title = {Choosing DBSCAN Parameters Automatically using Differential Evolution},
%	journal = {International Journal of Computer Applications},
%	year = {2014},
%	volume = {91},
%	number = {7},
%	pages = {1-11},
%	note = {Published by Foundation of Computer Science, New York, USA}
%}
% -------------------------------------------------------------------------

%% Clear & Close
clc;
clear;
close all;

%% Load Data
load('data');
load('label');

%% Problem Definition
global OptimalEps;
global EpsCost;

CostFunction = @(x) Purity(x,data,label);    % Cost Function
nVar = 7;            % Number of Decision Variables
VarSize = [1 nVar];   % Decision Variables Matrix Size

%% DE Parameters

MaxIt = 100;     % Maximum Number of Iterations
nPop = 30;        % Population Size

beta_min = 0.2;   % Lower Bound of Scaling Factor
beta_max = 0.8;   % Upper Bound of Scaling Factor

pCR = 0.25;       % Crossover Probability

OptimalEps = zeros(MaxIt,1);
EpsCost = zeros(MaxIt,1);

%% Initialization

empty_individual.Position = [];
empty_individual.Cost = [];
empty_individual.Sol = [];

BestSol.Cost = 0;

pop = repmat(empty_individual,nPop,1);

for i = 1:nPop
    pop(i).Position = randi([0 1],VarSize);
    % Avoid a population with 0
    if find(pop(i).Position~=1)
    pop(i).Position(randi(VarSize,1)) = 1;
    end
    [pop(i).Cost pop(i).Sol] = CostFunction(pop(i).Position);
    
    if (i == 1)
        BestSol = pop(1);
    end

    if pop(i).Cost > BestSol.Cost
        BestSol = pop(i);
    else if pop(i).Cost == BestSol.Cost   % when the cost is equal, we can select the lower nCluster
            if pop(i).Sol.Purity > BestSol.Sol.Purity
                BestSol = pop(i);
            elseif pop(i).Sol.nCluster < BestSol.Sol.nCluster
                BestSol = pop(i);
            end
        end
    end
end

BestCost = zeros(MaxIt,1);

%% DE Main Loop

for it=1:MaxIt
    
    for i=1:nPop
        
        x = pop(i).Position;
        
        A = randperm(nPop);
        
        A(A==i) = [];
        
        a = A(1);
        b = A(2);
        c = A(3);
        
        % Mutation
        beta = unifrnd(beta_min,beta_max,VarSize);
        y = pop(a).Position + beta .* (pop(b).Position - pop(c).Position);
        
        % Crossover
        z = zeros(size(x));
        j0 = randi([1 numel(x)]);
        for j=1:numel(x)
            if j == j0 || rand <= pCR
                z(j) = y(j);
            else
                z(j) = x(j);
            end
        end
        
        % Check z if it is 0 and should change a bit value to 1
        if find(z~=1)
            z(randi(VarSize,1)) = 1;
        end
        
        % Change real values to 0 and 1. exceed from [0 1], should be controlled
        z = round(z);
        z(z>1) = 1;
        z(z<0) = 0;
        
        NewSol.Position = z;
        [NewSol.Cost NewSol.Sol] = CostFunction(NewSol.Position);
        
        if NewSol.Cost > pop(i).Cost
            pop(i) = NewSol;
        else if NewSol.Cost == pop(i).Cost
                if NewSol.Sol.Purity > pop(i).Sol.Purity
                pop(i) = NewSol;
                elseif NewSol.Sol.nCluster < pop(i).Sol.nCluster
                pop(i) = NewSol;
                end
            end
        end
        
        if pop(i).Cost > BestSol.Cost
           BestSol = pop(i);
        else if pop(i).Cost == BestSol.Cost
                if pop(i).Sol.Purity > BestSol.Sol.Purity
                BestSol = pop(i);
                elseif pop(i).Sol.nCluster < BestSol.Sol.nCluster
                BestSol = pop(i);
                end
            end
        end  
    end

    % Update Best Cost
    BestCost(it) = BestSol.Cost;
    
    % Store BestEps
    OptimalEps(it) = BestSol.Sol.BestEps;
    EpsCost(it) = BestSol.Sol.Purity;
    
    % Show Iteration Information
    disp(['Iter. ' num2str(it) ':' ...
    ', Purity = ' num2str(BestSol.Sol.Purity) ...
    ', nClust = ' num2str(BestSol.Sol.nCluster) ...
    ', K-Dist = ' num2str(int2str(BestSol.Sol.MinPts)) ...
    ', Eps = ' num2str(BestSol.Sol.BestEps) ...
        ]);

    if BestCost(it) == 1
       break; 
    end
end


%% Show Results
figure(1);
PlotSolution(data(:,1:2),BestSol.Sol.Class);
title('DBSCAN Results');
figure(2);
PlotSolution(data(:,1:2),label);
title('Main Clustering');