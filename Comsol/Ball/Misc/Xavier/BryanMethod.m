cd /media/Storage/'Imaging and Detecting Platform'/'Project Files'/FRST/'Acoustically Efficient Buildings'/'Xavier Bremaud''s data and report'/mesure-tube/

a='trac501';
b='trac536';
c='trac537';
d='trac538';
e='trac539';
g='trac540';
ep=0.01; %epaisseur de l'échantillon testé'

%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
load(a)
HP1R=o2i1;HP1R=zeros(801,1);HP1R(:,:)=1;
load(b)
HP2R=o2i1;
load(e)
HP3R=o2i1;
load(g)
HP4R=o2i1;
f=o2i1x;

cd ~/Matlab/Xavier/

k=2*pi().*f/cs;

x1=-0.257;
x2=-0.187;
x3=-x2+ep;
x4=-x1+ep;

rho=1.2;

%==============TRANSFERT FUNCTIONS==========================
%figure, plot(f,HP1R,'r'), hold on, plot(f,HP2R,'g'), hold on, plot(f,HP3R,'b'), hold on, plot(f,HP4R,'c'), hold on, grid on,
%figure,subplot(2,2,1),plot(f,-20*log10(HP1R),'r'), title('transfert function (in dB) 1(red),2(green),3(blue),4(cyan)'),hold on,plot(f,-20*log10(HP2R),'g'),hold on,plot(f,-20*log10(HP3R),'b'),hold on,plot(f,-20*log10(HP4R),'c'),hold on,grid on

%==============AMPLITUDES===================================
A=i*(HP1R.*exp(i.*k.*x2)-HP2R.*exp(i.*k.*x1))./(2*sin(k.*(x1-x2)));
B=i*(HP2R.*exp(-i.*k.*x1)-HP1R.*exp(-i.*k.*x2))./(2*sin(k.*(x1-x2)));
C=i*(HP3R.*exp(i.*k.*x4)-HP4R.*exp(i.*k.*x3))./(2*sin(k.*(x3-x4)));
D=i*(HP4R.*exp(-i.*k.*x3)-HP3R.*exp(-i.*k.*x4))./(2*sin(k.*(x3-x4)));
%D=0;
%subplot(2,2,2),plot(f,A,'r'), title('Amplitudes A(red),B(green),C(blue),D(cyan)'), hold on,plot(f,B,'g'), hold on,plot(f,C,'b'), hold on,plot(f,D,'c'), hold on,grid on
%subplot(2,2,3),plot(f,(A-C)./A),title('% of difference between A & C'),grid on,axis([0 1600 -5 100]),

%==============Pression & Velocity==========================

p0=A+B; 
v0=(A-B)/(rho*cs);
pd=C.*exp(-i.*k.*ep)+D.*exp(i.*k.*ep);
vd=(C.*exp(-i.*k.*ep)-D.*exp(i.*k.*ep))/(rho*cs);
%subplot(2,2,4),plot(f,(pd-p0)./pd),title('% of difference between p0 & pd'),grid on,axis([0 1600 -5 100]),

%==============Transfert matrix=============================
T11=(pd.*vd+p0.*v0)./(p0.*vd+pd.*v0);
T12=p0.*p0-pd.*pd;
T21=v0.*v0-vd.*vd;
T22=T11;
%subplot(2,2,4), plot(f,T11,'b'),grid on, hold on, axis([0 1600 -5 5]),title('T12 in red & T11 in blue'),plot(f,T12,'r'),hold on, 

%==============Transmission loss coefficient=============================
TL=10*log10((1/4)*abs(T11+T12/(rho*cs)+rho*cs*T21+T22).*abs(T11+T12/(rho*cs)+rho*cs*T21+T22));
%subplot(2,2,3),semilogx(f,TL),title('TL (in dB) in function of the frequency'),grid on

T=(B.*D-A.*C)./(D.*D-A.*A);
R=(A.*B-C.*D)./(A.*A-D.*D);
lim=-0.5:0.01:1.5;
IA1=10*log(1./abs(T));
