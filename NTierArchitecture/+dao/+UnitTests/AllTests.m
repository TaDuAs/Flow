import matlab.unittest.TestRunner;
import matlab.unittest.TestSuite;

suite = TestSuite.fromClass(?Simple.DataAccess.UnitTests.DataQueueTests);

runner = TestRunner.withTextOutput;
result = run(runner,suite);