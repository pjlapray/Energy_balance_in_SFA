function f = myfun_multi_illu(X,x,nbreBandSpectral,mu,silicon_response)
%MYFUN Return standard deviation of all the Gaussian convolutions through
%multiple illuminants
%   mu: central position of Gaussian
%   X=[B;SIGMA]; array of amplitude and sigma parameters of Gaussian
%   x: Application range
%   ill: bank of illuminants
for j=1:size(silicon_response,1)
    for i=1:nbreBandSpectral
        conv(i,j)=trapz(X(i)*gaussmf(x, [X(i+nbreBandSpectral) mu(i)]).*silicon_response(j,:));
    end;
end;


% Mean of channels before std deviation
%conv = mean(conv,2)

f = std(conv(:));
end

