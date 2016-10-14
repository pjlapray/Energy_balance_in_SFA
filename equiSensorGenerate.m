function[f f_sil] = equiSensorGenerate(spectralBands, Min, Max, discretisation, attenuation, sigma, silicon_response_int)

boundaries_sigma = 0;
Nbre = ((Max-Min-2*boundaries_sigma)/spectralBands)%sigma
x=Min:(Max-Min)/discretisation:Max;
for i=1:spectralBands
    c(i)=Min+boundaries_sigma+i*Nbre-Nbre/2;
    f(i)=buildGaussianFilter(discretisation, Min, Max, attenuation(i), sigma(i), c(i), ones(size(x,2),1),3);
end
for i=1:spectralBands
    c(i)=Min+i*Nbre-Nbre/2;
    f_sil(i)=buildGaussianFilter(discretisation, Min, Max, attenuation(i), sigma(i), c(i), silicon_response_int,4);
end



