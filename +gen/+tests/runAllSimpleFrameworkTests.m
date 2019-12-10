testPkgs = {'gen.tests', 'appd.tests', 'IoC.tests', 'mfc.tests', 'mxml.tests', 'mvvm.tests', 'mvvm.view.tests'};

testSuit = cellfun(@matlab.unittest.TestSuite.fromPackage, testPkgs, 'UniformOutput', false);
testSuit = horzcat(testSuit{:});

run(testSuit)