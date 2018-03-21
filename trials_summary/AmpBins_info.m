% Manually select amp range and note their tuned directions for each recorded neuron in this script.
% Put those info into a ampbin_info.mat file for later use.

f_name={'ZL170517_fish03a',...  %1
    'ZL170518_fish01a',...%2
    'ZL170518_fish02a',...%3
    'ZL170518_fish03a',...%4
    'ZL170518_fish04a',...%5
    'ZL170830_fish04b',...%6
    'ZL170830_fish05b',...%7
    'ZL170901_fish04a',...%8
    'ZL170828_fish01a',...%9
    'ZL170828_fish03a',...%10
    'ZL170828_fish03b',...%11
    'ZL170828_fish04a',...%12
    'ZL170830_fish01b',...%13
    'ZL170830_fish02a',...%14
    'ZL170830_fish04a',...%15
    'ZL170901_fish03a',...%16
    'ZL170906_fish01b',...%17
    'ZL170906_fish03a',...%18
    'ZL170906_fish03b',...%19
    'ZL170901_fish02b',...%20
    'ZL170901_fish03b',...%21
    };
drc={'rostral','caudal'};
S=struct();
S.(f_name{1}).amp_range=[40 80];     %ZL170517_fish03a, Amp1
S.(f_name{1}).direction='rostral';
S.(f_name{1}).corre_clean=1; 

S.(f_name{2})(1).amp_range=[13 40]; %ZL170518_fish01a, Amp1
S.(f_name{2})(1).direction='caudal';
S.(f_name{2})(1).corre_clean=0;

S.(f_name{2})(2).amp_range=[40 100];%ZL170518_fish01a, Amp2
S.(f_name{2})(2).direction='caudal';
S.(f_name{2})(2).corre_clean=0;

S.(f_name{3}).amp_range=[60 90];%ZL170518_fish02a, Amp1
S.(f_name{3}).direction='caudal';
S.(f_name{3}).corre_clean=1;

S.(f_name{4})(1).amp_range=[0 40];%ZL170518_fish03a, Amp1
S.(f_name{4})(1).direction='rostral';
S.(f_name{4})(1).corre_clean=0;

S.(f_name{4})(2).amp_range=[60 120];%ZL170518_fish03a, Amp2
S.(f_name{4})(2).direction='rostral';
S.(f_name{4})(2).corre_clean=1;

S.(f_name{5}).amp_range=[18 35]; %ZL170518_fish04a, Amp1
S.(f_name{5}).direction='rostral';
S.(f_name{5}).corre_clean=0;

S.(f_name{6})(1).amp_range=[19 35];%ZL170830_fish04b, Amp1
S.(f_name{6})(1).direction='rostral';
S.(f_name{6})(1).corre_clean=0;

S.(f_name{6})(2).amp_range=[39 59];%ZL170830_fish04b, Amp2
S.(f_name{6})(2).direction='rostral';
S.(f_name{6})(2).corre_clean=0;

S.(f_name{6})(3).amp_range=[60 85];%ZL170830_fish04b, Amp3
S.(f_name{6})(3).direction='caudal';
S.(f_name{6})(3).corre_clean=1;

S.(f_name{7})(1).amp_range=[0 40];%ZL170830_fish05b, Amp1
S.(f_name{7})(1).direction='caudal';
S.(f_name{7})(1).corre_clean=0;

S.(f_name{7})(2).amp_range=[65 90];%ZL170830_fish05b, Amp2
S.(f_name{7})(2).direction='caudal';
S.(f_name{7})(2).corre_clean=1;

S.(f_name{7})(3).amp_range=[100 140];%ZL170830_fish05b, Amp3
S.(f_name{7})(3).direction='rostral';
S.(f_name{7})(3).corre_clean=1;

S.(f_name{8})(1).amp_range=[15 30];%ZL170901_fish04a, Amp1
S.(f_name{8})(1).direction='rostral';
S.(f_name{8})(1).corre_clean=1;

