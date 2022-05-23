
function Rates = getrates(DirElaborated)

fp = filesep;


load([DirElaborated fp 'sessionData' fp 'Rates.mat']);

