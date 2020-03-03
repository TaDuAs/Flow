import Simple.Math.Ex.*;
disp('Starting Simple.Math.Ex.Multiply class unit tests');
%%
test = Simple.UnitTests.UnitTesting('Simple.Math.Ex.Multiply.ctor');

exp = Multiply(Scalar(10), X);
test.checkExpectation(true, exp.left.equals(10), 'Multiply(10,x).left.equals(10)');
test.checkExpectation(true, exp.right.equals(X), 'Multiply(10,x).right.equals(x)');

exp = Multiply(X, Scalar(10));
test.checkExpectation(true, exp.right.equals(10), 'Multiply(x,10).right.equals(10)');
test.checkExpectation(true, exp.left.equals(X), 'Multiply(x,10).left.equals(x)');

exp = Multiply(X, Multiply(X, X));
test.checkExpectation(true, exp.left.equals(X), 'Multiply(X,Multiply(X,X)).left.equals(x)');
test.checkExpectation(true, isa(exp.right, 'Multiply'), 'Multiply(X,Multiply(X,X)).left.equals(x)');
test.checkExpectation(true, exp.right.left.equals(X), 'Multiply(X,Multiply(X,X)).right.left.equals(x)');
test.checkExpectation(true, exp.right.right.equals(X), 'Multiply(X,Multiply(X,X)).right.right.equals(x)');

test.evaluateAllExpectations();
%%
test = Simple.UnitTests.UnitTesting('Simple.Math.Ex.Multiply.equals');

exp = Multiply(Scalar(10), X);
test.checkExpectation(true, exp.equals(Multiply(Scalar(10), X)), 'Multiply(10,x).equals(Multiply(10, X))');
test.checkExpectation(true, exp.equals(Multiply(X, Scalar(10))), 'Multiply(10,x).equals(Multiply(X, 10))');
test.checkExpectation(false, exp.equals(Multiply(X, X)), 'Multiply(10,x).equals(Multiply(X, X))');
test.checkExpectation(false, exp.equals(Subtract(Scalar(10), X)), 'Multiply(10,x).equals(Subtract(10, X))');
test.checkExpectation(false, exp.equals(Add(Scalar(10), X)), 'Multiply(10,x).equals(Multiply(10, X))');
test.checkExpectation(false, exp.equals(Multiply(Scalar(10), Multiply(Scalar(10), X))), 'Multiply(10,x).equals(Multiply(X, Multiply(10, X)))');
test.checkExpectation(false, exp.equals(Multiply(Zero, Multiply(Scalar(10), X))), 'Multiply(10,x).equals(Multiply(0, Multiply(10, X)))');
test.checkExpectation(false, exp.equals(Multiply(X, Multiply(Scalar(10), Zero))), 'Multiply(10,x).equals(Multiply(X, Multiply(10, 0)))');
test.checkExpectation(true, exp.equals(Multiply(X, Add(Scalar(10), Zero))), 'Multiply(10,x).equals(Multiply(X, Add(10, 0)))');
test.checkExpectation(true, exp.equals(Multiply(X, Multiply(Scalar(10), One))), 'Multiply(10,x).equals(Multiply(X, Multiply(10, 1)))');
test.checkExpectation(false, exp.equals(Multiply(X, Add(Scalar(10), One))), 'Multiply(10,x).equals(Multiply(X, Multiply(10, 1)))');

test.evaluateAllExpectations();
%%
test = Simple.UnitTests.UnitTesting('Simple.Math.Ex.Multiply.invoke');

exp = Multiply(Scalar(10), X);
test.checkExpectation(10, exp.invoke(1), 'Multiply(10,x).invoke(1)');
test.checkExpectation((1:10)*10, exp.invoke(1:10), 'Multiply(10,x).invoke(1:10)');
test.checkExpectation((-10:10)*10, exp.invoke(-10:10), 'Multiply(10,x).invoke(-10:10)');
test.checkExpectation((-10:0.5:10)*10, exp.invoke(-10:0.5:10), 'Multiply(10,x).invoke(-10:0.5:10)');

test.evaluateAllExpectations();
%%
test = Simple.UnitTests.UnitTesting('Simple.Math.Ex.Multiply.derive');

exp = Multiply(Scalar(10), X);
test.checkExpectation(10, exp.derive(), 'Multiply(10,x).derive()');
test.checkExpectation(10, exp.derive(1), 'Multiply(10,x).derive(1)');
test.checkExpectation(Zero, exp.derive(2), 'Multiply(10,x).derive(2)');

test.evaluateAllExpectations();