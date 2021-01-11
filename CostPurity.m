function [Purity] = CostPurity(a,b)
M = crosstab(a,b);
nc = sum(M,1);
mc = max(M,[],1);
Purity = sum(mc(nc>0))/sum(nc);
end