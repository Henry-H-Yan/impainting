function crack_map = batchFiltering(path_data, name, filterset, filter_params, general_settings)

fileset = dir([path_data '*' name '*' ]);
    
% -- filter operation on blocks -- %
for i = 1:length(fileset)  
    im = imread([path_data fileset(i).name]);
    im = im2double(im);
    im_filtered = useElongatedFilters(im, filterset, filter_params);
    num = strtok(fileset(i).name, '_');
    imwrite(im_filtered, [path_data num '_filter_mask.tif']);    
end


% -- recombine blocks -- %
crack_map = recombineBlocks(path_data, '_filter_mask', general_settings);
crack_map = logical(crack_map);


end