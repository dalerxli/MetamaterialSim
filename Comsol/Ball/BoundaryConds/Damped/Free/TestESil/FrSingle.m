function [w] = FrSingle( freq, rhoStl, rStl, Esil, betak )

bSolve = 1;

flclear fem;

%========================================================
%  Simulation Properties [ Steel, Silicon, Epoxy ]
%========================================================
r = [ rStl, 0.00775, 0.023 ];
E = [ 2.0696e11, Esil, 4.35e9 ];
nu = [ 0.3, 0.49, 0.368 ];
rho = [ rhoStl, 1300, 1180 ];
h = [ .006, .0025, .006 ];


%========================================================
%  Load Geometry
%========================================================
clear s;
[s] = SymGeom( r(1), r(2), r(3) );

fem.draw=struct('s',s);
[g,st,ft,pt] = geomcsg(fem);
[SubInd,s0] = find(st);
fem.geom = geomcsg(fem);


%========================================================
%  Mesh Subdomains
%========================================================
fem.mesh=meshinit(fem, 'hauto',5, ...
                  'hmaxsub',[1,h(3),2,h(2),3,h(1)]);


%========================================================
%  Frequency Mode
%========================================================
clear appl
appl.mode.class = 'SmeSolid3';
appl.module = 'SME';
appl.shape = {'shlag(2,''u'')','shlag(2,''v'')','shlag(2,''w'')','shlag(1,''p'')'};
appl.gporder = 4;
appl.cporder = 2;
appl.assignsuffix = '_smsld';
clear prop
prop.analysis='freq';
appl.prop = prop;


%========================================================
%  Boundary Conditions
%========================================================
clear bnd
bnd.constrcond = {'free','sym','free'};
bnd.Fz = {0,0,1000};
bnd.ind = [2,2,1,2,2,1,2,2,1,1,1,3,1,1];
appl.bnd = bnd;


%========================================================
%  Set Up Solver
%========================================================
clear equ

equ.shape = {[1;2;3],[1;2;3;4],[1;2;3]};
equ.mixedform = {0,1,0};

equ.dampingtype = {'Rayleigh'};
equ.betadK = { betak };
equ.alphadM = { 0 };

equ.rho = { rho(1), rho(2), rho(3) };
equ.nu = { nu(1), nu(2), nu(3) };
equ.E = { E(1), E(2), E(3) };

equ.ind( SubInd ) = [1,2,3];
appl.equ = equ;

fem.appl{1} = appl;
fem.frame = {'ref'};
fem.border = 1;
clear units;
units.basesystem = 'SI';
fem.units = units;
fem=multiphysics(fem);


%========================================================
%  Solve
%========================================================
if( bSolve )
  fem.xmesh=meshextend(fem);
  fem.sol=femstatic(fem, 'solcomp',{'w','u','p','v'}, 'outcomp',{'w','u','p','v'}, ...
                    'pname','freq_smsld', 'plist',[freq], 'oldcomp',{}, ...
                    'linsolver','spooles');
  fem0=fem;
  p = [0;0;-r(3)/2];
  w = postinterp(fem, 'w', p);
end