S.(f_name{8})(2).amp_range=[30 45];%ZL170901_fish04a, Amp2
S.(f_name{8})(2).direction='rostral';
S.(f_name{8})(2).corre_clean=1;

S.(f_name{8})(3).amp_range=[90 110];%ZL170901_fish04a, Amp3
S.(f_name{8})(3).direction='rostral';
S.(f_name{8})(3).corre_clean=1;

S.(f_name{9}).amp_range=[20 50];%ZL170828_fish01a, Amp1
S.(f_name{9}).direction='rostral';
S.(f_name{9}).corre_clean=1;

S.(f_name{10})(1).amp_range=[0 30];%ZL170828_fish03a, Amp1
S.(f_name{10})(1).direction='caudal';
S.(f_name{10})(1).corre_clean=0;

S.(f_name{10})(2).amp_range=[40 70];%ZL170828_fish03a, Amp2
S.(f_name{10})(2).direction='caudal';
S.(f_name{10})(2).corre_clean=1;

S.(f_name{10})(3).amp_range=[70 95];%ZL170828_fish03a, Amp3
S.(f_name{10})(3).direction='rostral';
S.(f_name{10})(3).corre_clean=0;

S.(f_name{10})(4).amp_range=[95 120];%ZL170828_fish03a, Amp4
S.(f_name{10})(4).direction='caudal';
S.(f_name{10})(4).corre_clean=1;

S.(f_name{11})(1).amp_range=[0 20];%ZL170828_fish03b, Amp1
S.(f_name{11})(1).direction='caudal';
S.(f_name{11})(1).corre_clean=0;

S.(f_name{11})(2).amp_range=[20 60];%ZL170828_fish03b, Amp2
S.(f_name{11})(2).direction='caudal';
S.(f_name{11})(2).corre_clean=0;

S.(f_name{11})(3).amp_range=[80 120];%ZL170828_fish03b, Amp3
S.(f_name{11})(3).direction='caudal';
S.(f_name{11})(3).corre_clean=1;

S.(f_name{12})(1).amp_range=[0 20];%ZL170828_fish04a, Amp1
S.(f_name{12})(1).direction='caudal';
S.(f_name{12})(1).corre_clean=0;

S.(f_name{12})(2).amp_range=[20 40];%ZL170828_fish04a, Amp2
S.(f_name{12})(2).direction='caudal';
S.(f_name{12})(2).corre_clean=0;

S.(f_name{12})(3).amp_range=[50 70];%ZL170828_fish04a, Amp3
S.(f_name{12})(3).direction='caudal';
S.(f_name{12})(3).corre_clean=0;

S.(f_name{12})(4).amp_range=[70 90];%ZL170828_fish04a, Amp4
S.(f_name{12})(4).direction='caudal';
S.(f_name{12})(4).corre_clean=1;

S.(f_name{13})(1).amp_range=[0 17];%ZL170830_fish01b, Amp1
S.(f_name{13})(1).direction='caudal';
S.(f_name{13})(1).corre_clean=0;


S.(f_name{13})(2).amp_range=[17 30];%ZL170830_fish01b, Amp2
S.(f_name{13})(2).direction='caudal';
S.(f_name{13})(2).corre_clean=1;

S.(f_name{13})(3).amp_range=[40 60];%ZL170830_fish01b, Amp3
S.(f_name{13})(3).direction='rostral';
S.(f_name{13})(3).corre_clean=0;

S.(f_name{13})(4).amp_range=[120 170];%ZL170830_fish01b, Amp4??
S.(f_name{13})(4).direction='rostral';
S.(f_name{13})(4).corre_clean=1;

S.(f_name{14})(1).amp_range=[0 25];%ZL170830_fish02a, Amp1
S.(f_name{14})(1).direction='rostral';
S.(f_name{14})(1).corre_clean=0;

S.(f_name{14})(2).amp_range=[25 100];%ZL170830_fish02a, Amp2
S.(f_name{14})(2).direction='rostral';
S.(f_name{14})(2).corre_clean=0;

