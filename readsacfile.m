%function [t,a,p]=readsac(sacfile,npts,'many') 
% 
%Required input:  sacfile 
%Optional input:  npts,'many' 
%Required output: t,a 
%Optional output: p 
% 
%t = independent variable ; a = dependent variable. 
%sacfile= file containing sac data (or list of files). 
%   
% 
%The sac headers are stored in p as: 
%p(1:3)     delta,depmin,depmax, 
%p(4:6)     B,E,Event Origin Time 
%p(7:16)    T0 - T9 
%p(17:24)   STLA,LO,EL,DP,EVLA,LO,EL,DP 
%p(25:28)   Dist,Az,BAz,GCArc 
%p(29:34)   Year,Day,Hour,Min,Sec,MillSec 
%p(35)      Npts 
%p(36:40)   IFType,IDep,IZType,IevTyp,ISynth 
% 
%With npts presribed, only the first npts of the data 
%file are read in.  
% 
%With the Option 'many' the filenames are read from 
%the file specified. Npts must be specified because 
%the files may have different npts. 
% 
%Ex: [t,a]=readsac('sac.data'); -read data from 1 binary sac file 
%Ex: [t,a]=readsac('mysac.dat',2400,'many') - read several  
%datafiles. (The list of files is in mysac.dat.) 
% 
%Written by Greenfield&Battenhouse 
function [t,a,p]=readsacfile(sacfile) 
sacfid=fopen(sacfile,'r'); 
fparam=zeros(1,70);  iparam=zeros(1,35);  p=zeros(1,40); 
% Read Parameters 
 fparam=fread(sacfid,70,'float32'); 
 iparam=fread(sacfid,35,'int32'); 
 p=assignparam(fparam,iparam); 
for j=1:40, if p(j)==-12345 p(j)=nan; end, end; 
% Read data 
 npts=p(35); a=zeros(1,npts); t=zeros(1,npts); 
 t=p(4):p(1):p(4)+(npts-1)*p(1); 
 fseek(sacfid,158*4,-1);  %(used to be 154?) 
 a(1:npts)=fread(sacfid,npts,'float32'); 
if isNAN(p(4)) | isNAN(p(1)), 
 t(1:npts)=fread(sacfid,npts,'float32'); 
end 
fclose(sacfid); 
return 

function p=assignparam(fparam,iparam) 
p=zeros(1,40); 
p(1:3)=fparam(1:3);            %delta,depmin,depmax, 
p(4:5)=fparam(6:7);            %B,E 
p(6)=fparam(8);                %Event Origin Time 
p(7:16)=fparam(11:20);         %T0 - T9 
p(17:24)=fparam(32:39);        %STLA,LO,EL,DP,EVLA,LO,EL,DP 
p(25:28)=fparam(51:54);        %Dist,Az,BAz,GCArc 
p(29:34)=iparam(1:6);          %Year,Day,Hour,Min,Sec,MillSec 
p(35)=iparam(10);              %Npts 
p(36:38)=iparam(16:18);        %IFType,IDep,IZType 
p(39:40)=[iparam(23) iparam(25)];   %IevTyp,ISynth 
p(41)=fparam(40) ;              %Magnitude     
return 

function l=isNAN(a) 
l=1- (a>0 | a<0 | a==0); 
return 
 

