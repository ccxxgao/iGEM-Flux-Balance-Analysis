changeCobraSolver('glpk','all');
global CBTDIR
modelFileName = 'ecoli_core_model.mat';
modelDirectory = getDistributedModelFolder(modelFileName);
modelFileName= [modelDirectory filesep modelFileName]; % Get the full path. Necessary to be sure, that the right model is loaded
model = readCbModel(modelFileName);

model_normal = model;
model_normal = changeObjective (model_normal, {'Biomass_Ecoli_core_w_GAM'});
model_normal = changeRxnBounds (model_normal, {'EX_glc(e)'}, -20, 'l');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

model_ethylene_glycol = model;
[exchBool,uptBool] = findExcRxns(model);
uptakes = model.rxns(uptBool);
subuptakeModel = extractSubNetwork(model, uptakes);
hiCarbonRxns = findCarbonRxns(subuptakeModel,1);

model_ethylene_glycol = changeRxnBounds(model_ethylene_glycol, hiCarbonRxns, 0, 'b');
model_ethylene_glycol = changeRxnBounds (model_ethylene_glycol, 'glx[c]', -20, 'l');
model_ethylene_glycol = changeRxnMets(model_ethylene_glycol, {'glc-D[e]'}, {'glx[c]'}, 'Biomass_Ecoli_core_w_GAM', 1)
model_ethylene_glycol = changeObjective (model_ethylene_glycol, {'Biomass_Ecoli_core_w_GAM'});

FBA_normal = optimizeCbModel (model_normal, 'max')
FBA_ethylene_glycol = optimizeCbModel (model_ethylene_glycol, 'max')