%% set up our testing grid
x1 = 0:0.1:1;
x2 = 0:0.1:1;

% set up function parameters
to_test = {'egreedy','softmax','selection_gurney2001a_fun'};
%to_test = {'softmax'};

param = [];
param.e = 0;
param.tau = 0.01;
param.numChans = 4;
param.posW = 0.45;
param.negW = -1.35;
param.chanIDs = 1:param.numChans;
param.W = ones(param.numChans);
param.epsilon = -0.1;
param.m = 1;
param.thr_large = 0.1; % theta thr   
param.thr_small = 0; 


%% get the data
nIter = 100;

out_count = zeros(length(to_test),length(x1),length(x2),4);

for i1 = 1:length(x1)
    
    for i2 = 1:length(x2)
        
        this_input = [x1(i1) x2(i2) 0.5 0.5];
        param.numChans = length(this_input);
        
        for iIter = 1:nIter
            
            for iF = 1:length(to_test)
                
                fun_string = sprintf('temp = %s(this_input,param);',to_test{iF});
                eval(fun_string);
                
                out_count(iF,i1,i2,:) = squeeze(out_count(iF,i1,i2,:)) + temp'; 
                
            end % functions
            
        end % iterations
        
    end % i2
    
end % i1

%% visualize

for iF = 1:length(to_test)
    
    figure(iF);
    
    for iSp = 1:4
        
        subplot(2,2,iSp)
        imagesc(x1,x2,squeeze(out_count(iF,:,:,iSp))');
        xlabel('x1');
        ylabel('x2');
        title(sprintf('%s, action %d',to_test{iF},iSp));
        set(gca,'FontSize',16);
        
    end
    
end