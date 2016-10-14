%% Script for simple optimization for multispectral sensor based on Gaussian filters
%% Author: Pierre-Jean Lapray

%% Initialization
close all
clear all

%% Font size for graphic views
fontsize = 80;
linewidth = 6;
visible = 'on'; %% Figure could be visible or not

%% Global Parameters
N = 1000;  % Step
Min = 400; % Min wavelength
Max = 800; % Max wavelength
x = Min:(Max-Min)/N:Max; % Wavelength range
nbreBandSpectral = [3;5;8;12];
min_sigma = 0.01;
max_sigma = 100;
selected_illuminant = 'E'; % Select illuminant - A C D50 D55 D65 D75 F1-F12 Dnn Pnn E

%% Generate illuminants
illuminant1=illuminant(selected_illuminant,x)/max(illuminant(selected_illuminant,x));

%% Silicon response (SONY)
%load('silicon_response.mat');
%silicon_response = xlsread('Sensors/Reponse_capteur_661.xlsx');
silicon_response = xlsread('Sensors/SONY IMX174.csv');

silicon_response_int = interp1(silicon_response(:,1), silicon_response(:,2), x(:), 'linear');
silicon_response_int = silicon_response_int ./ max(silicon_response_int);
silicon_response_illu=silicon_response_int.*(illuminant1');
plot(x, silicon_response_int,'LineWidth',linewidth);title('Silicon response');xlabel('Wavelength (nm)');ylabel('Relative response');
figure('Visible',visible);


%% Filter optimization process
[ filters_opt_amplitude_3 relative_response_opt_amplitude_3 ] = opt_simple_function( x, nbreBandSpectral(1), Min, Max, min_sigma, max_sigma, 'amplitude', N, silicon_response_illu )
[ filters_opt_sigma_3 relative_response_opt_sigma_3 ] = opt_simple_function( x, nbreBandSpectral(1), Min, Max, min_sigma, max_sigma, 'sigma', N, silicon_response_illu )
[ filters_opt_amplitude_5 relative_response_opt_amplitude_5 ] = opt_simple_function( x, nbreBandSpectral(2), Min, Max, min_sigma, max_sigma, 'amplitude', N, silicon_response_illu )
[ filters_opt_sigma_5 relative_response_opt_sigma_5 ] = opt_simple_function( x, nbreBandSpectral(2), Min, Max, min_sigma, max_sigma, 'sigma', N, silicon_response_illu )
[ filters_opt_amplitude_8 relative_response_opt_amplitude_8 ] = opt_simple_function( x, nbreBandSpectral(3), Min, Max, min_sigma, max_sigma, 'amplitude', N, silicon_response_illu )
[ filters_opt_sigma_8 relative_response_opt_sigma_8 ] = opt_simple_function( x, nbreBandSpectral(3), Min, Max, min_sigma, max_sigma, 'sigma', N, silicon_response_illu )
[ filters_opt_amplitude_12 relative_response_opt_amplitude_12 ] = opt_simple_function( x, nbreBandSpectral(4), Min, Max, min_sigma, max_sigma, 'amplitude', N, silicon_response_illu )
[ filters_opt_sigma_12 relative_response_opt_sigma_12 ] = opt_simple_function( x, nbreBandSpectral(4), Min, Max, min_sigma, max_sigma, 'sigma', N, silicon_response_illu )

%% Vérification of energy balance
for i=1:nbreBandSpectral
    R=relative_response_opt_amplitude_3(i).data(:);
    rho_opt_amplitude_3(:,i) = trapz(R)
end;

%% Plot filters
axis([Min Max 0 1.5]);
hold all;set(gcf,'position',get(0,'screensize'));
set(gcf,'PaperUnits','centimeters','PaperPosition',[0 0 20 40], 'PaperPositionMode', 'auto');grid on;
for i=1:nbreBandSpectral(1)
    plot(x, filters_opt_amplitude_3(i).data,'LineWidth',linewidth);ylim([0 1]);xlim([Min Max]);
end;
xlabel('Wavelength (nm)','FontSize',fontsize,'FontWeight','bold');ylabel('Efficiency','FontSize',fontsize,'FontWeight','bold');set(gcf,'Color',[1,1,1]);set(gca,'fontsize',fontsize);grid on;
print('opt_amplitude_3.png','-dpng');

figure('Visible',visible);hold all;
plot(x, silicon_response_illu,'LineWidth',linewidth);
axis([Min Max 0 1.5]);set(gcf,'position',get(0,'screensize'));
set(gcf,'PaperUnits','centimeters','PaperPosition',[0 0 20 40], 'PaperPositionMode', 'auto');grid on;
for i=1:nbreBandSpectral(2)
    plot(x, filters_opt_amplitude_5(i).data,'LineWidth',linewidth);ylim([0 1]);xlim([Min Max]);
end;
xlabel('Wavelength (nm)','FontSize',fontsize,'FontWeight','bold');ylabel('Efficiency','FontSize',fontsize,'FontWeight','bold');set(gcf,'Color',[1,1,1]);set(gca,'fontsize',fontsize);grid on;
print('opt_amplitude_5.png','-dpng');

figure('Visible',visible);hold all;
plot(x, silicon_response_illu,'LineWidth',linewidth);
axis([Min Max 0 1.5]);set(gcf,'position',get(0,'screensize'));
set(gcf,'PaperUnits','centimeters','PaperPosition',[0 0 20 40], 'PaperPositionMode', 'auto');grid on;
for i=1:nbreBandSpectral(3)
    plot(x, filters_opt_amplitude_8(i).data,'LineWidth',linewidth);ylim([0 1]);xlim([Min Max]);
end;
xlabel('Wavelength (nm)','FontSize',fontsize,'FontWeight','bold');ylabel('Efficiency','FontSize',fontsize,'FontWeight','bold');set(gcf,'Color',[1,1,1]);set(gca,'fontsize',fontsize);grid on;
print('opt_amplitude_8.png','-dpng');

figure('Visible',visible);hold all;
plot(x, silicon_response_illu,'LineWidth',linewidth);
axis([Min Max 0 1.5]);set(gcf,'position',get(0,'screensize'));
set(gcf,'PaperUnits','centimeters','PaperPosition',[0 0 20 40], 'PaperPositionMode', 'auto');grid on;
for i=1:nbreBandSpectral(4)
    plot(x, filters_opt_amplitude_12(i).data,'LineWidth',linewidth);ylim([0 1]);xlim([Min Max]);
end;
xlabel('Wavelength (nm)','FontSize',fontsize,'FontWeight','bold');ylabel('Efficiency','FontSize',fontsize,'FontWeight','bold');set(gcf,'Color',[1,1,1]);set(gca,'fontsize',fontsize);grid on;
print('opt_amplitude_12.png','-dpng');

figure('Visible',visible);hold all;
plot(x, silicon_response_illu,'LineWidth',linewidth);
axis([Min Max 0 1.5]);set(gcf,'position',get(0,'screensize'));
set(gcf,'PaperUnits','centimeters','PaperPosition',[0 0 20 40], 'PaperPositionMode', 'auto');grid on;
for i=1:nbreBandSpectral(1)
    plot(x, filters_opt_sigma_3(i).data,'LineWidth',linewidth);ylim([0 1]);xlim([Min Max]);
end;
xlabel('Wavelength (nm)','FontSize',fontsize,'FontWeight','bold');ylabel('Efficiency','FontSize',fontsize,'FontWeight','bold');set(gcf,'Color',[1,1,1]);set(gca,'fontsize',fontsize);grid on;
print('opt_sigma_3.png','-dpng');

figure('Visible',visible);hold all;
plot(x, silicon_response_illu,'LineWidth',linewidth);
axis([Min Max 0 1.5]);set(gcf,'position',get(0,'screensize'));
set(gcf,'PaperUnits','centimeters','PaperPosition',[0 0 20 40], 'PaperPositionMode', 'auto');grid on;
for i=1:nbreBandSpectral(2)
    plot(x, filters_opt_sigma_5(i).data,'LineWidth',linewidth);ylim([0 1]);xlim([Min Max]);
end;
xlabel('Wavelength (nm)','FontSize',fontsize,'FontWeight','bold');ylabel('Efficiency','FontSize',fontsize,'FontWeight','bold');set(gcf,'Color',[1,1,1]);set(gca,'fontsize',fontsize);grid on;
print('opt_sigma_5.png','-dpng');

figure('Visible',visible);hold all;
plot(x, silicon_response_illu,'LineWidth',linewidth);
axis([Min Max 0 1.5]);set(gcf,'position',get(0,'screensize'));
set(gcf,'PaperUnits','centimeters','PaperPosition',[0 0 20 40], 'PaperPositionMode', 'auto');grid on;
for i=1:nbreBandSpectral(3)
    plot(x, filters_opt_sigma_8(i).data,'LineWidth',linewidth);ylim([0 1]);xlim([Min Max]);
end;
xlabel('Wavelength (nm)','FontSize',fontsize,'FontWeight','bold');ylabel('Efficiency','FontSize',fontsize,'FontWeight','bold');set(gcf,'Color',[1,1,1]);set(gca,'fontsize',fontsize);grid on;
print('opt_sigma_8.png','-dpng');

figure('Visible',visible);hold all;
plot(x, silicon_response_illu,'LineWidth',linewidth);
axis([Min Max 0 1.5]);set(gcf,'position',get(0,'screensize'));
set(gcf,'PaperUnits','centimeters','PaperPosition',[0 0 20 40], 'PaperPositionMode', 'auto');grid on;
for i=1:nbreBandSpectral(4)
    plot(x, filters_opt_sigma_12(i).data,'LineWidth',linewidth);ylim([0 1]);xlim([Min Max]);
end;
xlabel('Wavelength (nm)','FontSize',fontsize,'FontWeight','bold');ylabel('Efficiency','FontSize',fontsize,'FontWeight','bold');set(gcf,'Color',[1,1,1]);set(gca,'fontsize',fontsize);grid on;
print('opt_sigma_12.png','-dpng');
