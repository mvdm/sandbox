%% define space (units all in cm)
dx = 1;
xl = [-50 50];
x = xl(1):dx:xl(2);

%% define place field centers and sigmas
pf_ctr = [0];
pf_sigma = [10];
pf_fr = [50];

nCells = length(pf_ctr);
%% generate tuning curves
for iC = nCells:-1:1
    
    tc(iC,:) = pf_fr(iC) * exp((-(x-pf_ctr(iC)).^2)./(2*pf_sigma(iC).^2)); 
    
end
plot(x,tc)

%% run a simulation
v = 100; % in cm/s
dt = 0.0001; % in s
t = [0 1];
tvec = t(1):dt:t(2);


%% first, for each time, get position
pos = x(1)+v*tvec;
pos_idx = nearest_idx2(pos,x);
pos = x(pos_idx);

plot(tvec,pos);

%% then, obtain rate for each position
for iC = length(nCells):-1:1
   
    frate(iC,:) = tc(iC,pos_idx);
    
end
plot(tvec,frate);

%% generate spikes
p_spike = frate.*dt;

rng default; % reset random number generator to reproducible state

spk_poiss = rand(size(p_spike));
for iC = nCells:-1:1
    
    % random numbers between 0 and 1
    spk_poiss_idx = find(spk_poiss(iC,:) < p_spike(iC,:)); % index of bins with spike
    S{iC} = tvec(spk_poiss_idx)'; % use idxs to get corresponding spike time
    
end

iC = 1;
hold on;
yl = ylim;
plot([S{iC} S{iC}],[-1 -0.5],'Color',[0 0 0]); % note, plots all spikes in one command
axis([t(1) t(2) -1.5 yl(2)]); %set(gca,'YTick','');