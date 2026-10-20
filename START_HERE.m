% Structural Analysis Workbench: open the integrated calculation document.
workbenchRoot = fileparts(mfilename('fullpath'));
workbenchMatlab = fullfile(workbenchRoot, 'matlab');
addpath(workbenchMatlab, '-begin');
ae_verificar;
open(fullfile(workbenchMatlab, 'ANALISIS_ESTRUCTURAL_INTEGRADO.mlx'));
fprintf('Structural Analysis Workbench ready. Edit the inputs and press Run.\n');
