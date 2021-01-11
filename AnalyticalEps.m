function OptEps = AnalyticalEps(x,k)

[m,n] = size(x);
OptEps = ((prod(max(x)-min(x))*k*gamma(.5*n+1))/(m*sqrt(pi.^n))).^(1/n);

end