S.(f_name{14})(3).amp_range=[130 200];%ZL170830_fish02a, Amp3
S.(f_name{14})(3).direction='rostral';
S.(f_name{14})(3).corre_clean=1;

S.(f_name{15})(1).amp_range=[0 50];%ZL170830_fish04a, Amp1
S.(f_name{15})(1).direction='caudal';
S.(f_name{15})(1).corre_clean=0;

S.(f_name{15})(2).amp_range=[70 150];%ZL170830_fish04a, Amp2
S.(f_name{15})(2).direction='caudal';
S.(f_name{15})(2).corre_clean=1;

S.(f_name{16})(1).amp_range=[0 18];%ZL170901_fish03a, Amp1
S.(f_name{16})(1).direction='rostral';
S.(f_name{16})(1).corre_clean=0;

S.(f_name{16})(2).amp_range=[18 30];%ZL170901_fish03a, Amp2
S.(f_name{16})(2).direction='rostral';
S.(f_name{16})(2).corre_clean=1;

S.(f_name{16})(3).amp_range=[30 60];%ZL170901_fish03a, Amp3
S.(f_name{16})(3).direction='rostral';
S.(f_name{16})(3).corre_clean=1;

S.(f_name{16})(4).amp_range=[70 110];%ZL170901_fish03a, Amp4
S.(f_name{16})(4).direction='rostral';
S.(f_name{16})(4).corre_clean=1;

S.(f_name{17})(1).amp_range=[0 20];%ZL170906_fish01b, Amp1
S.(f_name{17})(1).direction='caudal';
S.(f_name{17})(1).corre_clean=0;

S.(f_name{17})(2).amp_range=[20 40];%ZL170906_fish01b, Amp2
S.(f_name{17})(2).direction='caudal';
S.(f_name{17})(2).corre_clean=0;

S.(f_name{17})(3).amp_range=[80 120];%ZL170906_fish01b, Amp3
S.(f_name{17})(3).direction='caudal';
S.(f_name{17})(3).corre_clean=1;

S.(f_name{18})(1).amp_range=[23 50];%ZL170906_fish03a, Amp1
S.(f_name{18})(1).direction='rostral';
S.(f_name{18})(1).corre_clean=0;

S.(f_name{19})(1).amp_range=[0 25];%ZL170906_fish03b, Amp1
S.(f_name{19})(1).direction='caudal';
S.(f_name{19})(1).corre_clean=0;

S.(f_name{19})(2).amp_range=[40 70];%ZL170906_fish03b, Amp2
S.(f_name{19})(2).direction='caudal';
S.(f_name{19})(2).corre_clean=1;

S.(f_name{19})(3).amp_range=[80 100];%ZL170906_fish03b, Amp3
S.(f_name{19})(3).direction='caudal';
S.(f_name{19})(3).corre_clean=1;

S.(f_name{19})(4).amp_range=[200 250];%ZL170906_fish03b, Amp3
S.(f_name{19})(4).direction='caudal';
S.(f_name{19})(4).corre_clean=1;

S.(f_name{20}).amp_range=[50 70];%ZL170901_fish02b, Amp1
S.(f_name{20}).direction='rostral';
S.(f_name{20}).corre_clean=1;

S.(f_name{21})(1).amp_range=[20 30];%ZL170901_fish03b, Amp1
S.(f_name{21})(1).direction='rostral';
S.(f_name{21})(1).corre_clean=1;

S.(f_name{21})(2).amp_range=[30 40];%ZL170901_fish03b, Amp2
S.(f_name{21})(2).direction='rostral';
S.(f_name{21})(2).corre_clean=1;

S.(f_name{21})(3).amp_range=[90 100];%ZL170901_fish03b, Amp3
S.(f_name{21})(3).direction='rostral';
S.(f_name{21})(3).corre_clean=1;
save('ampbin_info.mat','-struct','S');
