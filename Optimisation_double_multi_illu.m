%% Script for double optimization using multiple illuminant inputs 
%% for multispectral sensor based on Gaussian filters
%% Author: Pierre-Jean Lapray

%% Initialization
close all
clear all
visible = 'on'; %% Figure could be visible or not

%% Font size for graphic views
fontsize = 70;
linewidth = 8;

%% Global parameter
nbreBandSpectral = 8;
N = 100; % discretisation
Min = 380; % Min wavelength
Max = 780; % Max wavelength
x = Min:(Max-Min)/N:Max;
M_min = 0.3;% minimum amplitude
M_max = 1.0;% maximum amplitude
P = 2; % ref article
Q = 3; % ref article
illuminant_input = ['D75';'E  ';'D65']; % selected illuminant 'A  ';'E  ';'D50';'D55';'D65';'D75';'F3 '
selected_illuminant = cellstr(illuminant_input);
environment_absorption_enable = 'bypass'; %% bypass - ocean_water (1981 at http://omlc.org/spectra/water/abs/)

%% Generate illuminants
for i=1:size(selected_illuminant,1)
    illuminant_bank(i,:)=illuminant(selected_illuminant{i},x)/max(illuminant(selected_illuminant{i},x));
end;

%% Plot illuminants
figure('Visible','on');
plot(x, illuminant_bank,'LineWidth',linewidth);
legend(strcat({'Illuminant '},{selected_illuminant{1}}),'FontSize',fontsize,'FontWeight','bold')
xlabel('Wavelength (nm)','FontSize',fontsize,'FontWeight','bold');
%title('Illuminants','FontSize',fontsize,'FontWeight','bold');grid on;
set(gcf,'Color',[1,1,1]);set(gca,'fontsize',fontsize);hold all;

%% Image's sensor response and plot
% Select between e2v and Sony sensors
%silicon_response = xlsread('Sensors/Reponse_capteur_661.xlsx');
silicon_response = xlsread('Sensors/SONY IMX174.csv');
silicon_response_int=interp1(silicon_response(:,1), silicon_response(:,2), x(:), 'linear');
silicon_response_int(:) = silicon_response_int(:) ./ max(silicon_response_int(:));
plot(x, silicon_response_int,'--b','LineWidth',linewidth);ylim([0 1]);xlim([Min Max]);

%% Envirronment absorption
if strcmp(environment_absorption_enable,'ocean_water')
    environment_absorption = xlsread('ocean_water_absorption.xlsx');
    environment_transmission(:,2) = max(environment_absorption(:,2)) - environment_absorption(:,2);
    environment_transmission_int = interp1(environment_absorption(:,1), environment_transmission(:,2), x(:), 'linear');
    environment_transmission_int2 = environment_transmission_int ./ max(environment_transmission_int) ;
    plot(x, environment_transmission_int2,'LineWidth',linewidth);
else
    environment_transmission_int2 = [ones(1,size(x,2))]';
end;

xlabel('Wavelength (nm)','FontSize',fontsize,'FontWeight','bold');
legend([illuminant_input;'Sen';'Abs']);

%% mu_i calculation
Nbre = ((Max-Min)/nbreBandSpectral);
mu=zeros(nbreBandSpectral,1);
for i=1:nbreBandSpectral
    mu(i)=Min+i*Nbre-Nbre/2;
end;

%% B(amplitude) and SIGMA initializations
B=ones(nbreBandSpectral,1);
SIGMA=ones(nbreBandSpectral,1);

%% Gaussian definition
for i=1:nbreBandSpectral
    f(i,:)=B(i)*gaussmf(x, [SIGMA(i) mu(i)]);
end;

%% Convolution definition
for i=1:nbreBandSpectral
    conv(i,:) = trapz(f(i,:));
end;

%% Optimization Implementation

%% Variable vector initialization X(k) / X(1)=B(1), ... X(nbreBandSpectral+1)=SIGMA(1),...
X=[B;SIGMA]; 

%% Lower bound vector
lb=ones(nbreBandSpectral*2,1);
lb(1:nbreBandSpectral,1)=M_min; %Minimum bounds for B
lb(nbreBandSpectral+1:nbreBandSpectral*2)=(Max-Min)/(nbreBandSpectral*6);%Minimum bounds for SIGMA

%% Upper bound vector
ub=Inf(nbreBandSpectral*2,1);
ub(1:nbreBandSpectral,1)=M_max; %Maximum bounds for B

%% Inequality vector A.x<=b
A=zeros(8*(nbreBandSpectral-2),nbreBandSpectral*2);
for i=2:nbreBandSpectral-1
    A(1+(i-2)*8,nbreBandSpectral+(i-1))=-P;A(1+(i-2)*8,nbreBandSpectral+(i))=Q;
    A(2+(i-2)*8,nbreBandSpectral+(i))=P;A(2+(i-2)*8,nbreBandSpectral+(i-1))=P;
    A(3+(i-2)*8,nbreBandSpectral+(i+1))=-P;A(3+(i-2)*8,nbreBandSpectral+(i))=Q;
    A(4+(i-2)*8,nbreBandSpectral+(i+1))=P;A(4+(i-2)*8,nbreBandSpectral+(i))=P;
    A(5+(i-2)*8,nbreBandSpectral+(i-1))=-P;A(5+(i-2)*8,nbreBandSpectral+(i))=-Q;
    A(6+(i-2)*8,nbreBandSpectral+(i))=-P;A(6+(i-2)*8,nbreBandSpectral+(i-1))=-Q;
    A(7+(i-2)*8,nbreBandSpectral+(i+1))=-P;A(7+(i-2)*8,nbreBandSpectral+(i))=-Q;
    A(8+(i-2)*8,nbreBandSpectral+(i))=-P;A(8+(i-2)*8,nbreBandSpectral+(i+1))=-Q;
    
    b(1+(i-2)*8,1)=mu(i)-mu(i-1);
    b(2+(i-2)*8,1)=mu(i)-mu(i-1);
    b(3+(i-2)*8,1)=mu(i+1)-mu(i);
    b(4+(i-2)*8,1)=mu(i+1)-mu(i);
    b(5+(i-2)*8,1)=mu(i-1)-mu(i);
    b(6+(i-2)*8,1)=mu(i-1)-mu(i);
    b(7+(i-2)*8,1)=mu(i)-mu(i+1);
    b(8+(i-2)*8,1)=mu(i)-mu(i+1);
end;

%% Equality definition
Aeq=zeros(0,nbreBandSpectral*2);
beq=zeros(0,1);

%% Starting guess at the solution
x0 = ones(nbreBandSpectral*2,1);   

%% Call and test objective function myfun
for i=1:size(illuminant_bank,1)
    silicon_response_ill(i,:) = silicon_response_int' .* (illuminant_bank(i,:)) .* environment_transmission_int2';
end;

%% Launch optimization - Minimization of the standard deviation of
%% convolutions
options = optimoptions('fmincon','Algorithm','active-set');
[xopt,fopt,exitflag] = fmincon(@(X) myfun_multi_illu(X,x,nbreBandSpectral,mu,silicon_response_ill),x0,A,b,[],[],lb,ub,[],options)

%% Gaussian creation
for j=1:size(silicon_response_int,1)
    for i=1:nbreBandSpectral
        f(i,:)=(xopt(i)*gaussmf(x, [xopt(i+nbreBandSpectral) mu(i)]));
    end;
end;

%% Plot optimization waves
figure('Visible',visible);hold all;
plot(x, f,'LineWidth',linewidth);ylim([0 max(f(:))]);xlim([Min Max]);
xlabel('Wavelength (nm)','FontSize',fontsize,'FontWeight','bold');ylabel('Transm. / Resp.','FontSize',fontsize,'FontWeight','bold');
set(gcf,'Color',[1,1,1]);set(gca,'fontsize',fontsize);
plot(x, silicon_response_int,'--b','LineWidth',linewidth);ylim([0 1]);xlim([Min Max]);

%% Relative response simulation
for j=1:size(silicon_response_ill,1)
    for i=1:nbreBandSpectral
        f(i,:,j)=(xopt(i)*gaussmf(x, [xopt(i+nbreBandSpectral) mu(i)]).*silicon_response_ill(j,:));
    end;
end;

%% Vérification of energy balance
for j=1:size(silicon_response_ill,1)
    for i=1:nbreBandSpectral
        R=f(i,:,j);
        rho(i,j) = trapz(R);
    end;
end;
mean_rho = mean(rho(:))

%% Save plot
set(gcf,'position',get(0,'screensize'));
set(gcf,'PaperUnits','centimeters','PaperPosition',[0 0 20 40], 'PaperPositionMode', 'auto');grid on;
print(strrep(strrep(strrep(strrep([ reshape(illuminant_input',1,size(illuminant_input,1)*size(illuminant_input,2)) '_N_' num2str(nbreBandSpectral) ...
'_M_min_' num2str(M_min) '_M_max_' num2str(M_max) '_P_' num2str(P) '_Q_' num2str(Q)],'.','_'),'  ','_'),' ','_'),'__','_'),'-dpng');
