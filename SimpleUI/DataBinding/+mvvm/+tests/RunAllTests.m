
results = run(matlab.unittest.TestSuite.fromPackage('mvvm.tests'));

%%
fprintf('\n');
fprintf('Totals:\n');
fprintf('\t%d Passed, %d Failed, %d Incomplete.\n', sum([results.Passed]), sum([results.Failed]), sum([results.Incomplete]));
fprintf('\t%f seconds testing time.\n', sum([results.Duration]));