function [realf, realy] = FFTtoReal(signal,Fs)

y=fft(signal); 

n = length(signal);                         

realy=2*abs(y(1:n/2+1))/n;
realf=(0:n/2)*(Fs/n);

end