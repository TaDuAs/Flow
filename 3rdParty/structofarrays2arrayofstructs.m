function S = structofarrays2arrayofstructs(A)
   % structofarrays2arrayofstructs does exactly what it says.
   % USAGE: 
   %   S = structofarrays2arrayofstructs(A) assumes that A is a struct, with each field
   %   containing Nx1 (columns) of values. (theoretically NxM values, where M may vary).  This results in an Nx1 array of
   %   structs, each containing 1 (or M) values.
   %  
   %  Example 1
   %     >> A.flower={'Daisy';'Rose';'Violet'};
   %     >> A.color={'white';'red';'violet'};
   %
   %     >> S = structofarrays2arrayofstructs(A)
   %
   %     S = 
   %     1x3 struct array with fields:
   %         flower
   %         color 
   %       
   %     >> S(2)
   %     ans = 
   %         flower: 'Rose'
   %          color: 'red'
   %
   %  Note, Any cells it encounters are unwrapped.
   
   % -Celso Reyes
   % Updated by Tal Duanis-Assaf to account for matrices
   
fn=fieldnames(A);

% Update by Tal Duanis-Assaf.
% Changed from nItems = numel(...)
% when a property holds a list of character arrays, i.e when loading a
% delimited values file using tdfread, it generates a property with a
% character matrix instead of a cell array.
% There is an error when calculating nItems using numel because numel is a
% product of the dimentions of the matrix.
[n,m] = size(A.(fn{1}));
if n > 1 && m > 1
    nItems = n;
else
    nItems=max([n m]);
end
sf=fn';

sf(2,1:numel(fn))={{}};
sf = sf(:)';
S=struct(sf{:});

for f=1:numel(fn)
   if iscell( A.(fn{f})(1) )
      for n = nItems: -1 : 1
         S(n).(fn{f}) = A.(fn{f}){n,:};
      end
   else
      for n = nItems: -1 : 1
         S(n).(fn{f}) = A.(fn{f})(n,:);
      end
   end
end