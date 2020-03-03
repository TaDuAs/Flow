import Simple.Math.Ex.*;
disp('Starting Simple.Math.Ex.Shift unit tests');
%%
test = Simple.UnitTests.UnitTesting('Simple.Math.Ex.Shift.ctor');

exp = Shift(X, 10);
test.checkExpectation(X, exp.expression, 'Shift(X, 10).expression.equals(X)');
test.checkExpectation(10, exp.shift, 'Shift(X, 10).shift.equals(10)');

exp = Shift(Subtract(X, X), 10);
test.checkExpectation(true, isa(exp.expression, 'Subtract'), 'Shift(Subtract(X, X), 10).expression.equals(Subtract)');

test.evaluateAllExpectations();
%%
test = Simple.UnitTests.UnitTesting('Simple.Math.Ex.Shift.equals');

exp = Shift(X, 10);
test.checkExpectation(true, exp.equals(Shift(X, 10)), 'Shift(x, 10).equals(Shift(X, 10))');
test.checkExpectation(false, exp.equals(Shift(One, 10)), 'Shift(x, 10).equals(Shift(X, 10))');

test.evaluateAllExpectations();
%%
test = Simple.UnitTests.UnitTesting('Simple.Math.Ex.Shift.invoke');

exp = Shift(X, 10);
test.checkExpectation(11, exp.invoke(1), 'Shift(X,10).invoke(1)');
test.checkExpectation((1:10) + 10, exp.invoke(1:10), 'Shift(X,10).invoke(1:10)');
test.checkExpectation((-10:10) + 10, exp.invoke(-10:10), 'Shift(X,10).invoke(-10:10)');
test.checkExpectation((-10:0.5:10) + 10, exp.invoke(-10:0.5:10), 'Shift(X,10).invoke(-10:0.5:10)');

exp = Shift(X, -5);
test.checkExpectation(-4, exp.invoke(1), 'Shift(X,-5).invoke(1)');
test.checkExpectation((1:10) -5, exp.invoke(1:10), 'Shift(X,-5).invoke(1:10)');
test.checkExpectation((-10:10) -5, exp.invoke(-10:10), 'Shift(X,-5).invoke(-10:10)');
test.checkExpectation((-10:0.5:10) -5, exp.invoke(-10:0.5:10), 'Shift(X,-5).invoke(-10:0.5:10)');

exp = Shift(Subtract(X, One), -10);
test.checkExpectation(-10, exp.invoke(1), 'Shift(Subtract(X, One), -10).invoke(1)');
test.checkExpectation((1:10)-11, exp.invoke(1:10), 'Shift(Subtract(X, One), -10).invoke(1:10)');
test.checkExpectation((-10:10)-11, exp.invoke(-10:10), 'Shift(Subtract(X, One), -10).invoke(-10:10)');
test.checkExpectation((-10:0.5:10)-11, exp.invoke(-10:0.5:10), 'Shift(Subtract(X, One), -10).invoke(-10:0.5:10)');

test.evaluateAllExpectations();
%%
test = Simple.UnitTests.UnitTesting('Common.Math.Expressions.Operators.Subtract.derive');

exp = Shift(X, 10);
test.checkExpectation(Shift(One, 10), exp.derive(), 'Shift(X, 10).derive()');
test.checkExpectation(Shift(One, 10), exp.derive(1), 'Shift(X, 10).derive(1)');
test.checkExpectation(Shift(Zero, 10), exp.derive(2), 'Shift(X, 10).derive(2)');

test.evaluateAllExpectations();