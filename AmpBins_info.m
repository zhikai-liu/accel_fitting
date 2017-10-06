
f_name={'ZL170517_fish03a','ZL170518_fish01a','ZL170518_fish02a','ZL170518_fish03a','ZL170518_fish04a',...
    'ZL170830_fish04b','ZL170830_fish05b','ZL170901_fish04a'};
drc={'rostral','caudal'};
S=struct();
S.(f_name{1}).amp_range=[40 80];
S.(f_name{1}).direction='rostral';
S.(f_name{2})(1).amp_range=[13 40];
S.(f_name{2})(1).direction='caudal';
S.(f_name{2})(2).amp_range=[40 100];
S.(f_name{2})(2).direction='caudal';
S.(f_name{3}).amp_range=[60 90];
S.(f_name{3}).direction='caudal';
S.(f_name{4})(1).amp_range=[0 40];
S.(f_name{4})(1).direction='rostral';
S.(f_name{4})(2).amp_range=[60 120];
S.(f_name{4})(2).direction='rostral';
S.(f_name{5}).amp_range=[18 35];
S.(f_name{5}).direction='rostral';
S.(f_name{6})(1).amp_range=[19 35];
S.(f_name{6})(1).direction='rostral';
S.(f_name{6})(2).amp_range=[39 59];
S.(f_name{6})(2).direction='rostral';
S.(f_name{6})(3).amp_range=[60 85];
S.(f_name{6})(3).direction='caudal';
S.(f_name{7})(1).amp_range=[0 40];
S.(f_name{7})(1).direction='caudal';
S.(f_name{7})(2).amp_range=[65 90];
S.(f_name{7})(2).direction='caudal';
S.(f_name{7})(3).amp_range=[100 140];
S.(f_name{7})(3).direction='rostral';
S.(f_name{8})(1).amp_range=[15 30];
S.(f_name{8})(1).direction='rostral';
S.(f_name{8})(2).amp_range=[30 45];
S.(f_name{8})(2).direction='rostral';
S.(f_name{8})(3).amp_range=[90 110];
S.(f_name{8})(3).direction='rostral';


save('ampbin_info.mat','-struct','S');
