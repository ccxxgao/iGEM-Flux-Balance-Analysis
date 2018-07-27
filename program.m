changeCobraSolver('glpk','all');
global CBTDIR
modelFileName = 'Recon2.0model.mat';
modelDirectory = getDistributedModelFolder(modelFileName); %Look up the folder for the distributed Models.
modelFileName= [modelDirectory filesep modelFileName]; % Get the full path. Necessary to be sure, that the right model is loaded
model = readCbModel(modelFileName);

modelaerobic = model;
printRxnFormula(model, 'DM_atp_c_');
modelaerobic = changeObjective (modelaerobic, 'DM_atp_c_');
modelaerobic = changeRxnBounds (modelaerobic, 'EX_glc(e)', -20, 'l');
modelaerobic = changeRxnBounds (modelaerobic, 'EX_o2(e)', -1000, 'l');

%Closing the uptake of all energy and oxygen sources
[exchBool,uptBool] = findExcRxns(model);
uptakes = model.rxns(uptBool);
subuptakeModel = extractSubNetwork(model, uptakes);
hiCarbonRxns = findCarbonRxns(subuptakeModel,1);
% Closing the uptake of all the carbon sources
modelalter = model;
modelalter = changeRxnBounds(modelalter, hiCarbonRxns, 0, 'b');
% Closing other oxygen and energy sources. Use the following lines for recon2, or uncomment the lines below for recon3
exoxygen = {'EX_adp', 'EX_amp(e)', 'EX_atp(e)', 'EX_co2(e)', 'EX_coa(e)', 'EX_fad(e)', 'EX_fe2(e)',...
            'EX_fe3(e)', 'EX_gdp(e)', 'EX_gmp(e)', 'EX_gtp(e)', 'EX_h(e)', 'EX_h2o(e)', 'EX_h2o2(e)',...
            'EX_nad(e)', 'EX_nadp(e)', 'EX_no(e)', 'EX_no2(e)', 'EX_o2s(e)'};
modelalter = changeRxnBounds (modelalter, exoxygen, 0, 'l');

%Closing the uptake of all energy and oxygen sources
[exchBool,uptBool] = findExcRxns(model);
uptakes = model.rxns(uptBool);
subuptakeModel = extractSubNetwork(model, uptakes);
hiCarbonRxns = findCarbonRxns(subuptakeModel,1);

% Closing the uptake of all the carbon sources
modelanaerobic = modelalter;
modelanaerobic = changeRxnBounds(modelanaerobic, 'EX_glc(e)',-20,'l');
modelanaerobic = changeRxnBounds (modelanaerobic, 'EX_o2(e)', 0, 'l');
modelanaerobic = changeObjective(modelanaerobic,'DM_atp_c_');

FBAaerobic = optimizeCbModel (modelaerobic, 'max')
FBAanaerob = optimizeCbModel(modelanaerobic,'max')