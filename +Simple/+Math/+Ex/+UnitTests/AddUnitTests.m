import Simple.Math.Ex.*;
import Simple.*;
import Simple.UnitTests.UnitTesting;
disp('Starting Simple.Math.Ex.Add class unit tests');
test = UnitTests.UnitTesting('Simple.Math.Ex.Add.ctor');

exp = Add(Scalar(10), X);
test.checkExpectation(true, exp.left.equals(10), 'Add(10,x).left.equals(10)');
test.checkExpectation(true, exp.right.equals(X), 'Add(10,x).right.equals(x)');

exp = Add(X, Scalar(10));
test.checkExpectation(true, exp.right.equals(10), 'Add(x,10).right.equals(10)');
test.checkExpectation(true, exp.left.equals(X), 'Add(x,10).left.equals(x)');

exp = Add(X, Add(X, X));
test.checkExpectation(true, exp.left.equals(X), 'Add(X,Add(X,X)).left.equals(x)');
test.checkExpectation(true, isa(exp.right, 'Add'), 'Add(X,Add(X,X)).left.equals(x)');
test.checkExpectation(true, exp.right.left.equals(X), 'Add(X,Add(X,X)).right.left.equals(x)');
test.checkExpectation(true, exp.right.right.equals(X), 'Add(X,Add(X,X)).right.right.equals(x)');

test.evaluateAllExpectations();
test = UnitTests.UnitTesting('Simple.Math.Ex.Add.equals');

exp = Add(Scalar(10), X);
test.checkExpectation(true, exp.equals(Add(Scalar(10), X)), 'Add(10,x).equals(Add(10, X))');
test.checkExpectation(true, exp.equals(Add(X, Scalar(10))), 'Add(10,x).equals(Add(X, 10))');
test.checkExpectation(false, exp.equals(Add(X, X)), 'Add(10,x).equals(Add(X, X))');
test.checkExpectation(false, exp.equals(Subtract(Scalar(10), X)), 'Add(10,x).equals(Subtract(10, X))');
test.checkExpectation(false, exp.equals(Multiply(Scalar(10), X)), 'Add(10,x).equals(Multiply(10, X))');
test.checkExpectation(false, exp.equals(Add(Scalar(10), Add(Scalar(10), X))), 'Add(10,x).equals(Add(X, Add(10, X)))');
test.checkExpectation(true, exp.equals(Add(Zero, Add(Scalar(10), X))), 'Add(10,x).equals(Add(0, Add(10, X)))');
test.checkExpectation(true, exp.equals(Add(X, Add(Scalar(10), Zero))), 'Add(10,x).equals(Add(X, Add(10, 0)))');
test.checkExpectation(false, exp.equals(Add(X, Add(Scalar(10), One))), 'Add(10,x).equals(Add(X, Add(10, 1)))');
test.checkExpectation(true, exp.equals(Add(X, Multiply(Scalar(10), One))), 'Add(10,x).equals(Add(X, Multiply(10, 1)))');

test.evaluateAllExpectations();
test = UnitTests.UnitTesting('Simple.Math.Ex.Add.invoke');

exp = Add(Scalar(10), X);
test.checkExpectation(11, exp.invoke(1), 'Add(10,x).invoke(1)');
test.checkExpectation((1:10)+10, exp.invoke(1:10), 'Add(10,x).invoke(1:10)');
test.checkExpectation((-10:10)+10, exp.invoke(-10:10), 'Add(10,x).invoke(-10:10)');
test.checkExpectation((-10:0.5:10)+10, exp.invoke(-10:0.5:10), 'Add(10,x).invoke(-10:0.5:10)');

test.evaluateAllExpectations();
test = UnitTests.UnitTesting('Simple.Math.Ex.Add.derive');

exp = Add(Scalar(10), X);
test.checkExpectation(true, exp.derive().equals(One), 'Add(10,x).derive()');
test.checkExpectation(true, exp.derive(1).equals(One), 'Add(10,x).derive(1)');
test.checkExpectation(true, exp.derive(2).equals(Zero), 'Add(10,x).derive(2)');

test.evaluateAllExpectations();