function[filter] = buildGaussianFilter(N, Min, Max, A, sigma, moyenne, silicon_response_int,disp)

%Generate a vector of N values between 0 and A to simulate the
%transmittance of a bandwidth filter.

%Returns a struct filter containing fields

filter.Min=Min;
filter.Max=Max;
filter.N=N;
filter.A=A;
filter.sigma=sigma;
filter.moyenne=moyenne;

x=Min:(Max-Min)/N:Max;

filter.data=A*gaussmf(x, [sigma moyenne]);%Ajout Attenuation
for i=1:size(filter.data,2)
    filter.data(:,i)=filter.data(:,i)*silicon_response_int(i,:);
end
