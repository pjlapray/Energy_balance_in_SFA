
close all
clear all

%% Font size for graphic views
fontsize = 50;
linewidth = 4;

domain = -4:0.01:4;
plot(domain,normpdf(domain),'Color',[0 0 0],'LineWidth',2);
hold on

% We shade two regions with the area command
L = 4*fix(length(domain))/8;
R = 4*fix(length(domain))/8;
area(domain(1:L),normpdf(domain(1:L)),'FaceColor',[0 1 0]);
area(domain(R:end),normpdf(domain(R:end)),'FaceColor',[0 1 0]);
hold on

% We shade two regions with the area command
L = 3*fix(length(domain))/8;
R = 5*fix(length(domain))/8;
area(domain(1:L),normpdf(domain(1:L)),'FaceColor',[0 0 1]);
area(domain(R:end),normpdf(domain(R:end)),'FaceColor',[0 0 1]);
hold on

% We shade two regions with the area command
L = 2*fix(length(domain))/8;
R = 6*fix(length(domain))/8;
area(domain(1:L),normpdf(domain(1:L)),'FaceColor',[1 0 0]);
area(domain(R:end),normpdf(domain(R:end)),'FaceColor',[1 0 0]);

% We shade two regions with the area command
L = 1*fix(length(domain))/8;
R = 7*fix(length(domain))/8;
area(domain(1:L),normpdf(domain(1:L)),'FaceColor',[1 1 0]);
area(domain(R:end),normpdf(domain(R:end)),'FaceColor',[1 1 0]);

% Now add gratuitous vertical lines
stem([-3,-2,-1,0,1,2,3],normpdf([-3,-2,-1,0,1,2,3]),'LineWidth',1.5,'Color',[0 0 0]);

grid on;
set(gcf,'Color',[1,1,1]);set(gca,'fontsize',fontsize);
xlabel('Wavelength (nm)','FontSize',fontsize,'FontWeight','bold');
ylabel('Efficiency','FontSize',fontsize,'FontWeight','bold');
set(gca,...
 'xlim',[-4 4],...
 'xtick',[-4:1:4],...
 'xticklabel',{'-4\sigma' '-3\sigma' '-2\sigma' '-\sigma' '0' '\sigma' '2\sigma' '3\sigma' '4\sigma'},...
 'fontsize',fontsize)

rotateXLabels(gca,45);