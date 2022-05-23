

function b = getWorkBursts

b = {};
b(end+1,:) = {'H3','hip_flexion','SWpfW'};         % poitive hip flexion work during swing
b(end+1,:) = {'K3','knee','SWneW'};                % negative knee extension work during swing
b(end+1,:) = {'K4','knee','SWnfW'};                % negative knee flexion work during swing
b(end+1,:) = {'H4','hip_flexion','SWpeW'};         % positive hip extension work during swing
b(end+1,:) = {'H1','hip_flexion','STpeW'};         % positive hip extension work during stance
b(end+1,:) = {'K1','knee','STneW'};                % negative knee extension work during stance
b(end+1,:) = {'A1','ankle','STneW'};               % negative ankle plantarflexion work during stance
b(end+1,:) = {'K2','knee','STpeW'};                % positive knee extension work during stance
b(end+1,:) = {'A2','ankle','STpeW'};               % positive ankle plantarflexion work during stance
b(end+1,:) = {'H2','hip_flexion','STnfW'};         % negative hip flexion work during stance