function out = alanineScan(nativeSequence)
    alaScanPos = diag(diag(ones(numel(nativeSequence))));
    sequences = repmat(nativeSequence, numel(nativeSequence), 1);
    sequences(alaScanPos == 1) = 'A';
    out = mat2cell(sequences, ones(1, numel(nativeSequence)), numel(nativeSequence));
    out = [{nativeSequence}; out(cellfun(@(s) ~strcmp(s, nativeSequence), out))];
end

