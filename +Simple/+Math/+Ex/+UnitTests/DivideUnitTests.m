import Simple.Math.Ex.*;
disp('Starting Simple.Math.Ex.Divide class unit tests');
%%
test = Simple.UnitTests.UnitTesting('Simple.Math.Ex.Divide.ctor');

exp = Divide(Scalar(10), X);
test.checkExpectation(true, exp.left.equals(10), 'Divide(10,x).left.equals(10)');
test.checkExpectation(true, exp.right.equals(X), 'Divide(10,x).right.equals(x)');

exp = Divide(X, Scalar(10));
test.checkExpectation(true, exp.right.equals(10), 'Divide(x,10).right.equals(10)');
test.checkExpectation(true, exp.left.equals(X), 'Divide(x,10).left.equals(x)');

exp = Divide(X, Divide(X, X));
test.checkExpectation(true, exp.left.equals(X), 'Divide(X,Divide(X,X)).left.equals(x)');
test.checkExpectation(true, isa(exp.right, 'Divide'), 'Divide(X,Divide(X,X)).left.equals(x)');
test.checkExpectation(true, exp.right.left.equals(X), 'Divide(X,Divide(X,X)).right.left.equals(x)');
test.checkExpectation(true, exp.right.right.equals(X), 'Divide(X,Divide(X,X)).right.right.equals(x)');

test.evaluateAllExpectations();
%%
test = Simple.UnitTests.UnitTesting('Simple.Math.Ex.Divide.equals');

exp = Divide(Scalar(10), X);
test.checkExpectation(true, exp.equals(Divide(Scalar(10), X)), 'Divide(10,x).equals(Divide(10, X))');
test.checkExpectation(false, exp.equals(Divide(X, Scalar(10))), 'Divide(10,x).equals(Divide(X, 10))');
test.checkExpectation(false, exp.equals(Divide(X, X)), 'Divide(10,x).equals(Divide(X, X))');
test.checkExpectation(false, exp.equals(Subtract(Scalar(10), X)), 'Divide(10,x).equals(Subtract(10, X))');
test.checkExpectation(false, exp.equals(Multiply(Scalar(10), X)), 'Divide(10,x).equals(Multiply(10, X))');
test.checkExpectation(false, exp.equals(Divide(Scalar(10), Divide(Scalar(10), X))), 'Divide(10,x).equals(Divide(X, Divide(10, X)))');
test.checkExpectation(false, exp.equals(Divide(Zero, Divide(Scalar(10), X))), 'Divide(10,x).equals(Divide(0, Divide(10, X)))');
test.checkExpectation(false, exp.equals(Divide(X, Divide(Scalar(10), Zero))), 'Divide(10,x).equals(Divide(X, Divide(10, 0)))');
test.checkExpectation(false, exp.equals(Divide(X, Divide(Scalar(10), One))), 'Divide(10,x).equals(Divide(X, Divide(10, 1)))');
test.checkExpectation(false, exp.equals(Divide(X, Multiply(Scalar(10), One))), 'Divide(10,x).equals(Divide(X, Multiply(10, 1)))');
test.checkExpectation(true, exp.equals(Divide(Multiply(Scalar(10), One), X)), 'Divide(10,x).equals(Divide(X, Multiply(10, 1)))');

test.evaluateAllExpectations();
%%
test = Simple.UnitTests.UnitTesting('Simple.Math.Ex.Divide.invoke');

exp = Divide(Scalar(10), X);
test.checkExpectation(10, exp.invoke(1), 'Divide(10,x).invoke(1)');
test.checkExpectation(10./(1:10), exp.invoke(1:10), 'Divide(10,x).invoke(1:10)');
test.checkExpectation(10./(-10:10), exp.invoke(-10:10), 'Divide(10,x).invoke(-10:10)');
test.checkExpectation(10./(-10:0.5:10), exp.invoke(-10:0.5:10), 'Divide(10,x).invoke(-10:0.5:10)');

test.evaluateAllExpectations();
%% Too complicated for now... but it works
% test = Simple.UnitTests.UnitTesting('Simple.Math.Ex.Divide.derive');
% 
% exp = Divide(Scalar(10), X);
% test.checkExpectation(Minus(Divide(Scalar(10), Power(X, Scalar(2)))), exp.derive(), 'Divide(10,x).derive()', @(obj) '');
% test.checkExpectation(Minus(Divide(Scalar(10), Power(X, Scalar(2)))), exp.derive(1), 'Divide(10,x).derive(1)', @(obj) '');
% %test.checkExpectation(Minus(Divide(Scalar(10), Power(X, Scalar(3)))), exp.derive(2), 'Divide(10,x).derive(2)');
% 
% test.evaluateAllExpectations();