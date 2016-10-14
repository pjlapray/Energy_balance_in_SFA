function [ filters relative_response ] = opt_simple_function( x, nbreBandSpectral, Min, Max, min_sigma, max_sigma, optimization_method, N, silicon_response_illu )

%OPT_SIMPLE_FUNCTION Summary of this function goes here
%   Detailed explanation goes here

%% Generate filters
sigma_init=(Max-Min)/(5*nbreBandSpectral);
B=ones(nbreBandSpectral);
sigma=sigma_init*ones(nbreBandSpectral);
[filters relative_response]=equiSensorGenerate(nbreBandSpectral, Min, Max, N, B, sigma, silicon_response_illu);
for i=1:nbreBandSpectral
    R=relative_response(i).data(:);
    rho(:,i) = trapz(R);
end;
rho
switch optimization_method
    case 'amplitude'
        % Amplitude method for energy balancing
        index_rho_max=find(rho==(max(max(rho))))
        norm1=rho(index_rho_max)./rho
        norm2=norm1/max(norm1)
        [filters relative_response]=equiSensorGenerate(nbreBandSpectral, Min, Max, N, norm2, sigma, silicon_response_illu);
    case 'sigma'
        % Sigma method for energy balancing
        A=sum(rho(:))/nbreBandSpectral;
        Nbre = ((Max-Min)/nbreBandSpectral);%sigma
        for i=1:nbreBandSpectral
            c(i)=Min+i*Nbre-Nbre/2;
            y(i) = fminbnd(@(y) (abs(A-trapz(B(i)*gaussmf(x, [y c(i)]).*silicon_response_illu'))),min_sigma,max_sigma);
        end;
        [filters relative_response]=equiSensorGenerate(nbreBandSpectral, Min, Max, N, B, y, silicon_response_illu);
    case 'double'
        % Optimisation double sigma + amplitude (beta) 
        y=zeros(2,5);
        index_rho_max=find(rho==(max(max(rho))))
        A=rho(index_rho_max)
        Nbre = ((Max-Min)/nbreBandSpectral);% sigma
        for i=1:nbreBandSpectral
            c(i)=Min+i*Nbre-Nbre/2;
            [y(:,i),fval,exitflag] = fminsearch(@(y) (abs(A-trapz(y(1)*gaussmf(x, [y(2) c(i)]).*silicon_response_illu'))),[B(i) sigma(i)])
            exitflag
        end;
        y(1,:)=y(1,:)/max(y(1,:))% normalisation
        [filters relative_response]=equiSensorGenerate(nbreBandSpectral, Min, Max, N, y(1,:), y(2,:), silicon_response_illu);
    end;
end

