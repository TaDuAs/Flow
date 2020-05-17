function cdata = getIconCData(path, bg, wantedSize)
    % use white as default
    if nargin < 2; bg = [255 255 255]; end
    [img, ~, alpha] = imread(path);
    
    imgd = double(img);
    alphad = double(alpha)/255;
    
    fixedImg = zeros(size(img), 'uint8');
    for i = 1:3
        fixedImg(:,:,i) = uint8(imgd(:,:,i).*alphad + bg(i)*(1-alphad));
    end
    
    if nargin >= 3
        fixedImg = imresize(fixedImg, wantedSize);
    end
    
    cdata = double(fixedImg) / 255;
end

