import Simple.Math.Ex.*;

disp('Starting Simple.Math.Ex.One class unit tests');
test = Simple.UnitTests.UnitTesting('Simple.Math.Ex.One.equals');

uno = One();
test.checkExpectation(true, uno.equals(One), 'uno.equals(One)');
test.checkExpectation(true, uno.equals(Scalar(1)), 'uno.equals(Scalar(1))');
test.checkExpectation(false, uno.equals(Scalar(100)), 'uno.equals(Scalar(100))');
test.checkExpectation(false, uno.equals(Scalar(0)), 'uno.equals(Scalar(0))');
test.checkExpectation(false, uno.equals(Zero), 'uno.equals(Zero)');
test.checkExpectation(false, uno.equals(0), 'uno.equals(0)');
test.checkExpectation(true, uno.equals(1), 'uno.equals(1)');
test.checkExpectation(false, uno.equals(100), 'uno.equals(100)');
test.checkExpectation(false, uno.equals(X), 'uno.equals(X)');

test.evaluateAllExpectations();
test = Simple.UnitTests.UnitTesting('Simple.Math.Ex.Zero.equals');

cero = Zero();
test.checkExpectation(false, cero.equals(One), 'cero.equals(One)');
test.checkExpectation(false, cero.equals(Scalar(1)), 'cero.equals(Scalar(1))');
test.checkExpectation(false, cero.equals(Scalar(100)), 'cero.equals(Scalar(100))');
test.checkExpectation(true, cero.equals(Scalar(0)), 'cero.equals(Scalar(0))');
test.checkExpectation(true, cero.equals(Zero), 'cero.equals(Zero)');
test.checkExpectation(true, cero.equals(0), 'cero.equals(0)');
test.checkExpectation(false, cero.equals(1), 'cero.equals(1)');
test.checkExpectation(false, cero.equals(100), 'cero.equals(100)');
test.checkExpectation(false, cero.equals(X), 'cero.equals(X)');

test.evaluateAllExpectations();
test = Simple.UnitTests.UnitTesting('Simple.Math.Ex.Scalar.equals');

cien = Scalar(100);
test.checkExpectation(false, cien.equals(One), 'cien.equals(One)');
test.checkExpectation(false, cien.equals(Scalar(1)), 'cien.equals(Scalar(1))');
test.checkExpectation(true, cien.equals(Scalar(100)), 'cien.equals(Scalar(100))');
test.checkExpectation(false, cien.equals(Scalar(0)), 'cien.equals(Scalar(0))');
test.checkExpectation(false, cien.equals(Zero), 'cien.equals(Zero)');
test.checkExpectation(false, cien.equals(0), 'cien.equals(0)');
test.checkExpectation(false, cien.equals(1), 'cien.equals(1)');
test.checkExpectation(true, cien.equals(100), 'cien.equals(100)');
test.checkExpectation(false, cien.equals(X), 'cien.equals(X)');

test.evaluateAllExpectations();
test = Simple.UnitTests.UnitTesting('Simple.Math.Ex.Scalar.invoke');

diez = Scalar(10);
test.checkExpectation(10, diez.invoke(1), 'diez.invoke(1)');
test.checkExpectation(10, diez.invoke(10), 'diez.invoke(10)');
test.checkExpectation(10, diez.invoke(100), 'diez.invoke(100)');
test.checkExpectation(10, diez.invoke(0), 'diez.invoke(0)');
test.checkExpectation(zeros(1,10)+10, diez.invoke(1:10), 'diez.invoke(1:10)');
test.checkExpectation((-10:10)*0+10, diez.invoke(-10:10), 'diez.invoke(1:10)');
test.checkExpectation((-10:0.5:10)*0+10, diez.invoke(-10:0.5:10), 'diez.invoke(1:10)');

test.evaluateAllExpectations();
test = Simple.UnitTests.UnitTesting('Simple.Math.Ex.Scalar.derive');

diez = Scalar(10);
test.checkExpectation(true, diez.derive().equals(Zero), 'diez.derive()');
test.checkExpectation(true, diez.derive(1).equals(Zero), 'diez.derive(1)');
test.checkExpectation(true, diez.derive(2).equals(Zero), 'diez.derive(2)');
test.checkExpectation(true, diez.derive(10).equals(Zero), 'diez.derive(10)');

test.evaluateAllExpectations();